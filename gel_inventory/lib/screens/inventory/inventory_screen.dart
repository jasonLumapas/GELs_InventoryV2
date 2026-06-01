import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/inventory_item.dart';
import '../../models/product.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/product_repository.dart';
import '../../utils/currency_format.dart';
import '../../widgets/common/app_scaffold.dart';

// Combines all products with their current inventory quantity.
// Products with no inventory record show as 0 stock.
// Uses public providers so external screens can invalidate after invoice saves.
final inventoryViewProvider =
    FutureProvider<List<({Product product, InventoryItem? stock})>>((ref) async {
  final products = await ref.watch(productsListProvider.future);
  final inventoryItems = await ref.watch(inventoryListProvider.future);
  final stockByProductId = {for (final i in inventoryItems) i.productId: i};
  return products
      .map((p) => (product: p, stock: stockByProductId[p.id]))
      .toList();
});

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewAsync = ref.watch(inventoryViewProvider);

    return AppScaffold(
      title: 'Inventory',
      body: viewAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (rows) {
          if (rows.isEmpty) {
            return const Center(
                child: Text('No products yet. Add products first.'));
          }
          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final row = rows[i];
              final product = row.product;
              final stock = row.stock;
              final qty = stock?.quantityPieces ?? 0;
              final boxes = qty ~/ product.piecesPerBox;
              final remainPieces = qty % product.piecesPerBox;
              return ListTile(
                leading: Icon(
                  Icons.inventory,
                  color: qty == 0 ? Colors.red : null,
                ),
                title: Text(product.name),
                subtitle: qty == 0
                    ? const Text('No stock', style: TextStyle(color: Colors.red))
                    : Text(
                        '$boxes box(es) + $remainPieces pcs'
                        ' = ${formatNumber(qty)} pcs total'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      tooltip: 'Add stock',
                      onPressed: () =>
                          _showAdjustDialog(ctx, ref, product, qty, isAdd: true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      tooltip: 'Remove stock',
                      onPressed: qty == 0
                          ? null
                          : () => _showAdjustDialog(ctx, ref, product, qty,
                              isAdd: false),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAdjustDialog(
    BuildContext context,
    WidgetRef ref,
    Product product,
    int currentQty, {
    required bool isAdd,
  }) async {
    final ctrl = TextEditingController();
    String unitType = 'piece';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(isAdd ? 'Add Stock' : 'Remove Stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Current: ${formatNumber(currentQty)} pcs',
                  style: const TextStyle(color: Colors.grey)),
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
                controller: ctrl,
                decoration: InputDecoration(
                  labelText:
                      'Quantity (${unitType == 'box' ? 'boxes' : 'pcs'})',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final qty = int.tryParse(ctrl.text) ?? 0;
                if (qty <= 0) return;
                final pieces =
                    unitType == 'box' ? qty * product.piecesPerBox : qty;
                final delta = isAdd ? pieces : -pieces;
                await ref
                    .read(inventoryRepositoryProvider)
                    .adjust(productId: product.id, deltaPieces: delta);
                if (ctx.mounted) Navigator.pop(ctx);
                ref.invalidate(inventoryViewProvider);
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
