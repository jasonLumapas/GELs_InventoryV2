import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/bad_order.dart';
import '../../models/bad_order_item.dart';
import '../../models/client.dart';
import '../../models/product.dart';
import '../../repositories/bad_order_repository.dart';
import '../../repositories/client_repository.dart';
import '../../repositories/product_repository.dart';
import '../../utils/currency_format.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/confirm_dialog.dart';

class BadOrderListScreen extends ConsumerWidget {
  const BadOrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync    = ref.watch(badOrdersListProvider);
    final clientsAsync = ref.watch(clientsListProvider);
    final dateFmt      = DateFormat('MMM dd, yyyy');

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
                onTap: () => _showDetail(context, ref, o, client),
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

// ── Detail data ───────────────────────────────────────────────────────────────

class _DetailData {
  final List<BadOrderItem> items;
  final Map<String, Product> productsById;
  final Map<String, double> amounts; // item.id → selling amount
  final double grandTotal;

  const _DetailData({
    required this.items,
    required this.productsById,
    required this.amounts,
    required this.grandTotal,
  });
}

Future<_DetailData> _loadDetailData(WidgetRef ref, BadOrder order) async {
  final items = await ref.read(badOrderRepositoryProvider).getItems(order.id);
  final products = await ref.read(productRepositoryProvider).getAll();
  final productsById = <String, Product>{for (final p in products) p.id: p};

  final amounts = <String, double>{};
  double total = 0;

  for (final item in items) {
    final product = productsById[item.productId];
    if (product == null) continue;
    final pieces = item.unitType == 'box'
        ? item.quantity * product.piecesPerBox
        : item.quantity;
    final price =
        await ref.read(productRepositoryProvider).getCurrentPrice(item.productId);
    final amount = pieces * (price?.sellingPrice ?? 0.0);
    amounts[item.id] = amount;
    total += amount;
  }

  return _DetailData(
    items: items,
    productsById: productsById,
    amounts: amounts,
    grandTotal: total,
  );
}

// ── Detail sheet ──────────────────────────────────────────────────────────────

void _showDetail(
  BuildContext context,
  WidgetRef ref,
  BadOrder order,
  Client? client,
) {
  final dateFmt = DateFormat('MMM dd, yyyy');
  // Create the future once so FutureBuilder won't re-fire on rebuilds.
  final detailFuture = _loadDetailData(ref, order);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.85,
      minChildSize: 0.3,
      expand: false,
      builder: (ctx, scrollCtrl) => FutureBuilder<_DetailData>(
        future: detailFuture,
        builder: (ctx, snap) {
          final data = snap.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Icon(
                      order.isReturn
                          ? Icons.undo
                          : Icons.remove_shopping_cart,
                      color: order.isReturn ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.typeLabel,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // Meta info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _metaRow('Client', client?.name ?? order.clientId),
                    _metaRow('Date', dateFmt.format(order.date)),
                    if (order.notes != null && order.notes!.isNotEmpty)
                      _metaRow('Notes', order.notes!),
                  ],
                ),
              ),

              const Divider(height: 20),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Items',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 4),

              // Items list or loading/error
              if (snap.connectionState == ConnectionState.waiting)
                const Expanded(
                    child: Center(child: CircularProgressIndicator()))
              else if (snap.hasError)
                Expanded(
                    child: Center(child: Text('Error: ${snap.error}')))
              else if (data == null || data.items.isEmpty)
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No items.'),
                  ),
                )
              else ...[
                Expanded(
                  child: ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: data.items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final item = data.items[i];
                      final product = data.productsById[item.productId];
                      final qtyLabel = item.unitType == 'box'
                          ? '${item.quantity} box(es)'
                          : '${item.quantity} pcs';
                      final amount = data.amounts[item.id] ?? 0.0;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(product?.name ?? item.productId),
                        subtitle: Text(qtyLabel,
                            style: const TextStyle(fontSize: 12)),
                        trailing: Text(
                          formatCurrency(amount),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                    },
                  ),
                ),

                // Grand total footer
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Grand Total: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        formatCurrency(data.grandTotal),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    ),
  );
}

Widget _metaRow(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text('$label:',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
