import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/confirm_dialog.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsListProvider);
    final suppliersMapAsync = ref.watch(suppliersListProvider);

    return AppScaffold(
      title: 'Products',
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/products/new'),
        child: const Icon(Icons.add),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (products) {
          final suppliers = suppliersMapAsync.valueOrNull ?? [];
          final suppliersMap = {for (final s in suppliers) s.id: s};
          return products.isEmpty
              ? const Center(child: Text('No products yet.'))
              : ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final p = products[i];
                    final supplier = suppliersMap[p.supplierId];
                    return ListTile(
                      leading: const Icon(Icons.inventory_2),
                      title: Text(p.name),
                      subtitle: Text(
                          '${supplier?.name ?? 'Unknown'} • ${p.piecesPerBox} pcs/box'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => context.go('/products/${p.id}'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final ok = await showConfirmDialog(
                                ctx,
                                title: 'Delete Product',
                                message:
                                    'Delete "${p.name}"? This cannot be undone.',
                              );
                              if (ok) {
                                await ref
                                    .read(productRepositoryProvider)
                                    .deleteProduct(p.id);
                                ref.invalidate(productsListProvider);
                              }
                            },
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
}
