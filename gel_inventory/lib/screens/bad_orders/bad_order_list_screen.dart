import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../repositories/bad_order_repository.dart';
import '../../repositories/client_repository.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/confirm_dialog.dart';

class BadOrderListScreen extends ConsumerWidget {
  const BadOrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(badOrdersListProvider);
    final clientsAsync = ref.watch(clientsListProvider);
    final dateFmt = DateFormat('MMM dd, yyyy');

    return AppScaffold(
      title: 'Bad Orders & Returns',
      actions: [
        FilledButton.icon(
          icon: const Icon(Icons.add, size: 18),
          label: const Text('New'),
          onPressed: () => context.go('/bad-orders/new'),
        ),
        const SizedBox(width: 8),
      ],
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (orders) {
          final clientsMap = {
            for (final c in clientsAsync.valueOrNull ?? []) c.id: c
          };
          if (orders.isEmpty) {
            return const Center(child: Text('No bad orders or returns yet.'));
          }
          return ListView.separated(
            itemCount: orders.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final o = orders[i];
              final client = clientsMap[o.clientId];
              return ListTile(
                leading: Icon(
                  o.isReturn ? Icons.undo : Icons.remove_shopping_cart,
                  color: o.isReturn ? Colors.green : Colors.orange,
                ),
                title: Text('${o.typeLabel} — ${client?.name ?? o.clientId}'),
                subtitle: Text(
                    '${dateFmt.format(o.date)}${o.notes != null ? ' • ${o.notes}' : ''}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    final ok = await showConfirmDialog(ctx,
                        title: 'Delete',
                        message:
                            'Delete this ${o.typeLabel}? This cannot be undone.',
                        confirmLabel: 'Delete');
                    if (ok) {
                      await ref.read(badOrderRepositoryProvider).delete(o.id);
                      ref.invalidate(badOrdersListProvider);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
