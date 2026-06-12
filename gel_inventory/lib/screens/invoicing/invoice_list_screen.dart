import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/services/app_settings_service.dart';
import '../../models/client.dart';
import '../../models/invoice.dart';
import '../../models/product.dart';
import '../../repositories/client_repository.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/invoice_repository.dart';
import '../../repositories/product_repository.dart';
import '../../utils/currency_format.dart';
import '../../utils/pdf_generator.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/search_picker.dart';

enum _FilterType { day, week, month }

class _Financials {
  final double grandTotal;
  final double capital;
  double get profit => grandTotal - capital;
  const _Financials(this.grandTotal, this.capital);
}

/// Returns the set of invoice ids (within [range]) that contain at least one
/// item for the given product id.
final _productInvoiceIdsProvider = FutureProvider.autoDispose
    .family<Set<String>, (DateTime, DateTime, String)>((ref, args) async {
  final (start, end, productId) = args;
  final invoices = await ref.watch(filteredInvoicesProvider((start, end)).future);
  final invoiceRepo = ref.read(invoiceRepositoryProvider);
  final ids = <String>{};
  for (final inv in invoices) {
    final items = await invoiceRepo.getItems(inv.id);
    if (items.any((it) => it.productId == productId)) {
      ids.add(inv.id);
    }
  }
  return ids;
});

final _financialsProvider = FutureProvider.autoDispose
    .family<_Financials, (DateTime, DateTime)>((ref, range) async {
  final invoices = await ref.watch(filteredInvoicesProvider(range).future);
  final invoiceRepo = ref.read(invoiceRepositoryProvider);
  final productRepo = ref.read(productRepositoryProvider);
  double grandTotal = 0;
  double capital = 0;
  for (final inv in invoices) {
    if (inv.status == 'cancelled') continue;
    grandTotal += inv.totalAmount;
    final items = await invoiceRepo.getItems(inv.id);
    for (final item in items) {
      if (item.isFree) continue;
      final price = await productRepo.getCurrentPrice(item.productId);
      if (price != null) {
        capital += price.withdrawalPrice * item.quantity;
      }
    }
  }
  return _Financials(grandTotal, capital);
});

class InvoiceListScreen extends ConsumerStatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  _FilterType _filter = _FilterType.day;
  DateTime _anchor = DateTime.now().add(const Duration(days: 1));
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  Product? _productFilter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final changed = await ref
          .read(invoiceRepositoryProvider)
          .backfillSequenceNumbers();
      if (changed && mounted) {
        ref.invalidate(invoicesListProvider);
        ref.invalidate(filteredInvoicesProvider);
        ref.invalidate(draftInvoicesProvider);
      }
    });
  }

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

  Future<void> _pickProductFilter() async {
    final products = await ref.read(productsListProvider.future);
    if (!mounted) return;
    final picked = await showSearchPicker<Product>(
      context: context,
      title: 'Filter by Product',
      items: products,
      labelOf: (p) => p.name,
    );
    if (picked != null) setState(() => _productFilter = picked);
  }

  Future<void> _print() async {
    final invoices   = ref.read(filteredInvoicesProvider((_startDate, _endDate))).valueOrNull;
    final clientsMap = {
      for (final c in ref.read(clientsListProvider).valueOrNull ?? []) c.id: c
    };
    if (invoices == null || invoices.isEmpty) return;

    final items = invoices.map((inv) => InvoiceListItem(
          invoiceNumber: inv.displayNumber,
          clientName: clientsMap[inv.clientId]?.name ?? inv.clientId,
          date: inv.invoiceDate,
          amount: inv.totalAmount,
          notes: inv.notes,
        )).toList();

    await printInvoiceList(periodLabel: _periodLabel, items: items);
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final invoicesAsync =
        ref.watch(filteredInvoicesProvider((_startDate, _endDate)));
    final clientsAsync = ref.watch(clientsListProvider);
    final draftsAsync = ref.watch(draftInvoicesProvider);
    final dateFmt = DateFormat('MMM dd, yyyy');

    return AppScaffold(
      title: 'Invoices',
      actions: [
        IconButton(
          icon: const Icon(Icons.print),
          tooltip: 'Print invoice list',
          onPressed: _print,
        ),
        FilledButton.icon(
          icon: const Icon(Icons.add, size: 18),
          label: const Text('New Invoice'),
          onPressed: () => context.go('/invoices/new'),
        ),
        const SizedBox(width: 8),
      ],
      body: Column(
        children: [
          // ── Draft invoices banner ────────────────────────────────────────
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
                        '${drafts.length} unfinished invoice(s)',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    ...drafts.map((d) {
                      final client = clientsMap[d.clientId];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.edit_note, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${client?.name ?? 'Unknown client'}'
                                '  •  ${dateFmt.format(d.invoiceDate)}'
                                '  •  ${formatCurrency(d.totalAmount)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context
                                  .go('/invoices/new?draft=${d.id}'),
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
                                      'Discard this unfinished invoice? This cannot be undone.',
                                  confirmLabel: 'Discard',
                                );
                                if (ok) {
                                  await ref
                                      .read(invoiceRepositoryProvider)
                                      .discardDraft(d.id);
                                  ref.invalidate(draftInvoicesProvider);
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
                // Period type
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

                // Previous
                // IconButton(
                //   icon: const Icon(Icons.chevron_left),
                //   onPressed: _prev,
                //   visualDensity: VisualDensity.compact,
                // ),

                // Date label (tappable to pick a specific date)
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

                // Next
                // IconButton(
                //   icon: const Icon(Icons.chevron_right),
                //   onPressed: _next,
                //   visualDensity: VisualDensity.compact,
                // ),

                // Today shortcut
                TextButton(
                  onPressed: () => setState(() =>
                      _anchor = DateTime.now().add(const Duration(days: 1))),
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search by store, notes or date…',
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
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: Icon(
                    _productFilter == null
                        ? Icons.filter_alt_outlined
                        : Icons.filter_alt,
                    size: 18,
                  ),
                  label: Text(
                    _productFilter?.name ?? 'Product',
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact),
                  onPressed: _pickProductFilter,
                ),
                if (_productFilter != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    tooltip: 'Clear product filter',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() => _productFilter = null),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Invoice list ───────────────────────────────────────────────
          Expanded(
            child: invoicesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (allInvoices) {
                final clientsMap = <String, Client>{
                  for (final c in clientsAsync.valueOrNull ?? []) c.id: c
                };

                // Client-side filter by store name, notes, or date.
                final searchFiltered = _searchQuery.isEmpty
                    ? allInvoices
                    : () {
                        final q = _searchQuery.toLowerCase();
                        return allInvoices.where((inv) {
                          final clientName = (clientsMap[inv.clientId]?.name ?? '').toLowerCase();
                          final notes = (inv.notes ?? '').toLowerCase();
                          final dateStr = dateFmt.format(inv.invoiceDate).toLowerCase();
                          return clientName.contains(q) ||
                              notes.contains(q) ||
                              dateStr.contains(q);
                        }).toList();
                      }();

                // Filter by selected product, if any.
                if (_productFilter != null) {
                  final idsAsync = ref.watch(_productInvoiceIdsProvider(
                      (_startDate, _endDate, _productFilter!.id)));
                  return idsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (ids) {
                      final filtered = searchFiltered
                          .where((inv) => ids.contains(inv.id))
                          .toList();
                      return _buildInvoiceListBody(
                          context, filtered, clientsMap, dateFmt);
                    },
                  );
                }

                return _buildInvoiceListBody(
                    context, searchFiltered, clientsMap, dateFmt);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceListBody(
    BuildContext context,
    List<Invoice> invoices,
    Map<String, Client> clientsMap,
    DateFormat dateFmt,
  ) {
                if (invoices.isEmpty) {
                  return Center(
                    child: Text(_searchQuery.isEmpty
                        ? 'No invoices for $_periodLabel.'
                        : 'No invoices match "$_searchQuery".'),
                  );
                }

                // Running total for the period
                final periodTotal =
                    invoices.fold(0.0, (s, i) => s + i.totalAmount);
                final actualTotal = invoices.fold(
                    0.0, (s, i) => s + (i.actualAmount ?? 0));
                final hasActual =
                    invoices.any((i) => i.actualAmount != null);

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: invoices.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final inv = invoices[i];
                          final client = clientsMap[inv.clientId];
                          final displayNumber = inv.displayNumber;
                          return ListTile(
                            leading: const Icon(Icons.receipt_long),
                            title: Text(displayNumber),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${client?.name ?? inv.clientId}'
                                  '  •  ${dateFmt.format(inv.invoiceDate)}'
                                  '  •  ${inv.status.toUpperCase()}',
                                ),
                                if (client?.address != null &&
                                    client!.address!.isNotEmpty)
                                  Text(
                                    client.address!,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                if (inv.notes != null && inv.notes!.isNotEmpty)
                                  Text(
                                    inv.notes!,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                if (inv.actualAmount != null)
                                  Text(
                                    'Actual: ${formatCurrency(inv.actualAmount!)}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  formatCurrency(inv.totalAmount),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  tooltip: inv.status == 'printed'
                                      ? 'Delete (restores stock)'
                                      : 'Delete',
                                  onPressed: () async {
                                    final msg = inv.status == 'printed'
                                        ? 'Delete invoice $displayNumber?\n\nOrdered stock will be restored to inventory.'
                                        : 'Delete invoice $displayNumber? This cannot be undone.';
                                    final ok = await showConfirmDialog(
                                      ctx,
                                      title: 'Delete Invoice',
                                      message: msg,
                                      confirmLabel: 'Delete',
                                    );
                                    if (ok) {
                                      await ref
                                          .read(invoiceRepositoryProvider)
                                          .deleteInvoice(inv);
                                      ref.invalidate(filteredInvoicesProvider);
                                      ref.invalidate(invoicesListProvider);
                                      ref.invalidate(inventoryListProvider);
                                    }
                                  },
                                ),
                              ],
                            ),
                            onTap: () async {
                              await context.push('/invoices/${inv.id}');
                              ref.invalidate(filteredInvoicesProvider);
                              ref.invalidate(_financialsProvider);
                            },
                          );
                        },
                      ),
                    ),

                    // Footer: invoice count + financials
                    Container(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${invoices.length} invoice(s)',
                              style: const TextStyle(color: Colors.grey)),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (hasActual)
                                Text(
                                  'Actual Total: ${formatCurrency(actualTotal)}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700),
                                ),
                              () {
                            final showCapitalProfit = ref
                                    .watch(showCapitalProfitProvider)
                                    .valueOrNull ??
                                true;
                            return ref
                                .watch(_financialsProvider(
                                    (_startDate, _endDate)))
                                .when(
                                  loading: () => const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)),
                                  error: (_, s) => Text(
                                      'Total: ${formatCurrency(periodTotal)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  data: (fin) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Total: ${formatCurrency(fin.grandTotal)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      if (showCapitalProfit) ...[
                                        Text(
                                          'Capital: ${formatCurrency(fin.capital)}',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700),
                                        ),
                                        Text(
                                          'Profit: ${formatCurrency(fin.profit)}',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: fin.profit >= 0
                                                  ? Colors.green.shade700
                                                  : Colors.red),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
  }
}
