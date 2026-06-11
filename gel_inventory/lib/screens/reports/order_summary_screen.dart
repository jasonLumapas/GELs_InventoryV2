import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/product.dart';
import '../../repositories/bad_order_repository.dart';
import '../../repositories/invoice_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../utils/currency_format.dart';
import '../../utils/pdf_generator.dart';
import '../../widgets/common/app_scaffold.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class _Row {
  final String productId;
  final String productName;
  final String supplierName;
  final int piecesPerBox;
  int totalPieces;
  double totalAmount;

  _Row({
    required this.productId,
    required this.productName,
    required this.supplierName,
    required this.piecesPerBox,
    required this.totalPieces,
    required this.totalAmount,
  });

  int get boxes => totalPieces ~/ piecesPerBox;
  int get remainingPieces => totalPieces % piecesPerBox;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class OrderSummaryScreen extends ConsumerStatefulWidget {
  const OrderSummaryScreen({super.key});

  @override
  ConsumerState<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends ConsumerState<OrderSummaryScreen> {
  DateTime _selectedDate =
      DateTime.now().add(const Duration(days: 1));
  bool _loading = false;
  List<_Row> _rows = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _rows = [];
    });

    final start = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day);
    final end = start.add(const Duration(days: 1));

    final invoices = await ref
        .read(invoiceRepositoryProvider)
        .getAll(startDate: start, endDate: end);

    final products  = await ref.read(productRepositoryProvider).getAll();
    final suppliers = await ref.read(supplierRepositoryProvider).getAll();
    final productsById  = <String, Product>{for (final p in products) p.id: p};
    final suppliersById = <String, String>{for (final s in suppliers) s.id: s.name};

    final Map<String, _Row> rowMap = {};

    for (final inv in invoices) {
      if (inv.status == 'cancelled') continue;
      if (!inv.isDelivery) continue;
      final items =
          await ref.read(invoiceRepositoryProvider).getItems(inv.id);
      for (final item in items) {
        final product = productsById[item.productId];
        if (product == null) continue;
        if (rowMap.containsKey(item.productId)) {
          rowMap[item.productId]!.totalPieces += item.quantity;
          rowMap[item.productId]!.totalAmount += item.subtotal;
        } else {
          rowMap[item.productId] = _Row(
            productId: item.productId,
            productName: product.name,
            supplierName: suppliersById[product.supplierId] ?? 'Unknown',
            piecesPerBox: product.piecesPerBox,
            totalPieces: item.quantity,
            totalAmount: item.subtotal,
          );
        }
      }
    }

    final badOrders = await ref.read(badOrderRepositoryProvider).getAll();
    for (final o in badOrders) {
      if (o.type != 'bad_order') continue;
      if (o.date.isBefore(start) || !o.date.isBefore(end)) continue;
      final items = await ref.read(badOrderRepositoryProvider).getItems(o.id);
      for (final item in items) {
        final product = productsById[item.productId];
        if (product == null) continue;
        final pieces = item.unitType == 'box'
            ? item.quantity * product.piecesPerBox
            : item.quantity;
        final price =
            await ref.read(productRepositoryProvider).getCurrentPrice(item.productId);
        final amount = pieces * (price?.sellingPrice ?? 0.0);
        if (rowMap.containsKey(item.productId)) {
          rowMap[item.productId]!.totalPieces += pieces;
          rowMap[item.productId]!.totalAmount += amount;
        } else {
          rowMap[item.productId] = _Row(
            productId: item.productId,
            productName: product.name,
            supplierName: suppliersById[product.supplierId] ?? 'Unknown',
            piecesPerBox: product.piecesPerBox,
            totalPieces: pieces,
            totalAmount: amount,
          );
        }
      }
    }

    setState(() {
      _rows = rowMap.values.toList()
        ..sort((a, b) {
          final s = a.supplierName.compareTo(b.supplierName);
          return s != 0 ? s : a.productName.compareTo(b.productName);
        });
      _loading = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _load();
    }
  }

  void _prevDay() {
    setState(
        () => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
    _load();
  }

  void _nextDay() {
    setState(
        () => _selectedDate = _selectedDate.add(const Duration(days: 1)));
    _load();
  }

  Future<void> _print() async {
    await printOrderSummary(
      date: _selectedDate,
      rows: _rows
          .map((r) => OrderSummaryRow(
                productName: r.productName,
                totalPieces: r.totalPieces,
                piecesPerBox: r.piecesPerBox,
                totalAmount: r.totalAmount,
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMMM dd, yyyy');
    final grandTotal = _rows.fold(0.0, (s, r) => s + r.totalAmount);

    return AppScaffold(
      title: 'Layout',
      actions: [
        if (_rows.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print summary',
            onPressed: _print,
          ),
      ],
      body: Column(
        children: [
          // ── Date bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _prevDay,
                        visualDensity: VisualDensity.compact,
                      ),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              dateFmt.format(_selectedDate),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _nextDay,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _selectedDate =
                        DateTime.now().add(const Duration(days: 1)));
                    _load();
                  },
                  style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact),
                  child: const Text('Today'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Table ─────────────────────────────────────────────────────
          if (_loading)
            const Expanded(
                child: Center(child: CircularProgressIndicator()))
          else if (_rows.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No orders for ${dateFmt.format(_selectedDate)}.',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  // Header row
                  _TableHeader(),

                  // Data rows grouped by supplier
                  Expanded(
                    child: Builder(builder: (ctx) {
                      // Build a flat list: header String + _Row items
                      final List<dynamic> listItems = [];
                      String? lastSupplier;
                      for (final row in _rows) {
                        if (row.supplierName != lastSupplier) {
                          listItems.add(row.supplierName);
                          lastSupplier = row.supplierName;
                        }
                        listItems.add(row);
                      }
                      return ListView.separated(
                        itemCount: listItems.length,
                        separatorBuilder: (_, i) {
                          // No divider before/after supplier headers
                          if (listItems[i] is String) return const SizedBox();
                          if (i + 1 < listItems.length &&
                              listItems[i + 1] is String) {
                            return const SizedBox();
                          }
                          return const Divider(height: 1);
                        },
                        itemBuilder: (ctx, i) {
                          final item = listItems[i];
                          if (item is String) {
                            return Container(
                              color: Theme.of(ctx)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              child: Text(item,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Theme.of(ctx)
                                        .colorScheme
                                        .primary,
                                    letterSpacing: 0.5,
                                  )),
                            );
                          }
                          return _TableDataRow(row: item as _Row);
                        },
                      );
                    }),
                  ),

                  const Divider(height: 1, thickness: 2),
                  _GrandTotalFooter(grandTotal: grandTotal),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Table widgets ─────────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: 13,
    );
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 5, child: Text('Product', style: headerStyle)),
          Expanded(
              flex: 2,
              child: Text('Boxes',
                  style: headerStyle, textAlign: TextAlign.center)),
          Expanded(
              flex: 2,
              child: Text('Pieces',
                  style: headerStyle, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}

class _TableDataRow extends StatelessWidget {
  final _Row row;
  const _TableDataRow({required this.row});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(row.productName,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.boxes > 0 ? '${row.boxes}' : '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.remainingPieces > 0 ? '${row.remainingPieces}' : '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GrandTotalFooter extends StatelessWidget {
  final double grandTotal;
  const _GrandTotalFooter({required this.grandTotal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('Grand Total: ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text(
            formatCurrency(grandTotal),
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15),
          ),
        ],
      ),
    );
  }
}
