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
import '../../repositories/inventory_repository.dart';
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
    final draftsAsync  = ref.watch(badOrderDraftsProvider);
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
      body: Column(
        children: [
          // ── Draft bad orders / returns banner ──────────────────────────
          draftsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (drafts) {
              if (drafts.isEmpty) return const SizedBox.shrink();
              final clientsMap = {
                for (final c in clientsAsync.valueOrNull ?? []) c.id: c
              };
              return Container(
                width: double.infinity,
                color: Colors.amber.shade100,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${drafts.length} unfinished bad order(s)/return(s)',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    ...drafts.map((d) {
                      final client = d.noClient
                          ? null
                          : clientsMap[d.clientId];
                      final typeLabel =
                          d.type == 'return' ? 'Return' : 'Bad Order';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.edit_note, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '$typeLabel — '
                                '${d.noClient ? "No Client Specified" : client?.name ?? "Unknown client"}'
                                '  •  ${dateFmt.format(d.date)}'
                                '  •  ${d.items.length} item(s)',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context
                                  .go('/bad-orders/new?draft=${d.id}'),
                              child: const Text('Resume'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red, size: 20),
                              tooltip: 'Discard draft',
                              onPressed: () async {
                                final ok = await showConfirmDialog(
                                  context,
                                  title: 'Discard Draft',
                                  message:
                                      'Discard this unfinished $typeLabel? This cannot be undone.',
                                  confirmLabel: 'Discard',
                                );
                                if (ok) {
                                  await ref
                                      .read(badOrderRepositoryProvider)
                                      .discardDraft(d.id);
                                  ref.invalidate(badOrderDraftsProvider);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: listAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (orders) {
                final clientsMap = {
                  for (final c in clientsAsync.valueOrNull ?? []) c.id: c
                };
                if (orders.isEmpty) {
                  return const Center(
                      child: Text('No bad orders or returns yet.'));
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
                      title:
                          Text('${o.typeLabel} — ${client?.name ?? o.clientId}'),
                      subtitle: Text(
                          '${dateFmt.format(o.date)}${o.notes != null ? ' • ${o.notes}' : ''}'),
                      onTap: () => _showDetail(context, ref, o, client),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        onPressed: () async {
                          final ok = await showConfirmDialog(ctx,
                              title: 'Delete',
                              message:
                                  'Delete this ${o.typeLabel}? This cannot be undone.',
                              confirmLabel: 'Delete');
                          if (ok) {
                            await ref
                                .read(badOrderRepositoryProvider)
                                .delete(o.id);
                            ref.invalidate(badOrdersListProvider);
                          }
                        },
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

// ── Detail sheet ──────────────────────────────────────────────────────────────

void _showDetail(
  BuildContext context,
  WidgetRef ref,
  BadOrder order,
  Client? client,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _DetailSheet(order: order, client: client),
  );
}

class _DetailSheet extends ConsumerStatefulWidget {
  final BadOrder order;
  final Client? client;

  const _DetailSheet({required this.order, required this.client});

  @override
  ConsumerState<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends ConsumerState<_DetailSheet> {
  bool _loading = true;
  List<BadOrderItem> _items = [];
  Map<String, Product> _productsById = {};
  Map<String, double> _amounts = {};
  double _grandTotal = 0;
  Map<String, int> _inventoryQty = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final itemsFuture    = ref.read(badOrderRepositoryProvider).getItems(widget.order.id);
    final productsFuture = ref.read(productRepositoryProvider).getAll();
    final pricesFuture   = ref.read(productRepositoryProvider).getAllCurrentPrices();
    final inventoryFuture = ref.read(inventoryRepositoryProvider).getAll();

    final results = await Future.wait([itemsFuture, productsFuture, pricesFuture, inventoryFuture]);
    final items      = results[0] as List<BadOrderItem>;
    final products   = results[1] as List<Product>;
    final prices     = results[2] as Map<String, double>;
    final inventory  = results[3] as List;

    final productsById = <String, Product>{for (final p in products) p.id: p};
    final inventoryQty = <String, int>{
      for (final i in inventory) i.productId as String: i.quantityPieces as int
    };

    final amounts  = <String, double>{};
    double total   = 0;
    for (final item in items) {
      final product = productsById[item.productId];
      if (product == null) continue;
      final pieces = item.unitType == 'box'
          ? item.quantity * product.piecesPerBox
          : item.quantity;
      final amount = pieces * (prices[item.productId] ?? 0.0);
      amounts[item.id] = amount;
      total += amount;
    }

    if (!mounted) return;
    setState(() {
      _loading      = false;
      _items        = items;
      _productsById = productsById;
      _amounts      = amounts;
      _grandTotal   = total;
      _inventoryQty = inventoryQty;
    });
  }

  Future<void> _editItem(BadOrderItem item) async {
    final product      = _productsById[item.productId];
    final piecesPerBox = product?.piecesPerBox ?? 1;
    final oldPieces    = item.unitType == 'box'
        ? item.quantity * piecesPerBox
        : item.quantity;

    // For bad orders the old deduction is already in the DB, so effective
    // available = current stock + old pieces back − pieces held by other
    // lines for this same product.
    // Returns have no stock constraint (they add stock back).
    int? maxPieces;
    if (!widget.order.isReturn) {
      int otherCommitted = 0;
      for (final other in _items) {
        if (other.id == item.id || other.productId != item.productId) continue;
        final ppb = _productsById[other.productId]?.piecesPerBox ?? 1;
        otherCommitted +=
            other.unitType == 'box' ? other.quantity * ppb : other.quantity;
      }
      final stock = _inventoryQty[item.productId] ?? 0;
      final raw   = stock + oldPieces - otherCommitted;
      maxPieces   = raw < 0 ? 0 : raw;
    }

    String unitType  = item.unitType;
    final qtyCtrl    = TextEditingController(text: item.quantity.toString());

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) {
          final newQty    = int.tryParse(qtyCtrl.text.trim()) ?? 0;
          final newPieces = unitType == 'box' ? newQty * piecesPerBox : newQty;
          final isOver    = maxPieces != null && newPieces > maxPieces;

          String availLabel = '';
          if (maxPieces != null) {
            final availBoxes = maxPieces ~/ piecesPerBox;
            final availPcs   = maxPieces % piecesPerBox;
            availLabel = availBoxes > 0
                ? '$availBoxes box(es)${availPcs > 0 ? ' + $availPcs pcs' : ''}'
                : '$availPcs pcs';
          }

          return AlertDialog(
            title: Text('Edit — ${product?.name ?? item.productId}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (maxPieces != null) ...[
                  Text(
                    'Available: $availLabel',
                    style: TextStyle(
                      fontSize: 13,
                      color: isOver ? Colors.red : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                const Text('Unit type'),
                const SizedBox(height: 6),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'box', label: Text('Box')),
                    ButtonSegment(value: 'piece', label: Text('Piece')),
                  ],
                  selected: {unitType},
                  onSelectionChanged: (s) =>
                      setDlg(() => unitType = s.first),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setDlg(() {}),
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    errorText: isOver ? 'Exceeds available stock' : null,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: isOver ? null : () => Navigator.pop(ctx, true),
                  child: const Text('Save')),
            ],
          );
        },
      ),
    );

    if (confirmed != true || !mounted) return;
    final newQty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
    if (newQty <= 0) return;

    await ref.read(badOrderRepositoryProvider).updateItem(
      order: widget.order,
      oldItem: item,
      newUnitType: unitType,
      newQuantity: newQty,
      piecesPerBox: product?.piecesPerBox ?? 1,
    );
    ref.invalidate(badOrdersListProvider);
    ref.invalidate(inventoryListProvider);
    await _loadData();
  }

  Future<void> _deleteItem(BadOrderItem item) async {
    final product = _productsById[item.productId];
    final ok = await showConfirmDialog(
      context,
      title: 'Delete Item',
      message: 'Remove "${product?.name ?? item.productId}" from this '
          '${widget.order.typeLabel}? The inventory will be adjusted.',
      confirmLabel: 'Delete',
    );
    if (!ok || !mounted) return;

    await ref.read(badOrderRepositoryProvider).deleteItem(
      order: widget.order,
      item: item,
      piecesPerBox: product?.piecesPerBox ?? 1,
    );
    ref.invalidate(badOrdersListProvider);
    ref.invalidate(inventoryListProvider);

    await _loadData();

    if (mounted && _items.isEmpty) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM dd, yyyy');

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.85,
      minChildSize: 0.3,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
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

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Icon(
                  widget.order.isReturn
                      ? Icons.undo
                      : Icons.remove_shopping_cart,
                  color:
                      widget.order.isReturn ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.order.typeLabel,
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
                _metaRow('Client',
                    widget.client?.name ?? widget.order.clientId),
                _metaRow('Date', dateFmt.format(widget.order.date)),
                if (widget.order.notes != null &&
                    widget.order.notes!.isNotEmpty)
                  _metaRow('Notes', widget.order.notes!),
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

          // Body
          if (_loading)
            const Expanded(
                child: Center(child: CircularProgressIndicator()))
          else if (_items.isEmpty)
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
                itemCount: _items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final item    = _items[i];
                  final product = _productsById[item.productId];
                  final ppb     = product?.piecesPerBox ?? 1;
                  String qtyLabel;
                  if (item.unitType == 'box') {
                    qtyLabel = '${item.quantity} box(es)';
                  } else {
                    final boxes = ppb > 0 ? item.quantity ~/ ppb : 0;
                    final pcs   = ppb > 0 ? item.quantity % ppb : item.quantity;
                    qtyLabel =
                        boxes > 0 ? '$boxes box(es) + $pcs pcs' : '$pcs pcs';
                  }
                  final amount = _amounts[item.id] ?? 0.0;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(product?.name ?? item.productId),
                    subtitle: Text(qtyLabel,
                        style: const TextStyle(fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatCurrency(amount),
                          style: const TextStyle(
                              fontWeight: FontWeight.w500),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              size: 20),
                          tooltip: 'Edit item',
                          onPressed: () => _editItem(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red, size: 20),
                          tooltip: 'Delete item',
                          onPressed: () => _deleteItem(item),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Grand total footer
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                border:
                    Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Grand Total: ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(
                    formatCurrency(_grandTotal),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
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
