import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/client_repository.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/confirm_dialog.dart';

class ClientListScreen extends ConsumerStatefulWidget {
  const ClientListScreen({super.key});

  @override
  ConsumerState<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends ConsumerState<ClientListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        data: (clients) {
          final filtered = _query.isEmpty
              ? clients
              : clients.where((c) {
                  final q = _query.toLowerCase();
                  return c.name.toLowerCase().contains(q) ||
                      (c.contact?.toLowerCase().contains(q) ?? false) ||
                      (c.address?.toLowerCase().contains(q) ?? false);
                }).toList();

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search clients / stores…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _query = v.trim()),
                ),
              ),
              if (filtered.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(_query.isEmpty
                        ? 'No clients yet.'
                        : 'No results for "$_query".'),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final c = filtered[i];
                      final subtitleParts = [
                        if (c.contact != null && c.contact!.isNotEmpty)
                          c.contact!,
                        if (c.address != null && c.address!.isNotEmpty)
                          c.address!,
                      ];
                      return ListTile(
                        leading: const Icon(Icons.store),
                        title: Text(c.name),
                        subtitle: subtitleParts.isEmpty
                            ? null
                            : Text(subtitleParts.join('  •  ')),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => context.go('/clients/${c.id}'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
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
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border(
                      top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Text(
                  _query.isEmpty
                      ? '${clients.length} client(s)'
                      : '${filtered.length} of ${clients.length} client(s)',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
