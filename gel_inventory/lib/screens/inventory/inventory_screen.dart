import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/inventory_item.dart';
import '../../models/product.dart';
import '../../models/stock_movement.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/stock_movement_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../utils/currency_format.dart';
import '../../widgets/common/app_scaffold.dart';

// Combines all products with their current inventory quantity.
// Products with no inventory record show as 0 stock.
// Uses public providers so external screens can invalidate after invoice saves.
final inventoryViewProvider =
    FutureProvider<List<({Product product, InventoryItem? stock})>>((ref) async {
  final products      = await ref.watch(productsListProvider.future);
  final inventoryItems = await ref.watch(inventoryListProvider.future);
  final stockByProductId = {for (final i in inventoryItems) i.productId: i};
  return products
      .map((p) => (product: p, stock: stockByProductId[p.id]))
      .toList();
});

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String? _selectedSupplierId;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewAsync      = ref.watch(inventoryViewProvider);
    final suppliersAsync = ref.watch(suppliersListProvider);
    final suppliers      = suppliersAsync.valueOrNull ?? [];

    return AppScaffold(
      title: 'Inventory',
      body: Column(
        children: [
          // ── Search + supplier filter ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search product…',
                prefixIcon: Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
            ),
          ),
          if (suppliers.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  const Text('Supplier:',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey)),
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
                      onChanged: (v) =>
                          setState(() => _selectedSupplierId = v),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),

          // ── Inventory list ─────────────────────────────────────────
          Expanded(
            child: viewAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (allRows) {
                final q = _searchQuery.toLowerCase();
                final rows = allRows.where((r) {
                  final matchesSupplier = _selectedSupplierId == null ||
                      r.product.supplierId == _selectedSupplierId;
                  final matchesSearch = q.isEmpty ||
                      r.product.name.toLowerCase().contains(q);
                  return matchesSupplier && matchesSearch;
                }).toList();

                if (rows.isEmpty) {
                  return const Center(
                      child: Text('No products found.'));
                }
                return ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final row     = rows[i];
                    final product = row.product;
                    final stock   = row.stock;
                    final qty     = stock?.quantityPieces ?? 0;
                    final boxes   = qty ~/ product.piecesPerBox;
                    final remainPieces = qty % product.piecesPerBox;
                    return ListTile(
                      leading: Icon(
                        Icons.inventory,
                        color: qty == 0 ? Colors.red : null,
                      ),
                      title: Text(product.name),
                      subtitle: qty == 0
                          ? const Text('No stock',
                              style: TextStyle(color: Colors.red))
                          : Text(
                              '$boxes box(es) + $remainPieces pcs'
                              ' = ${formatNumber(qty)} pcs total'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: Colors.green),
                            tooltip: 'Add stock',
                            onPressed: () => _showAdjustDialog(
                                ctx, product, qty,
                                isAdd: true),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            tooltip: 'Remove stock',
                            onPressed: qty == 0
                                ? null
                                : () => _showAdjustDialog(
                                    ctx, product, qty,
                                    isAdd: false),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAdjustDialog(
    BuildContext context,
    Product product,
    int currentQty, {
    required bool isAdd,
  }) async {
    final qtyCtrl     = TextEditingController();
    final invCtrl     = TextEditingController();
    final commentCtrl = TextEditingController();
    String unitType   = isAdd ? 'box' : 'piece';
    DateTime refDate  = DateTime.now();

    // Fetch withdrawal price for price-per-box display
    final price = isAdd
        ? await ref.read(productRepositoryProvider).getCurrentPrice(product.id)
        : null;
    final pricePerBox = price != null
        ? price.withdrawalPrice * product.piecesPerBox
        : null;

    if (!mounted) return;
    await showDialog(
      context: this.context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(isAdd ? 'Add Stock' : 'Remove Stock'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                Text('Current: ${formatNumber(currentQty)} pcs',
                    style: const TextStyle(color: Colors.grey)),
                if (pricePerBox != null)
                  Text(
                    'Price/box: ${formatCurrency(pricePerBox)}',
                    style: TextStyle(
                        color: Colors.blue.shade700, fontSize: 13),
                  ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'piece', label: Text('Pieces')),
                    ButtonSegment(value: 'box', label: Text('Boxes')),
                  ],
                  selected: {unitType},
                  onSelectionChanged: (s) =>
                      setState(() => unitType = s.first),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: qtyCtrl,
                  decoration: InputDecoration(
                    labelText:
                        'Quantity (${unitType == 'box' ? 'boxes' : 'pcs'})',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                ),
                if (isAdd && price != null) ...[
                  const SizedBox(height: 4),
                  Builder(builder: (_) {
                    final qty = int.tryParse(qtyCtrl.text) ?? 0;
                    final unitPrice = unitType == 'box'
                        ? pricePerBox!
                        : price.withdrawalPrice;
                    final total = qty * unitPrice;
                    return Text(
                      'Total: ${formatCurrency(total)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    );
                  }),
                ],
                if (isAdd) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 4),
                  const Text('Reference',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: refDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => refDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        suffixIcon:
                            Icon(Icons.calendar_today, size: 18),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      child: Text(
                        '${refDate.year}-'
                        '${refDate.month.toString().padLeft(2, '0')}-'
                        '${refDate.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: invCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Invoice / Reference No.',
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Comments',
                      isDense: true,
                    ),
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final qty = int.tryParse(qtyCtrl.text) ?? 0;
                if (qty <= 0) return;
                final pieces =
                    unitType == 'box' ? qty * product.piecesPerBox : qty;
                final delta = isAdd ? pieces : -pieces;
                await ref
                    .read(inventoryRepositoryProvider)
                    .adjust(productId: product.id, deltaPieces: delta);
                await ref
                    .read(stockMovementRepositoryProvider)
                    .save(StockMovement(
                      id: const Uuid().v4(),
                      productId: product.id,
                      movementType: isAdd ? 'in' : 'out',
                      quantityPieces: pieces,
                      referenceDate: refDate,
                      invoiceNumber: invCtrl.text.trim().isEmpty
                          ? null
                          : invCtrl.text.trim(),
                      comments: commentCtrl.text.trim().isEmpty
                          ? null
                          : commentCtrl.text.trim(),
                      createdAt: DateTime.now(),
                    ));
                if (ctx.mounted) Navigator.pop(ctx);
                ref.invalidate(inventoryListProvider);
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
