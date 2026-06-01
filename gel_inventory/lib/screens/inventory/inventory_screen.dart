import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/inventory_item.dart';
import '../../models/product.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/product_repository.dart';
import '../../utils/currency_format.dart';
import '../../widgets/common/app_scaffold.dart';

final _inventoryProvider =
    FutureProvider<List<InventoryItem>>((ref) async {
  return ref.watch(inventoryRepositoryProvider).getAll();
});

final _productsMapProvider =
    FutureProvider<Map<String, Product>>((ref) async {
  final all = await ref.watch(productRepositoryProvider).getAll();
  return {for (final p in all) p.id: p};
});

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(_inventoryProvider);
    final productsMapAsync = ref.watch(_productsMapProvider);

    return AppScaffold(
      title: 'Inventory',
      body: inventoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          final productsMap = productsMapAsync.valueOrNull ?? {};
          if (items.isEmpty) {
            return const Center(
                child: Text('No inventory records. Add products first.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final item = items[i];
              final product = productsMap[item.productId];
              final piecesPerBox = product?.piecesPerBox ?? 1;
              final boxes = item.quantityPieces ~/ piecesPerBox;
              final remainPieces = item.quantityPieces % piecesPerBox;
              return ListTile(
                leading: const Icon(Icons.inventory),
                title: Text(product?.name ?? item.productId),
                subtitle: Text(
                    '$boxes box(es) + $remainPieces pcs = ${formatNumber(item.quantityPieces)} pcs total'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      tooltip: 'Add stock',
                      onPressed: () => _showAdjustDialog(
                          ctx, ref, item, productsMap, isAdd: true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      tooltip: 'Remove stock',
                      onPressed: () => _showAdjustDialog(
                          ctx, ref, item, productsMap, isAdd: false),
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
    InventoryItem item,
    Map<String, Product> productsMap, {
    required bool isAdd,
  }) async {
    final product = productsMap[item.productId];
    final ctrl = TextEditingController();
    String unitType = 'piece';
    final piecesPerBox = product?.piecesPerBox ?? 1;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(isAdd ? 'Add Stock' : 'Remove Stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(product?.name ?? item.productId,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    unitType == 'box' ? qty * piecesPerBox : qty;
                final delta = isAdd ? pieces : -pieces;
                await ref
                    .read(inventoryRepositoryProvider)
                    .adjust(productId: item.productId, deltaPieces: delta);
                if (ctx.mounted) Navigator.pop(ctx);
                ref.invalidate(_inventoryProvider);
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}

