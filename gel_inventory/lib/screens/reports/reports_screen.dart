import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/product.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/invoice_repository.dart';
import '../../repositories/product_repository.dart';
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
    _tabs = TabController(length: 2, vsync: this);
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
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _buildDailySummary(context),
                const _InventoryReportTab(),
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
                                  '${row.totalBoxes}',
                                  '${row.totalPieces}',
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

class _InventoryReportTab extends ConsumerWidget {
  const _InventoryReportTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: _loadData(ref),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final (products, inventoryMap) = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            columnWidths: const {
              0: FlexColumnWidth(4),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
            },
            children: [
              _header(['Product', 'Qty (pcs)', 'Qty (boxes)', 'Rem. pcs']),
              ...products.map((p) {
                final qty = inventoryMap[p.id] ?? 0;
                final boxes = qty ~/ p.piecesPerBox;
                final rem = qty % p.piecesPerBox;
                return _row([
                  p.name,
                  formatNumber(qty),
                  '$boxes',
                  '$rem',
                ]);
              }),
            ],
          ),
        );
      },
    );
  }

  Future<(List<Product>, Map<String, int>)> _loadData(WidgetRef ref) async {
    final products = await ref.read(productRepositoryProvider).getAll();
    final inventoryItems =
        await ref.read(inventoryRepositoryProvider).getAll();
    final inventoryMap = {
      for (final i in inventoryItems) i.productId: i.quantityPieces
    };
    return (products, inventoryMap);
  }

  TableRow _header(List<String> cells) => TableRow(
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

  TableRow _row(List<String> cells) => TableRow(
        children: cells
            .map((c) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(c),
                ))
            .toList(),
      );
}
