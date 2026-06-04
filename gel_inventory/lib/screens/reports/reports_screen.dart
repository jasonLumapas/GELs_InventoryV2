import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/product.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/invoice_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/stock_movement_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../repositories/van_stock_repository.dart';
import '../../utils/currency_format.dart';
import '../../widgets/common/app_scaffold.dart';

class _SummaryRow {
  final String productName;
  int totalPieces;
  double totalAmount;
  int piecesPerBox;

  _SummaryRow({
    required this.productName,
    required this.totalPieces,
    required this.totalAmount,
    required this.piecesPerBox,
  });

  int get totalBoxes => totalPieces ~/ piecesPerBox;
  int get remainPieces => totalPieces % piecesPerBox;
}

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  DateTime _selectedDate = DateTime.now();
  bool _loading = false;
  List<_SummaryRow> _summary = [];
  double _grandTotal = 0;
  double _capital = 0;

  double get _profit => _grandTotal - _capital;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _loadSummary();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadSummary() async {
    setState(() => _loading = true);
    final invoices = await ref
        .read(invoiceRepositoryProvider)
        .getAll(
          startDate: DateTime(
              _selectedDate.year, _selectedDate.month, _selectedDate.day),
          endDate: DateTime(
              _selectedDate.year, _selectedDate.month, _selectedDate.day + 1),
        );

    final products = await ref.read(productRepositoryProvider).getAll();
    final productsMap = {for (final p in products) p.id: p};

    final Map<String, _SummaryRow> rowMap = {};
    double total = 0;

    for (final inv in invoices) {
      if (inv.status == 'cancelled') continue;
      final items =
          await ref.read(invoiceRepositoryProvider).getItems(inv.id);
      for (final item in items) {
        final product = productsMap[item.productId];
        if (product == null) continue;
        if (rowMap.containsKey(item.productId)) {
          rowMap[item.productId]!.totalPieces += item.quantity;
          rowMap[item.productId]!.totalAmount += item.subtotal;
        } else {
          rowMap[item.productId] = _SummaryRow(
            productName: product.name,
            totalPieces: item.quantity,
            totalAmount: item.subtotal,
            piecesPerBox: product.piecesPerBox,
          );
        }
        total += item.subtotal;
      }
    }

    // Capital = withdrawal_price × pieces sold per product
    double capital = 0;
    for (final entry in rowMap.entries) {
      final price = await ref
          .read(productRepositoryProvider)
          .getCurrentPrice(entry.key);
      if (price != null) {
        capital += price.withdrawalPrice * entry.value.totalPieces;
      }
    }

    setState(() {
      _summary = rowMap.values.toList();
      _grandTotal = total;
      _capital = capital;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Reports',
      body: Column(
        children: [
          TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: 'Daily Summary'),
              Tab(text: 'Inventory Report'),
              Tab(text: 'Movements'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _buildDailySummary(context),
                const _InventoryReportTab(),
                const _ProductMovementsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummary(BuildContext context) {
    final dateFmt = DateFormat('MMMM dd, yyyy');
    return Column(
      children: [
        // Date picker row
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 8),
              Text(dateFmt.format(_selectedDate),
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                    _loadSummary();
                  }
                },
                child: const Text('Change Date'),
              ),
            ],
          ),
        ),

        // Table
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _summary.isEmpty
                  ? const Center(
                      child: Text('No invoices for selected date.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Table(
                            border: TableBorder.all(
                                color: Colors.grey.shade300),
                            columnWidths: const {
                              0: FlexColumnWidth(4),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(2),
                            },
                            children: [
                              _tableHeader([
                                'Product',
                                'Boxes',
                                'Pieces',
                                'Amount'
                              ]),
                              ..._summary.map(
                                (row) => _tableRow([
                                  row.productName,
                                  row.totalBoxes > 0 ? '${row.totalBoxes}' : '',
                                  row.remainPieces > 0 ? '${row.remainPieces}' : '',
                                  formatCurrency(row.totalAmount),
                                ]),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _summaryFooterRow('Grand Total', _grandTotal,
                              bold: true),
                          const SizedBox(height: 6),
                          _summaryFooterRow('Capital', _capital),
                          const SizedBox(height: 6),
                          _summaryFooterRow('Profit', _profit,
                              color: _profit >= 0
                                  ? Colors.green.shade700
                                  : Colors.red),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }

  TableRow _tableHeader(List<String> cells) => TableRow(
        decoration: BoxDecoration(color: Colors.grey.shade200),
        children: cells
            .map((c) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(c,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                ))
            .toList(),
      );

  TableRow _tableRow(List<String> cells) => TableRow(
        children: cells
            .map((c) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(c),
                ))
            .toList(),
      );

  Widget _summaryFooterRow(String label, double amount,
      {bool bold = false, Color? color}) {
    final style = TextStyle(
      fontSize: 15,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: color,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('$label: ', style: style),
        Text(formatCurrency(amount), style: style),
      ],
    );
  }
}

class _InventoryReportTab extends ConsumerStatefulWidget {
  const _InventoryReportTab();

  @override
  ConsumerState<_InventoryReportTab> createState() =>
      _InventoryReportTabState();
}

class _InventoryReportTabState extends ConsumerState<_InventoryReportTab> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedSupplierId; // null = all suppliers

  late Future<_InvData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData(_selectedDate, null);
  }

  void _reload() => setState(() {
        _future = _loadData(_selectedDate, _selectedSupplierId);
      });

  void _setDate(DateTime d) => setState(() {
        _selectedDate = d;
        _future = _loadData(d, _selectedSupplierId);
      });

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) _setDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMMM dd, yyyy');

    return Column(
      children: [
        // ── Date navigation bar ───────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                visualDensity: VisualDensity.compact,
                onPressed: () => _setDate(
                    _selectedDate.subtract(const Duration(days: 1))),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _pickDate,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        dateFmt.format(_selectedDate),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                visualDensity: VisualDensity.compact,
                onPressed: () =>
                    _setDate(_selectedDate.add(const Duration(days: 1))),
              ),
              TextButton(
                onPressed: () => _setDate(DateTime.now()),
                style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact),
                child: const Text('Today'),
              ),
            ],
          ),
        ),
        // ── Supplier filter ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ref.watch(suppliersListProvider).maybeWhen(
                data: (suppliers) => Row(
                  children: [
                    const Text('Supplier:',
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String?>(
                        value: _selectedSupplierId,
                        isDense: true,
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('All Suppliers')),
                          ...suppliers.map((s) => DropdownMenuItem(
                              value: s.id, child: Text(s.name))),
                        ],
                        onChanged: (v) {
                          _selectedSupplierId = v;
                          _reload();
                        },
                      ),
                    ),
                  ],
                ),
                orElse: () => const SizedBox.shrink(),
              ),
        ),
        const Divider(height: 1),

        // ── Table ─────────────────────────────────────────────────────
        Expanded(
          child: FutureBuilder<_InvData>(
            future: _future,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final data = snapshot.data!;
              // Column flex: product=4, each pair=3 (1.5+1.5), total=13
              return SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // ── Group header row (Row widget for true centering) ──
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Container(
                              color: Colors.grey.shade300,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                              child: const Text(''),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              color: _begDark,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: const Text('Beginning',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              color: _inDark,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: const Text('Stock In',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              color: _outDark,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: const Text('Stock Out',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              color: _endDark,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: const Text('Ending',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Column labels + data rows (Table) ──
                    Table(
                      border: TableBorder.all(color: Colors.grey.shade400),
                      columnWidths: const {
                        0: FlexColumnWidth(4),
                        1: FlexColumnWidth(1.5),
                        2: FlexColumnWidth(1.5),
                        3: FlexColumnWidth(1.5),
                        4: FlexColumnWidth(1.5),
                        5: FlexColumnWidth(1.5),
                        6: FlexColumnWidth(1.5),
                        7: FlexColumnWidth(1.5),
                        8: FlexColumnWidth(1.5),
                      },
                      children: [
                        // Column label row (medium shades)
                        TableRow(children: [
                          _cell('Product', Colors.grey.shade200, bold: true),
                          _cell('Boxes', _begMid, bold: true, center: true),
                          _cell('Pcs',   _begMid, bold: true, center: true),
                          _cell('Boxes', _inMid,  bold: true, center: true),
                          _cell('Pcs',   _inMid,  bold: true, center: true),
                          _cell('Boxes', _outMid, bold: true, center: true),
                          _cell('Pcs',   _outMid, bold: true, center: true),
                          _cell('Boxes', _endMid, bold: true, center: true),
                          _cell('Pcs',   _endMid, bold: true, center: true),
                        ]),
                        // Data rows (light shades)
                        ...data.products.map((p) {
                          final beg = data.beginning[p.id] ?? 0;
                          final inn = data.stockIn[p.id]  ?? 0;
                          final out = data.stockOut[p.id] ?? 0;
                          final end = data.ending[p.id]   ?? 0;
                          return TableRow(children: [
                            _cell(p.name, null),
                            _cell(_fmt(beg ~/ p.piecesPerBox), _begLight, center: true),
                            _cell(_fmt(beg % p.piecesPerBox),  _begLight, center: true),
                            _cell(_fmt(inn ~/ p.piecesPerBox), _inLight,  center: true),
                            _cell(_fmt(inn % p.piecesPerBox),  _inLight,  center: true),
                            _cell(_fmt(out ~/ p.piecesPerBox), _outLight, center: true),
                            _cell(_fmt(out % p.piecesPerBox),  _outLight, center: true),
                            _cell(_fmt(end ~/ p.piecesPerBox), _endLight, center: true),
                            _cell(_fmt(end % p.piecesPerBox),  _endLight, center: true),
                          ]);
                        }),
                      ],
                    ),

                    // ── Stock-in value aligned under the Stock In group ──
                    if (data.totalStockInValue > 0)
                      Row(
                        children: [
                          Expanded(flex: 4, child: const SizedBox()),
                          Expanded(flex: 3, child: const SizedBox()),
                          Expanded(
                            flex: 3,
                            child: Container(
                              color: _inLight,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 6),
                              child: Text(
                                formatCurrency(data.totalStockInValue),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ),
                          ),
                          Expanded(flex: 3, child: const SizedBox()),
                          Expanded(flex: 3, child: const SizedBox()),
                        ],
                      ),

                    // ── Ending inventory total footer ──
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Ending Inventory Value: ${formatCurrency(data.totalEndingValue)}',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Group colour palette ──────────────────────────────────────────
  static final _begDark  = Colors.blue.shade200;
  static final _begMid   = Colors.blue.shade100;
  static final _begLight = Colors.blue.shade50;

  static final _inDark   = Colors.teal.shade200;
  static final _inMid    = Colors.teal.shade100;
  static final _inLight  = Colors.teal.shade50;

  static final _outDark  = Colors.orange.shade200;
  static final _outMid   = Colors.orange.shade100;
  static final _outLight = Colors.orange.shade50;

  static final _endDark  = Colors.green.shade200;
  static final _endMid   = Colors.green.shade100;
  static final _endLight = Colors.green.shade50;

  String _fmt(int v) => v > 0 ? '$v' : '';

  Widget _cell(String text, Color? bg,
      {bool bold = false, bool center = false}) =>
      Container(
        color: bg,
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal),
        ),
      );

  /// Computes beginning and ending inventory for [date] relative to the
  /// current physical stock.
  ///
  /// Ending   = current + pieces sold AFTER selected date
  /// Beginning = ending + pieces sold ON selected date
  Future<_InvData> _loadData(DateTime date, String? supplierId) async {
    var products = await ref.read(productRepositoryProvider).getAll();
    if (supplierId != null) {
      products = products.where((p) => p.supplierId == supplierId).toList();
    }

    final inventoryItems =
        await ref.read(inventoryRepositoryProvider).getAll();
    final currentInv = <String, int>{
      for (final i in inventoryItems) i.productId: i.quantityPieces
    };

    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final now = DateTime.now();
    final nowEnd =
        DateTime(now.year, now.month, now.day + 1);

    // Helper: sum van stock transactions by type for a date range
    Future<Map<String, int>> sumVan(String type, DateTime from, DateTime to) async {
      final txs = await ref.read(vanStockRepositoryProvider).getForRange(from, to);
      final totals = <String, int>{};
      for (final t in txs.where((t) => t.type == type)) {
        totals[t.productId] = (totals[t.productId] ?? 0) + t.quantityPieces;
      }
      return totals;
    }

    Map<String, int> merge(Map<String, int> a, Map<String, int> b) {
      final r = Map<String, int>.from(a);
      for (final e in b.entries) { r[e.key] = (r[e.key] ?? 0) + e.value; }
      return r;
    }

    // Pieces sold + van-out ON the selected date → Stock Out
    final invoiceOut    = await _sumSold(ref, dayStart, dayEnd);
    final vanOutOnDate  = await sumVan('out', dayStart, dayEnd);
    final onDate        = merge(invoiceOut, vanOutOnDate);

    // Pieces sold + van-out AFTER the selected date
    final Map<String, int> invoiceOutAfter;
    final Map<String, int> vanOutAfter;
    if (dayEnd.isBefore(nowEnd)) {
      invoiceOutAfter = await _sumSold(ref, dayEnd, nowEnd);
      vanOutAfter     = await sumVan('out', dayEnd, nowEnd);
    } else {
      invoiceOutAfter = {};
      vanOutAfter     = {};
    }
    final afterDate = merge(invoiceOutAfter, vanOutAfter);

    // Stock-in (movements) + van-in ON the selected date → Stock In
    final movIn        = await ref.read(stockMovementRepositoryProvider).sumInForDate(date);
    final vanInOnDate  = await sumVan('in', dayStart, dayEnd);
    final stockIn      = merge(movIn, vanInOnDate);

    // Stock-in + van-in AFTER the selected date
    final Map<String, int> movInAfter;
    final Map<String, int> vanInAfter;
    if (dayEnd.isBefore(nowEnd)) {
      movInAfter  = await ref.read(stockMovementRepositoryProvider).sumInForRange(dayEnd, nowEnd);
      vanInAfter  = await sumVan('in', dayEnd, nowEnd);
    } else {
      movInAfter = {};
      vanInAfter = {};
    }
    final stockInAfter = merge(movInAfter, vanInAfter);

    // Reconstruct ending and beginning by working backwards from current stock.
    // ending   = current + (sold+vanOut)_after  - (movIn+vanIn)_after
    // beginning = ending  + (sold+vanOut)_on_date - (movIn+vanIn)_on_date
    final ending   = <String, int>{};
    final beginning = <String, int>{};
    for (final p in products) {
      final end = (currentInv[p.id] ?? 0)
          + (afterDate[p.id] ?? 0)
          - (stockInAfter[p.id] ?? 0);
      ending[p.id] = end.clamp(0, 999999);
      final beg = end + (onDate[p.id] ?? 0) - (stockIn[p.id] ?? 0);
      beginning[p.id] = beg.clamp(0, 999999);
    }

    // Total ending inventory value = ending pieces × withdrawal price
    // Total stock-in value = stock-in pieces × withdrawal price
    double totalEndingValue  = 0;
    double totalStockInValue = 0;
    for (final p in products) {
      final price = await ref
          .read(productRepositoryProvider)
          .getCurrentPrice(p.id);
      if (price == null) continue;
      final endPieces = ending[p.id] ?? 0;
      if (endPieces > 0) {
        totalEndingValue += price.withdrawalPrice * endPieces;
      }
      final inPieces = stockIn[p.id] ?? 0;
      if (inPieces > 0) {
        totalStockInValue += price.withdrawalPrice * inPieces;
      }
    }

    return _InvData(
        products: products,
        beginning: beginning,
        stockIn: stockIn,
        stockOut: onDate,
        ending: ending,
        totalEndingValue: totalEndingValue,
        totalStockInValue: totalStockInValue);
  }

  Future<Map<String, int>> _sumSold(
      WidgetRef ref, DateTime from, DateTime to) async {
    final invoices = await ref
        .read(invoiceRepositoryProvider)
        .getAll(startDate: from, endDate: to);
    final sold = <String, int>{};
    for (final inv in invoices) {
      if (inv.status == 'cancelled') continue;
      final items =
          await ref.read(invoiceRepositoryProvider).getItems(inv.id);
      for (final item in items) {
        sold[item.productId] =
            (sold[item.productId] ?? 0) + item.quantity;
      }
    }
    return sold;
  }
}

class _InvData {
  final List<Product> products;
  final Map<String, int> beginning;
  final Map<String, int> stockIn;
  final Map<String, int> stockOut;
  final Map<String, int> ending;
  final double totalEndingValue;
  final double totalStockInValue;

  const _InvData({
    required this.products,
    required this.beginning,
    required this.stockIn,
    required this.stockOut,
    required this.ending,
    required this.totalEndingValue,
    required this.totalStockInValue,
  });
}

// ── Product Movements Tab ─────────────────────────────────────────────────────

enum _MovementPeriod { day, week, month, year }

class _ProductMovementsTab extends ConsumerStatefulWidget {
  const _ProductMovementsTab();

  @override
  ConsumerState<_ProductMovementsTab> createState() =>
      _ProductMovementsTabState();
}

class _ProductMovementsTabState extends ConsumerState<_ProductMovementsTab> {
  _MovementPeriod _period = _MovementPeriod.month;
  DateTime _anchor = DateTime.now();
  late Future<List<_MovementRow>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  void _setPeriod(_MovementPeriod p) =>
      setState(() {
        _period = p;
        _future = _load();
      });

  void _setAnchor(DateTime d) =>
      setState(() {
        _anchor = d;
        _future = _load();
      });

  DateTime get _startDate {
    switch (_period) {
      case _MovementPeriod.day:
        return DateTime(_anchor.year, _anchor.month, _anchor.day);
      case _MovementPeriod.week:
        final mon = _anchor.subtract(Duration(days: _anchor.weekday - 1));
        return DateTime(mon.year, mon.month, mon.day);
      case _MovementPeriod.month:
        return DateTime(_anchor.year, _anchor.month);
      case _MovementPeriod.year:
        return DateTime(_anchor.year);
    }
  }

  DateTime get _endDate {
    switch (_period) {
      case _MovementPeriod.day:
        return _startDate.add(const Duration(days: 1));
      case _MovementPeriod.week:
        return _startDate.add(const Duration(days: 7));
      case _MovementPeriod.month:
        return DateTime(_anchor.year, _anchor.month + 1);
      case _MovementPeriod.year:
        return DateTime(_anchor.year + 1);
    }
  }

  String get _periodLabel {
    final fmt = DateFormat('MMM d, y');
    switch (_period) {
      case _MovementPeriod.day:
        return DateFormat('EEE, MMM d, y').format(_startDate);
      case _MovementPeriod.week:
        return '${fmt.format(_startDate)} – ${fmt.format(_endDate.subtract(const Duration(days: 1)))}';
      case _MovementPeriod.month:
        return DateFormat('MMMM y').format(_startDate);
      case _MovementPeriod.year:
        return _startDate.year.toString();
    }
  }

  Future<List<_MovementRow>> _load() async {
    final products = await ref.read(productRepositoryProvider).getAll();
    final productsById = {for (final p in products) p.id: p};
    final Map<String, _MovementRow> rows = {};

    // Stock-out from invoices
    final invoices = await ref
        .read(invoiceRepositoryProvider)
        .getAll(startDate: _startDate, endDate: _endDate);
    for (final inv in invoices) {
      if (inv.status == 'cancelled') continue;
      final items =
          await ref.read(invoiceRepositoryProvider).getItems(inv.id);
      for (final item in items) {
        final p = productsById[item.productId];
        if (p == null) continue;
        if (rows.containsKey(item.productId)) {
          rows[item.productId]!.outPieces += item.quantity;
          rows[item.productId]!.totalAmount += item.subtotal;
        } else {
          rows[item.productId] = _MovementRow(
            productName: p.name,
            piecesPerBox: p.piecesPerBox,
            outPieces: item.quantity,
            totalAmount: item.subtotal,
          );
        }
      }
    }

    // Stock-in from manual stock movements
    final stockIn = await ref
        .read(stockMovementRepositoryProvider)
        .sumInForRange(_startDate, _endDate);
    for (final entry in stockIn.entries) {
      final p = productsById[entry.key];
      if (p == null) continue;
      if (rows.containsKey(entry.key)) {
        rows[entry.key]!.inPieces += entry.value;
      } else {
        rows[entry.key] = _MovementRow(
          productName: p.name,
          piecesPerBox: p.piecesPerBox,
          outPieces: 0,
          totalAmount: 0,
          inPieces: entry.value,
        );
      }
    }

    final sorted = rows.values.toList()
      ..sort((a, b) => b.totalMoved.compareTo(a.totalMoved));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Period filter bar
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Row(
            children: [
              SegmentedButton<_MovementPeriod>(
                segments: const [
                  ButtonSegment(value: _MovementPeriod.day, label: Text('Day')),
                  ButtonSegment(
                      value: _MovementPeriod.week, label: Text('Week')),
                  ButtonSegment(
                      value: _MovementPeriod.month, label: Text('Month')),
                  ButtonSegment(
                      value: _MovementPeriod.year, label: Text('Year')),
                ],
                selected: {_period},
                onSelectionChanged: (s) => _setPeriod(s.first),
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  switch (_period) {
                    case _MovementPeriod.day:
                      _setAnchor(
                          _anchor.subtract(const Duration(days: 1)));
                    case _MovementPeriod.week:
                      _setAnchor(
                          _anchor.subtract(const Duration(days: 7)));
                    case _MovementPeriod.month:
                      _setAnchor(
                          DateTime(_anchor.year, _anchor.month - 1));
                    case _MovementPeriod.year:
                      _setAnchor(DateTime(_anchor.year - 1));
                  }
                },
              ),
              Expanded(
                child: Text(_periodLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  switch (_period) {
                    case _MovementPeriod.day:
                      _setAnchor(_anchor.add(const Duration(days: 1)));
                    case _MovementPeriod.week:
                      _setAnchor(_anchor.add(const Duration(days: 7)));
                    case _MovementPeriod.month:
                      _setAnchor(
                          DateTime(_anchor.year, _anchor.month + 1));
                    case _MovementPeriod.year:
                      _setAnchor(DateTime(_anchor.year + 1));
                  }
                },
              ),
              TextButton(
                onPressed: () => _setAnchor(DateTime.now()),
                style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact),
                child: const Text('Today'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Results
        Expanded(
          child: FutureBuilder<List<_MovementRow>>(
            future: _future,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final rows = snap.data ?? [];
              if (rows.isEmpty) {
                return const Center(
                    child: Text('No movement data for this period.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: rows.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final row = rows[i];
                  final isTop = i < 3;
                  final isLeast = i >= rows.length - 3 && rows.length > 3;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isTop
                          ? Colors.green.shade100
                          : isLeast
                              ? Colors.orange.shade100
                              : Colors.grey.shade100,
                      child: Text('${i + 1}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isTop
                                  ? Colors.green.shade800
                                  : isLeast
                                      ? Colors.orange.shade800
                                      : Colors.grey.shade600)),
                    ),
                    title: Text(row.productName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (row.inPieces > 0)
                          Text(
                            'In: ${row.inBoxes} box(es) + ${row.inRemain} pcs',
                            style: TextStyle(color: Colors.teal.shade700),
                          ),
                        if (row.outPieces > 0)
                          Text(
                            'Out: ${row.outBoxes} box(es) + ${row.outRemain} pcs',
                            style: TextStyle(color: Colors.orange.shade700),
                          ),
                      ],
                    ),
                    trailing: row.totalAmount > 0
                        ? Text(formatCurrency(row.totalAmount),
                            style: const TextStyle(fontWeight: FontWeight.bold))
                        : null,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MovementRow {
  final String productName;
  final int piecesPerBox;
  int outPieces;
  double totalAmount;
  int inPieces;

  _MovementRow({
    required this.productName,
    required this.piecesPerBox,
    required this.outPieces,
    required this.totalAmount,
    this.inPieces = 0,
  });

  int get outBoxes => outPieces ~/ piecesPerBox;
  int get outRemain => outPieces % piecesPerBox;
  int get inBoxes  => inPieces ~/ piecesPerBox;
  int get inRemain => inPieces % piecesPerBox;
  int get totalMoved => outPieces + inPieces;
}
