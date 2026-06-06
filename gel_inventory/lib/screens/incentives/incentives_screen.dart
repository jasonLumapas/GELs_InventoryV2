import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/services/incentives_settings_service.dart';
import '../../repositories/bad_order_repository.dart';
import '../../repositories/invoice_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../utils/currency_format.dart';
import '../../widgets/common/app_scaffold.dart';

// ── Data models ───────────────────────────────────────────────────────────────

class _SupplierCol {
  final String id;
  final String name;
  const _SupplierCol({required this.id, required this.name});
}

class _DayData {
  final int day;
  double grandTotal = 0;
  // RAM (fixed column — always present, has Sales + BO)
  double ramSales = 0;
  double ramBoAmount = 0;
  // Additional configured suppliers (Sales only)
  final Map<String, double> additionalSales = {};
  _DayData(this.day);
}

class _MonthData {
  final List<_DayData> days;
  final String ramName;               // displayed name for the RAM column header
  final List<_SupplierCol> additional; // extra configured supplier columns

  _MonthData({
    required this.days,
    required this.ramName,
    required this.additional,
  });

  double get totalGrand =>
      days.fold(0.0, (s, d) => s + d.grandTotal);
  double get totalRamSales =>
      days.fold(0.0, (s, d) => s + d.ramSales);
  double get totalRamBoAmount =>
      days.fold(0.0, (s, d) => s + d.ramBoAmount);
  double totalAdditionalSales(String sid) =>
      days.fold(0.0, (s, d) => s + (d.additionalSales[sid] ?? 0.0));
}

// ── Screen ────────────────────────────────────────────────────────────────────

class IncentivesScreen extends ConsumerStatefulWidget {
  const IncentivesScreen({super.key});

  @override
  ConsumerState<IncentivesScreen> createState() => _IncentivesScreenState();
}

class _IncentivesScreenState extends ConsumerState<IncentivesScreen> {
  DateTime _selectedMonth =
      DateTime(DateTime.now().year, DateTime.now().month);
  List<String> _configuredIds = []; // additional supplier IDs (not RAM)
  late Future<_MonthData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadSettingsThenMonth();
  }

  Future<_MonthData> _loadSettingsThenMonth() async {
    _configuredIds = await IncentivesSettingsService.loadSupplierIds();
    return _loadMonth(_selectedMonth);
  }

  void _setMonth(DateTime m) => setState(() {
        _selectedMonth = DateTime(m.year, m.month);
        _future = _loadMonth(_selectedMonth);
      });

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedMonth.year, _selectedMonth.month, 15),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) _setMonth(DateTime(picked.year, picked.month));
  }

  Future<void> _openSettings() async {
    await showDialog<void>(
      context: context,
      builder: (_) => _SettingsDialog(
        configuredIds: List.from(_configuredIds),
        onSave: (newIds) async {
          await IncentivesSettingsService.saveSupplierIds(newIds);
          setState(() {
            _configuredIds = newIds;
            _future = _loadMonth(_selectedMonth);
          });
        },
      ),
    );
  }

  Future<_MonthData> _loadMonth(DateTime month) async {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final suppliers = await ref.read(supplierRepositoryProvider).getAll();
    final products = await ref.read(productRepositoryProvider).getAll();

    // ── Find RAM supplier ─────────────────────────────────────────────────────
    String? ramId;
    String ramName = 'RAM';
    for (final s in suppliers) {
      if (s.name.trim().toLowerCase() == 'ram') {
        ramId = s.id;
        ramName = s.name;
        break;
      }
    }

    // ── Build additional supplier columns (preserving order) ─────────────────
    final suppById = {for (final s in suppliers) s.id: s.name};
    final additional = _configuredIds
        .where((id) => suppById.containsKey(id) && id != ramId)
        .map((id) => _SupplierCol(id: id, name: suppById[id]!))
        .toList();

    // ── Product → supplier lookup ─────────────────────────────────────────────
    final productSupplier = <String, String>{
      for (final p in products) p.id: p.supplierId
    };
    final piecesPerBoxById = <String, int>{
      for (final p in products) p.id: p.piecesPerBox
    };

    final additionalSet = {for (final c in additional) c.id};
    final needItems = ramId != null || additionalSet.isNotEmpty;

    final days = List.generate(daysInMonth, (i) => _DayData(i + 1));

    // ── Invoices ──────────────────────────────────────────────────────────────
    final invoices = await ref.read(invoiceRepositoryProvider).getAll(
          startDate: monthStart,
          endDate: monthEnd,
        );

    for (final inv in invoices) {
      final d = inv.invoiceDate.day - 1;
      if (d < 0 || d >= daysInMonth) continue;
      days[d].grandTotal += inv.totalAmount;

      if (needItems) {
        final items =
            await ref.read(invoiceRepositoryProvider).getItems(inv.id);
        for (final item in items) {
          final sid = productSupplier[item.productId];
          if (sid == null) continue;
          if (sid == ramId) {
            days[d].ramSales += item.subtotal;
          } else if (additionalSet.contains(sid)) {
            days[d].additionalSales[sid] =
                (days[d].additionalSales[sid] ?? 0.0) + item.subtotal;
          }
        }
      }
    }

    // ── Bad orders — RAM only ─────────────────────────────────────────────────
    if (ramId != null) {
      final allBo = await ref.read(badOrderRepositoryProvider).getAll();
      for (final bo in allBo) {
        if (bo.date.isBefore(monthStart) || !bo.date.isBefore(monthEnd)) {
          continue;
        }
        final d = bo.date.day - 1;
        if (d < 0 || d >= daysInMonth) continue;
        final items =
            await ref.read(badOrderRepositoryProvider).getItems(bo.id);
        for (final item in items) {
          if (productSupplier[item.productId] == ramId) {
            final ppb = piecesPerBoxById[item.productId] ?? 1;
            final pieces =
                item.unitType == 'box' ? item.quantity * ppb : item.quantity;
            final price = await ref
                .read(productRepositoryProvider)
                .getCurrentPrice(item.productId);
            final unitPrice = price?.sellingPrice ?? 0.0;
            days[d].ramBoAmount += pieces * unitPrice;
          }
        }
      }
    }

    return _MonthData(days: days, ramName: ramName, additional: additional);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy').format(_selectedMonth);

    return AppScaffold(
      title: 'Incentives',
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Configure additional supplier columns',
          onPressed: _openSettings,
        ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _setMonth(DateTime(
                      _selectedMonth.year, _selectedMonth.month - 1)),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickMonth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_month,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(monthLabel,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _setMonth(DateTime(
                      _selectedMonth.year, _selectedMonth.month + 1)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<_MonthData>(
              future: _future,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                return _buildTable(snap.data!);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Colors ────────────────────────────────────────────────────────────────
  // RAM is always purple. Additional suppliers cycle through the rest.
  static const _ramDark  = Colors.purple;
  static const _ramMid   = Colors.purple;
  static const _ramLight = Colors.purple;

  static Color _addDark(int i) {
    const palette = [
      Colors.teal, Colors.orange, Colors.green, Colors.blue, Colors.pink,
    ];
    return palette[i % palette.length].shade200;
  }

  static Color _addMid(int i) {
    const palette = [
      Colors.teal, Colors.orange, Colors.green, Colors.blue, Colors.pink,
    ];
    return palette[i % palette.length].shade100;
  }

  static Color _addLight(int i) {
    const palette = [
      Colors.teal, Colors.orange, Colors.green, Colors.blue, Colors.pink,
    ];
    return palette[i % palette.length].shade50;
  }

  // Column layout:
  //   0 Date(3)  1 GrandTotal(4)  2 RamSales(4)  3 RamBO(3)
  //   4+i  AdditionalSales(4) for i in 0..n-1
  Map<int, TableColumnWidth> _buildColWidths(int n) {
    return {
      0: const FlexColumnWidth(3),
      1: const FlexColumnWidth(4),
      2: const FlexColumnWidth(4),
      3: const FlexColumnWidth(3),
      for (int i = 0; i < n; i++) 4 + i: const FlexColumnWidth(4),
    };
  }

  Widget _buildTable(_MonthData data) {
    final dateFmt = DateFormat('MMM d');
    final n = data.additional.length;
    final colWidths = _buildColWidths(n);

    final dataBorder = TableBorder(
      left: BorderSide(color: Colors.grey.shade400),
      right: BorderSide(color: Colors.grey.shade400),
      bottom: BorderSide(color: Colors.grey.shade400),
      horizontalInside: BorderSide(color: Colors.grey.shade400),
      verticalInside: BorderSide(color: Colors.grey.shade400),
    );
    final headerBorder = TableBorder(
      left: BorderSide(color: Colors.grey.shade400),
      right: BorderSide(color: Colors.grey.shade400),
      bottom: BorderSide(color: Colors.grey.shade400),
      verticalInside: BorderSide(color: Colors.grey.shade400),
    );
    final totalBorder = TableBorder(
      top: BorderSide(color: Colors.grey.shade600, width: 1.5),
      left: BorderSide(color: Colors.grey.shade400),
      right: BorderSide(color: Colors.grey.shade400),
      bottom: BorderSide(color: Colors.grey.shade400),
      verticalInside: BorderSide(color: Colors.grey.shade400),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Sticky headers ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Group header row
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400)),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        color: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        child: const Text(''),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        color: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text('Grand Total',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    // RAM — fixed, flex 7 (Sales 4 + BO 3)
                    Expanded(
                      flex: 7,
                      child: Container(
                        color: _ramDark.shade200,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(data.ramName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    // Additional suppliers — each flex 4 (Sales only)
                    for (int i = 0; i < n; i++)
                      Expanded(
                        flex: 4,
                        child: Container(
                          color: _addDark(i),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(data.additional[i].name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
              // Column labels row
              Table(
                border: headerBorder,
                columnWidths: colWidths,
                children: [
                  TableRow(children: [
                    _cell('Date', Colors.grey.shade200,
                        bold: true, center: true),
                    _cell('Amount', Colors.grey.shade200,
                        bold: true, center: true),
                    _cell('Sales', _ramMid.shade100,
                        bold: true, center: true),
                    _cell('BO (pcs)', _ramMid.shade100,
                        bold: true, center: true),
                    for (int i = 0; i < n; i++)
                      _cell('Sales', _addMid(i), bold: true, center: true),
                  ]),
                ],
              ),
            ],
          ),
        ),
        // ── Scrollable data rows + totals ───────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Data rows
                Table(
                  border: dataBorder,
                  columnWidths: colWidths,
                  children: data.days.map((d) {
                    final date = DateTime(
                        _selectedMonth.year, _selectedMonth.month, d.day);
                    final hasData = d.grandTotal > 0 ||
                        d.ramSales > 0 ||
                        d.ramBoAmount > 0 ||
                        d.additionalSales.values.any((v) => v > 0);
                    return TableRow(children: [
                      _cell(dateFmt.format(date), null),
                      _cell(hasData ? formatCurrency(d.grandTotal) : '—',
                          null,
                          center: true),
                      _cell(
                          d.ramSales > 0
                              ? formatCurrency(d.ramSales)
                              : '—',
                          _ramLight.shade50,
                          center: true),
                      _cell(
                          d.ramBoAmount > 0
                              ? formatCurrency(d.ramBoAmount)
                              : '—',
                          _ramLight.shade50,
                          center: true),
                      for (int i = 0; i < n; i++)
                        _cell(
                            (d.additionalSales[data.additional[i].id] ?? 0) >
                                    0
                                ? formatCurrency(
                                    d.additionalSales[data.additional[i].id]!)
                                : '—',
                            _addLight(i),
                            center: true),
                    ]);
                  }).toList(),
                ),
                // Totals row
                Table(
                  border: totalBorder,
                  columnWidths: colWidths,
                  children: [
                    TableRow(children: [
                      _cell('Total', Colors.grey.shade200, bold: true),
                      _cell(formatCurrency(data.totalGrand),
                          Colors.grey.shade200,
                          bold: true, center: true),
                      _cell(formatCurrency(data.totalRamSales),
                          _ramMid.shade100,
                          bold: true, center: true),
                      _cell(
                          data.totalRamBoAmount > 0
                              ? formatCurrency(data.totalRamBoAmount)
                              : '—',
                          _ramMid.shade100,
                          bold: true,
                          center: true),
                      for (int i = 0; i < n; i++)
                        _cell(
                            formatCurrency(data.totalAdditionalSales(
                                data.additional[i].id)),
                            _addMid(i),
                            bold: true,
                            center: true),
                    ]),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

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
}

// ── Settings dialog ───────────────────────────────────────────────────────────
// Manages only the additional supplier columns. RAM is always present.

class _SettingsDialog extends ConsumerStatefulWidget {
  final List<String> configuredIds;
  final Future<void> Function(List<String>) onSave;

  const _SettingsDialog({
    required this.configuredIds,
    required this.onSave,
  });

  @override
  ConsumerState<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<_SettingsDialog> {
  late List<String> _ids;
  String? _selectedToAdd;

  @override
  void initState() {
    super.initState();
    _ids = List.from(widget.configuredIds);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Additional Supplier Columns'),
      content: SizedBox(
        width: 340,
        child: ref.watch(suppliersListProvider).maybeWhen(
          data: (suppliers) {
            // Exclude RAM (always shown) and already-configured suppliers
            final nonRam = suppliers
                .where((s) => s.name.trim().toLowerCase() != 'ram')
                .toList();
            final suppById = {for (final s in nonRam) s.id: s.name};
            final available =
                nonRam.where((s) => !_ids.contains(s.id)).toList();

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                    'The RAM column is always shown. Configure extra supplier columns (Sales only) below.',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                const Text('Additional columns:',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 4),
                if (_ids.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('None configured.',
                        style: TextStyle(color: Colors.grey)),
                  )
                else
                  ..._ids.asMap().entries.map((e) => ListTile(
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        leading: CircleAvatar(
                          radius: 11,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          child: Text('${e.key + 1}',
                              style: const TextStyle(fontSize: 11)),
                        ),
                        title: Text(suppById[e.value] ?? e.value),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              size: 20),
                          color: Colors.red.shade300,
                          tooltip: 'Remove',
                          onPressed: () =>
                              setState(() => _ids.removeAt(e.key)),
                        ),
                      )),
                const Divider(height: 20),
                if (available.isNotEmpty) ...[
                  const Text('Add supplier:',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color:
                                    Theme.of(context).colorScheme.outline),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          child: DropdownButton<String>(
                            value: _selectedToAdd,
                            hint: const Text('Select supplier...'),
                            isExpanded: true,
                            isDense: true,
                            underline: const SizedBox(),
                            items: available
                                .map((s) => DropdownMenuItem(
                                      value: s.id,
                                      child: Text(s.name),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedToAdd = v),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        onPressed: _selectedToAdd == null
                            ? null
                            : () => setState(() {
                                  _ids.add(_selectedToAdd!);
                                  _selectedToAdd = null;
                                }),
                      ),
                    ],
                  ),
                ] else if (_ids.isNotEmpty)
                  Text('All non-RAM suppliers are already added.',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade500)),
              ],
            );
          },
          orElse: () => const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator())),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            await widget.onSave(_ids);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
