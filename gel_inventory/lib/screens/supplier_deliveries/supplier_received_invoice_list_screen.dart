import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/supplier_received_invoice_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../utils/currency_format.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/confirm_dialog.dart';

enum _FilterType { day, week, month }

class SupplierReceivedInvoiceListScreen extends ConsumerStatefulWidget {
  const SupplierReceivedInvoiceListScreen({super.key});

  @override
  ConsumerState<SupplierReceivedInvoiceListScreen> createState() =>
      _SupplierReceivedInvoiceListScreenState();
}

class _SupplierReceivedInvoiceListScreenState
    extends ConsumerState<SupplierReceivedInvoiceListScreen> {
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
    final invoicesAsync =
        ref.watch(filteredSupplierReceivedInvoicesProvider((_startDate, _endDate)));
    final suppliersAsync = ref.watch(suppliersListProvider);
    final draftsAsync = ref.watch(draftSupplierReceivedInvoicesProvider);
    final dateFmt = DateFormat('MMM dd, yyyy');

    return AppScaffold(
      title: 'Supplier Deliveries',
      actions: [
        FilledButton.icon(
          icon: const Icon(Icons.add, size: 18),
          label: const Text('New Delivery'),
          onPressed: () => context.go('/supplier-deliveries/new'),
        ),
        const SizedBox(width: 8),
      ],
      body: Column(
        children: [
          // ── Draft deliveries banner ──────────────────────────────────────
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
                        '${drafts.length} unfinished delivery(ies)',
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
                                '  •  ${dateFmt.format(d.receivedDate)}'
                                '  •  ${formatCurrency(d.totalAmountSupplier)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go(
                                  '/supplier-deliveries/new?draft=${d.id}'),
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
                                      'Discard this unfinished delivery? This cannot be undone.',
                                  confirmLabel: 'Discard',
                                );
                                if (ok) {
                                  await ref
                                      .read(
                                          supplierReceivedInvoiceRepositoryProvider)
                                      .discardDraft(d.id);
                                  ref.invalidate(
                                      draftSupplierReceivedInvoicesProvider);
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
            child: invoicesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (allInvoices) {
                final suppliersMap = {
                  for (final s in suppliersAsync.valueOrNull ?? []) s.id: s
                };

                final invoices = _searchQuery.isEmpty
                    ? allInvoices
                    : () {
                        final q = _searchQuery.toLowerCase();
                        return allInvoices.where((inv) {
                          final supplierName =
                              (suppliersMap[inv.supplierId]?.name ?? '')
                                  .toLowerCase();
                          final ref = (inv.referenceNumber ?? '').toLowerCase();
                          final dateStr =
                              dateFmt.format(inv.receivedDate).toLowerCase();
                          return supplierName.contains(q) ||
                              ref.contains(q) ||
                              dateStr.contains(q);
                        }).toList();
                      }();

                if (invoices.isEmpty) {
                  return Center(
                    child: Text(_searchQuery.isEmpty
                        ? 'No deliveries for $_periodLabel.'
                        : 'No deliveries match "$_searchQuery".'),
                  );
                }

                final activeInvoices =
                    invoices.where((inv) => inv.status != 'cancelled');
                final periodSystemTotal = activeInvoices.fold(
                    0.0, (s, i) => s + i.totalAmountSystem);
                final periodSupplierTotal = activeInvoices.fold(
                    0.0, (s, i) => s + i.totalAmountSupplier);

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: invoices.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final inv = invoices[i];
                          final supplier = suppliersMap[inv.supplierId];
                          final cancelled = inv.status == 'cancelled';
                          return ListTile(
                            leading: const Icon(Icons.move_to_inbox),
                            title: Text(
                              inv.displayNumber,
                              style: cancelled
                                  ? const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey)
                                  : null,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${supplier?.name ?? inv.supplierId}'
                                  '  •  ${dateFmt.format(inv.receivedDate)}'
                                  '${cancelled ? '  •  CANCELLED' : ''}',
                                  style: cancelled
                                      ? const TextStyle(color: Colors.grey)
                                      : null,
                                ),
                                if (inv.notes != null && inv.notes!.isNotEmpty)
                                  Text(
                                    inv.notes!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: cancelled
                                          ? Colors.grey
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Sys: ${formatCurrency(inv.totalAmountSystem)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    decoration: cancelled
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: cancelled ? Colors.grey : null,
                                  ),
                                ),
                                Text(
                                  'Sup: ${formatCurrency(inv.totalAmountSupplier)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    decoration: cancelled
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: cancelled ? Colors.grey : null,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () async {
                              await context.push('/supplier-deliveries/${inv.id}');
                              ref.invalidate(filteredSupplierReceivedInvoicesProvider);
                              ref.invalidate(inventoryListProvider);
                            },
                          );
                        },
                      ),
                    ),

                    // Footer: grand totals
                    Container(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${invoices.length} delivery(ies)',
                              style: const TextStyle(color: Colors.grey)),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'System Total: ${formatCurrency(periodSystemTotal)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                'Supplier Total: ${formatCurrency(periodSupplierTotal)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: periodSupplierTotal != periodSystemTotal
                                      ? Colors.orange.shade800
                                      : null,
                                ),
                              ),
                            ],
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
