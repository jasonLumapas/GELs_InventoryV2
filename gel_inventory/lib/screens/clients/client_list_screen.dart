import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/client_repository.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/confirm_dialog.dart';

class ClientListScreen extends ConsumerWidget {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientsListProvider);

    return AppScaffold(
      title: 'Clients / Stores',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Add client',
          onPressed: () => context.go('/clients/new'),
        ),
      ],
      body: clientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (clients) => clients.isEmpty
            ? const Center(child: Text('No clients yet.'))
            : ListView.separated(
                itemCount: clients.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final c = clients[i];
                  return ListTile(
                    leading: const Icon(Icons.store),
                    title: Text(c.name),
                    subtitle: c.address != null ? Text(c.address!) : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => context.go('/clients/${c.id}'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final ok = await showConfirmDialog(
                              ctx,
                              title: 'Delete Client',
                              message:
                                  'Delete "${c.name}"? This cannot be undone.',
                            );
                            if (ok) {
                              await ref
                                  .read(clientRepositoryProvider)
                                  .delete(c.id);
                              ref.invalidate(clientsListProvider);
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
