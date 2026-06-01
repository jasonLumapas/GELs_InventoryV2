import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/supplier_repository.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/confirm_dialog.dart';

class SupplierListScreen extends ConsumerWidget {
  const SupplierListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(suppliersListProvider);

    return AppScaffold(
      title: 'Suppliers',
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/suppliers/new'),
        child: const Icon(Icons.add),
      ),
      body: suppliersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (suppliers) => suppliers.isEmpty
            ? const Center(child: Text('No suppliers yet.'))
            : ListView.separated(
                itemCount: suppliers.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final s = suppliers[i];
                  return ListTile(
                    leading: const Icon(Icons.local_shipping),
                    title: Text(s.name),
                    subtitle: s.contact != null ? Text(s.contact!) : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => context.go('/suppliers/${s.id}'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final ok = await showConfirmDialog(
                              ctx,
                              title: 'Delete Supplier',
                              message:
                                  'Delete "${s.name}"? This cannot be undone.',
                            );
                            if (ok) {
                              await ref
                                  .read(supplierRepositoryProvider)
                                  .delete(s.id);
                              ref.invalidate(suppliersListProvider);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
