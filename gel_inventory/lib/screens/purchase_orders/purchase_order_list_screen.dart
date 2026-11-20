import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../repositories/purchase_order_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../utils/currency_format.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/confirm_dialog.dart';

enum _FilterType { day, week, month }

class PurchaseOrderListScreen extends ConsumerStatefulWidget {
  const PurchaseOrderListScreen({super.key});

  @override
  ConsumerState<PurchaseOrderListScreen> createState() =>
      _PurchaseOrderListScreenState();
}

class _PurchaseOrderListScreenState
    extends ConsumerState<PurchaseOrderListScreen> {
  _FilterType _filter = _FilterType.day;
  DateTime _anchor = DateTime.now();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Date range helpers ───────────────────────────────────────────────────

  DateTime get _startDate {
    switch (_filter) {
      case _FilterType.day:
        return DateTime(_anchor.year, _anchor.month, _anchor.day);
      case _FilterType.week:
        final monday = _anchor.subtract(Duration(days: _anchor.weekday - 1));
        return DateTime(monday.year, monday.month, monday.day);
      case _FilterType.month:
        return DateTime(_anchor.year, _anchor.month);
    }
  }

  DateTime get _endDate {
    switch (_filter) {
      case _FilterType.day:
        return _startDate.add(const Duration(days: 1));
      case _FilterType.week:
        return _startDate.add(const Duration(days: 7));
      case _FilterType.month:
        return DateTime(_anchor.year, _anchor.month + 1);
    }
  }

  String get _periodLabel {
    final s = _startDate;
    switch (_filter) {
      case _FilterType.day:
        return DateFormat('EEE, MMM d, y').format(s);
      case _FilterType.week:
        final e = _endDate.subtract(const Duration(days: 1));
        final sameMonth = s.month == e.month && s.year == e.year;
        return sameMonth
            ? '${DateFormat('MMM d').format(s)} – ${DateFormat('d, y').format(e)}'
            : '${DateFormat('MMM d').format(s)} – ${DateFormat('MMM d, y').format(e)}';
      case _FilterType.month:
        return DateFormat('MMMM y').format(s);
    }
  }

  void _prev() => setState(() {
        switch (_filter) {
          case _FilterType.day:
            _anchor = _anchor.subtract(const Duration(days: 1));
          case _FilterType.week:
            _anchor = _anchor.subtract(const Duration(days: 7));
          case _FilterType.month:
            _anchor = DateTime(_anchor.year, _anchor.month - 1, _anchor.day);
        }
      });

  void _next() => setState(() {
        switch (_filter) {
          case _FilterType.day:
            _anchor = _anchor.add(const Duration(days: 1));
          case _FilterType.week:
            _anchor = _anchor.add(const Duration(days: 7));
          case _FilterType.month:
            _anchor = DateTime(_anchor.year, _anchor.month + 1, _anchor.day);
        }
      });

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _anchor,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _anchor = picked);
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final ordersAsync =
        ref.watch(filteredPurchaseOrdersProvider((_startDate, _endDate)));
    final suppliersAsync = ref.watch(suppliersListProvider);
    final draftsAsync = ref.watch(draftPurchaseOrdersProvider);
    final dateFmt = DateFormat('MMM dd, yyyy');

    return AppScaffold(
      title: 'Purchase Orders',
      actions: [
        FilledButton.icon(
          icon: const Icon(Icons.add, size: 18),
          label: const Text('New Purchase Order'),
          onPressed: () => context.go('/purchase-orders/new'),
        ),
        const SizedBox(width: 8),
      ],
      body: Column(
        children: [
          // ── Draft purchase orders banner ─────────────────────────────────
          draftsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (drafts) {
              if (drafts.isEmpty) return const SizedBox.shrink();
              final suppliersMap = {
                for (final s in suppliersAsync.valueOrNull ?? []) s.id: s
              };
              return Container(
                width: double.infinity,
                color: Colors.amber.shade100,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${drafts.length} unfinished purchase order(s)',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    ...drafts.map((d) {
                      final supplier = suppliersMap[d.supplierId];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.edit_note, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${supplier?.name ?? 'Unknown supplier'}'
                                '  •  ${dateFmt.format(d.orderDate)}'
                                '  •  ${formatCurrency(d.totalAmount)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go(
                                  '/purchase-orders/new?draft=${d.id}'),
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
                                      'Discard this unfinished purchase order? This cannot be undone.',
                                  confirmLabel: 'Discard',
                                );
                                if (ok) {
                                  await ref
                                      .read(purchaseOrderRepositoryProvider)
                                      .discardDraft(d.id);
                                  ref.invalidate(draftPurchaseOrdersProvider);
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

          // ── Filter bar ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Row(
              children: [
                SegmentedButton<_FilterType>(
                  segments: const [
                    ButtonSegment(value: _FilterType.day, label: Text('Day')),
                    ButtonSegment(value: _FilterType.week, label: Text('Week')),
                    ButtonSegment(
                        value: _FilterType.month, label: Text('Month')),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (s) =>
                      setState(() => _filter = s.first),
                  style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _prev,
                        visualDensity: VisualDensity.compact,
                      ),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Text(
                          _periodLabel,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _next,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      setState(() => _anchor = DateTime.now()),
                  style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact),
                  child: const Text('Today'),
                ),
              ],
            ),
          ),

          // ── Search bar ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by supplier, reference or date…',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                border: const OutlineInputBorder(),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() {
                          _searchCtrl.clear();
                          _searchQuery = '';
                        }),
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
            ),
          ),

          const Divider(height: 1),

          // ── List ───────────────────────────────────────────────────────
          Expanded(
            child: ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (allOrders) {
                final suppliersMap = {
                  for (final s in suppliersAsync.valueOrNull ?? []) s.id: s
                };

                final orders = _searchQuery.isEmpty
                    ? allOrders
                    : () {
                        final q = _searchQuery.toLowerCase();
                        return allOrders.where((po) {
                          final supplierName =
                              (suppliersMap[po.supplierId]?.name ?? '')
                                  .toLowerCase();
                          final ref = (po.referenceNumber ?? '').toLowerCase();
                          final dateStr =
                              dateFmt.format(po.orderDate).toLowerCase();
                          return supplierName.contains(q) ||
                              ref.contains(q) ||
                              dateStr.contains(q);
                        }).toList();
                      }();

                if (orders.isEmpty) {
                  return Center(
                    child: Text(_searchQuery.isEmpty
                        ? 'No purchase orders for $_periodLabel.'
                        : 'No purchase orders match "$_searchQuery".'),
                  );
                }

                final activeOrders =
                    orders.where((po) => po.status != 'cancelled');
                final periodTotal =
                    activeOrders.fold(0.0, (s, po) => s + po.totalAmount);

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: orders.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final po = orders[i];
                          final supplier = suppliersMap[po.supplierId];
                          final cancelled = po.status == 'cancelled';
                          return ListTile(
                            leading: const Icon(Icons.shopping_cart),
                            title: Text(
                              po.displayNumber,
                              style: cancelled
                                  ? const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey)
                                  : null,
                            ),
                            subtitle: Text(
                              '${supplier?.name ?? po.supplierId}'
                              '  •  ${dateFmt.format(po.orderDate)}'
                              '${cancelled ? '  •  CANCELLED' : ''}',
                              style: cancelled
                                  ? const TextStyle(color: Colors.grey)
                                  : null,
                            ),
                            trailing: Text(
                              formatCurrency(po.totalAmount),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                decoration: cancelled
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: cancelled ? Colors.grey : null,
                              ),
                            ),
                            onTap: () async {
                              await context.push('/purchase-orders/${po.id}');
                              ref.invalidate(filteredPurchaseOrdersProvider);
                            },
                          );
                        },
                      ),
                    ),

                    // Footer: grand total
                    Container(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${orders.length} order(s)',
                              style: const TextStyle(color: Colors.grey)),
                          const Spacer(),
                          Text(
                            'Grand Total: ${formatCurrency(periodTotal)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
