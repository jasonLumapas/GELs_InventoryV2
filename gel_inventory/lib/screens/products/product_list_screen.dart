import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/confirm_dialog.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
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
    final productsAsync  = ref.watch(productsListProvider);
    final suppliersAsync = ref.watch(suppliersListProvider);
    final suppliers      = suppliersAsync.valueOrNull ?? [];
    final suppliersMap   = {for (final s in suppliers) s.id: s};

    return AppScaffold(
      title: 'Products',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Add product',
          onPressed: () => context.go('/products/new'),
        ),
      ],
      body: Column(
        children: [
          // ── Search ──────────────────────────────────────────────────
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

          // ── Supplier filter ──────────────────────────────────────────
          if (suppliers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
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
                      onChanged: (v) =>
                          setState(() => _selectedSupplierId = v),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),

          // ── Product list ─────────────────────────────────────────────
          Expanded(
            child: productsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (allProducts) {
                final q = _searchQuery.toLowerCase();
                final products = allProducts.where((p) {
                  final matchesSupplier = _selectedSupplierId == null ||
                      p.supplierId == _selectedSupplierId;
                  final matchesSearch = q.isEmpty ||
                      p.name.toLowerCase().contains(q) ||
                      (p.productCode?.toLowerCase().contains(q) ?? false);
                  return matchesSupplier && matchesSearch;
                }).toList()
                  ..sort((a, b) =>
                      a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                if (products.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }
                return ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final p = products[i];
                    final supplier = suppliersMap[p.supplierId];
                    return ListTile(
                      leading: const Icon(Icons.inventory_2),
                      title: Text(p.productCode != null && p.productCode!.isNotEmpty
                          ? '${p.name} (${p.productCode})'
                          : p.name),
                      subtitle: Text(
                          '${supplier?.name ?? 'Unknown'} • ${p.piecesPerBox} pcs/box'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                context.go('/products/${p.id}'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
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
          ),
        ],
      ),
    );
  }
}
