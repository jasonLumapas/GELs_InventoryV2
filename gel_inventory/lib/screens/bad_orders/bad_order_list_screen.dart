import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/bad_order.dart';
import '../../models/bad_order_draft.dart';
import '../../models/bad_order_item.dart';
import '../../models/client.dart';
import '../../models/invoice.dart';
import '../../models/product.dart';
import '../../repositories/bad_order_repository.dart';
import '../../repositories/client_repository.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/invoice_repository.dart';
import '../../repositories/product_repository.dart';
import '../../utils/currency_format.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/search_picker.dart';

enum _FilterType { day, week, month }

enum _ReportView { clients, products }

// Aggregated row for the Report tab — accumulates totals per client or
// per product across the currently filtered orders.
class _ReportRow {
  final String label;
  final int piecesPerBox;
  int totalPieces = 0;
  double totalAmount = 0;
  int orderCount = 0;

  _ReportRow({required this.label, this.piecesPerBox = 1});

  int get boxes => piecesPerBox > 0 ? totalPieces ~/ piecesPerBox : 0;
  int get remainingPieces =>
      piecesPerBox > 0 ? totalPieces % piecesPerBox : totalPieces;
}

class BadOrderListScreen extends ConsumerStatefulWidget {
  const BadOrderListScreen({super.key});

  @override
  ConsumerState<BadOrderListScreen> createState() => _BadOrderListScreenState();
}

class _BadOrderListScreenState extends ConsumerState<BadOrderListScreen>
    with SingleTickerProviderStateMixin {
  static DateTime _lastAnchor = DateTime.now();

  late final TabController _tabs;
  final _searchCtrl = TextEditingController();
  String? _filterType; // null = all
  String? _filterReason; // stock_release only; null = all
  _FilterType _filter = _FilterType.day;
  DateTime _anchor = _lastAnchor;
  _ReportView _reportView = _ReportView.clients;
  Map<String, List<String>> _productNamesByOrderId = {};
  Map<String, double> _amountByOrderId = {};
  Map<String, List<BadOrderItem>> _itemsByOrderId = {};
  Map<String, Product> _productsById = {};
  Map<String, double> _prices = {};

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _searchCtrl.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProductNames());
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProductNames() async {
    final grouped = await ref
        .read(badOrderRepositoryProvider)
        .getAllItemsGrouped();
    final products = await ref.read(productRepositoryProvider).getAll();
    final prices = await ref
        .read(productRepositoryProvider)
        .getAllCurrentPrices();
    final productsById = {for (final p in products) p.id: p};
    final nameMap = {for (final p in products) p.id: p.name};
    final ppbMap = {for (final p in products) p.id: p.piecesPerBox};
    if (!mounted) return;
    setState(() {
      _itemsByOrderId = grouped;
      _productsById = productsById;
      _prices = prices;
      _productNamesByOrderId = {
        for (final e in grouped.entries)
          e.key: e.value.map((i) => nameMap[i.productId] ?? '').toList(),
      };
      _amountByOrderId = {
        for (final e in grouped.entries)
          e.key: e.value.fold<double>(0, (sum, i) {
            final ppb = ppbMap[i.productId] ?? 1;
            final pieces = i.unitType == 'box' ? i.quantity * ppb : i.quantity;
            return sum + pieces * (prices[i.productId] ?? 0.0);
          }),
      };
    });
  }

  // Aggregates the currently filtered orders by client or by product,
  // depending on _reportView, sorted from highest to lowest total amount.
  List<_ReportRow> _buildReportRows(
    List<BadOrder> orders,
    Map<String, Client> clientsMap,
  ) {
    final Map<String, _ReportRow> acc = {};
    if (_reportView == _ReportView.clients) {
      for (final o in orders) {
        final name = clientsMap[o.clientId]?.name ?? 'No Client Specified';
        final row = acc.putIfAbsent(name, () => _ReportRow(label: name));
        row.totalAmount += _amountByOrderId[o.id] ?? 0;
        row.orderCount += 1;
      }
    } else {
      for (final o in orders) {
        for (final item in _itemsByOrderId[o.id] ?? const <BadOrderItem>[]) {
          final product = _productsById[item.productId];
          if (product == null) continue;
          final pieces = item.unitType == 'box'
              ? item.quantity * product.piecesPerBox
              : item.quantity;
          final row = acc.putIfAbsent(
            item.productId,
            () => _ReportRow(
              label: product.name,
              piecesPerBox: product.piecesPerBox,
            ),
          );
          row.totalPieces += pieces;
          row.totalAmount += pieces * (_prices[item.productId] ?? 0.0);
          row.orderCount += 1;
        }
      }
    }
    final rows = acc.values.toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return rows;
  }

  List<BadOrder> _applyFilters(
    List<BadOrder> orders,
    Map<String, Client> clientsMap,
  ) {
    final q = _searchCtrl.text.toLowerCase().trim();
    final from = _startDate;
    final to = _endDate;
    return orders.where((o) {
      if (_filterType != null && o.type != _filterType) return false;
      if (_filterType == 'stock_release' &&
          _filterReason != null &&
          o.notes != _filterReason) {
        return false;
      }
      if (o.date.isBefore(from) || !o.date.isBefore(to)) return false;
      if (q.isNotEmpty) {
        final clientName = (clientsMap[o.clientId]?.name ?? '').toLowerCase();
        final productNames = (_productNamesByOrderId[o.id] ?? []).map(
          (n) => n.toLowerCase(),
        );
        if (!clientName.contains(q) &&
            !productNames.any((n) => n.contains(q))) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // ── Date range helpers (mirrors Invoices' Day/Week/Month filter) ────────

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

  void _setAnchor(DateTime date) => setState(() {
    _anchor = date;
    _lastAnchor = date;
  });

  void _prev() {
    switch (_filter) {
      case _FilterType.day:
        _setAnchor(_anchor.subtract(const Duration(days: 1)));
      case _FilterType.week:
        _setAnchor(_anchor.subtract(const Duration(days: 7)));
      case _FilterType.month:
        _setAnchor(DateTime(_anchor.year, _anchor.month - 1, _anchor.day));
    }
  }

  void _next() {
    switch (_filter) {
      case _FilterType.day:
        _setAnchor(_anchor.add(const Duration(days: 1)));
      case _FilterType.week:
        _setAnchor(_anchor.add(const Duration(days: 7)));
      case _FilterType.month:
        _setAnchor(DateTime(_anchor.year, _anchor.month + 1, _anchor.day));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _anchor,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) _setAnchor(picked);
  }

  bool get _hasFilters =>
      _filterType != null ||
      _filterReason != null ||
      _searchCtrl.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(badOrdersListProvider);
    final clientsAsync = ref.watch(clientsListProvider);
    final draftsAsync = ref.watch(badOrderDraftsProvider);
    final invoicesAsync = ref.watch(invoicesListProvider);
    final dateFmt = DateFormat('MMM dd, yyyy');

    final clientsMap = <String, Client>{
      for (final c in clientsAsync.valueOrNull ?? []) c.id: c,
    };
    final invoicesById = <String, Invoice>{
      for (final inv in invoicesAsync.valueOrNull ?? []) inv.id: inv,
    };

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
          // ── Search bar ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by client or product…',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: const OutlineInputBorder(),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchCtrl.clear(),
                      )
                    : null,
              ),
            ),
          ),

          // ── Period filter (Day/Week/Month, mirrors Invoices) ────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                SegmentedButton<_FilterType>(
                  segments: const [
                    ButtonSegment(value: _FilterType.day, label: Text('Day')),
                    ButtonSegment(value: _FilterType.week, label: Text('Week')),
                    ButtonSegment(
                      value: _FilterType.month,
                      label: Text('Month'),
                    ),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (s) => setState(() => _filter = s.first),
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
                  onPressed: () => _setAnchor(DateTime.now()),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Today'),
                ),
              ],
            ),
          ),

          // ── Type filter chips ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final (typeValue, typeLabel) in [
                    (null as String?, 'All'),
                    ('bad_order', 'Bad Order'),
                    ('return', 'Return'),
                    ('stock_release', 'Stock Release'),
                    ('stock_pulled_out', 'Stock Pulled Out'),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(
                          typeLabel,
                          style: const TextStyle(fontSize: 12),
                        ),
                        selected: _filterType == typeValue,
                        onSelected: (_) => setState(() {
                          _filterType = typeValue;
                          if (typeValue != 'stock_release') {
                            _filterReason = null;
                          }
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Reason filter chips (Stock Release only) ─────────────────────
          if (_filterType == 'stock_release')
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final (reasonValue, reasonLabel) in [
                      (null as String?, 'All Reasons'),
                      ('Missed delivery', 'Missed delivery'),
                      ('Give-aways', 'Give-aways'),
                      ('Warehouse BO', 'Warehouse BO'),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(
                            reasonLabel,
                            style: const TextStyle(fontSize: 12),
                          ),
                          selected: _filterReason == reasonValue,
                          onSelected: (_) =>
                              setState(() => _filterReason = reasonValue),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          const Divider(height: 1),

          // ── Tabs: List / Report ──────────────────────────────────────────
          TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: 'List'),
              Tab(text: 'Report'),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _buildListTab(
                  listAsync,
                  draftsAsync,
                  clientsMap,
                  dateFmt,
                  invoicesById,
                ),
                listAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (orders) => _buildReportTab(
                    _applyFilters(orders, clientsMap),
                    clientsMap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTab(
    AsyncValue<List<BadOrder>> listAsync,
    AsyncValue<List<BadOrderDraft>> draftsAsync,
    Map<String, Client> clientsMap,
    DateFormat dateFmt,
    Map<String, Invoice> invoicesById,
  ) {
    return Column(
      children: [
        // ── Draft bad orders / returns banner ──────────────────────────
        draftsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (drafts) {
            if (drafts.isEmpty) return const SizedBox.shrink();
            return Container(
              width: double.infinity,
              color: Colors.amber.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${drafts.length} unfinished bad order(s)/return(s)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ...drafts.map((d) {
                    final client = d.noClient ? null : clientsMap[d.clientId];
                    final typeLabel = d.type == 'return'
                        ? 'Return'
                        : d.type == 'stock_release'
                        ? 'Stock Release'
                        : 'Bad Order';
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
                            onPressed: () =>
                                context.go('/bad-orders/new?draft=${d.id}'),
                            child: const Text('Resume'),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
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

        // ── Orders list ───────────────────────────────────────────────
        Expanded(
          child: listAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (orders) {
              final filtered = _applyFilters(orders, clientsMap);
              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    _hasFilters
                        ? 'No results match your search or filters.'
                        : 'No bad orders or returns yet.',
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              final grandTotal = filtered.fold<double>(
                0,
                (sum, o) => sum + (_amountByOrderId[o.id] ?? 0),
              );
              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final o = filtered[i];
                        final client = clientsMap[o.clientId];
                        final linkedInvoice = o.invoiceId == null
                            ? null
                            : invoicesById[o.invoiceId];
                        return ListTile(
                          leading: Icon(
                            o.isReturn
                                ? Icons.undo
                                : o.isStockRelease
                                ? Icons.output
                                : o.isStockPulledOut
                                ? Icons.move_down
                                : Icons.remove_shopping_cart,
                            color: o.restoresInventory
                                ? Colors.green
                                : o.isStockRelease
                                ? Colors.red
                                : Colors.orange,
                          ),
                          title: Text(
                            '${o.typeLabel} — ${client?.name ?? o.clientId}',
                          ),
                          subtitle: Text(
                            '${dateFmt.format(o.date)}'
                            '${o.notes != null ? ' • ${o.notes}' : ''}'
                            '${linkedInvoice != null ? ' • Invoice ${linkedInvoice.displayNumber}' : ''}',
                          ),
                          onTap: () => _showDetail(context, ref, o, client),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                formatCurrency(_amountByOrderId[o.id] ?? 0),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final ok = await showConfirmDialog(
                                    ctx,
                                    title: 'Delete',
                                    message:
                                        'Delete this ${o.typeLabel}? This cannot be undone.',
                                    confirmLabel: 'Delete',
                                  );
                                  if (ok) {
                                    await ref
                                        .read(badOrderRepositoryProvider)
                                        .delete(o.id);
                                    ref.invalidate(badOrdersListProvider);
                                    ref.invalidate(inventoryListProvider);
                                    if (o.isStockPulledOut &&
                                        o.invoiceId != null) {
                                      ref.invalidate(invoicesListProvider);
                                      ref.invalidate(filteredInvoicesProvider);
                                    }
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Grand Total: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          formatCurrency(grandTotal),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
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
    );
  }

  Widget _buildReportTab(
    List<BadOrder> orders,
    Map<String, Client> clientsMap,
  ) {
    final rows = _buildReportRows(orders, clientsMap);
    final isClients = _reportView == _ReportView.clients;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: SegmentedButton<_ReportView>(
            segments: const [
              ButtonSegment(value: _ReportView.clients, label: Text('Clients')),
              ButtonSegment(
                value: _ReportView.products,
                label: Text('Products'),
              ),
            ],
            selected: {_reportView},
            onSelectionChanged: (s) => setState(() => _reportView = s.first),
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: rows.isEmpty
              ? Center(
                  child: Text(
                    'No ${isClients ? "clients" : "products"} for $_periodLabel.',
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final row = rows[i];
                    final isTop = i < 3;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isTop
                            ? Colors.green.shade100
                            : Colors.grey.shade100,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isTop
                                ? Colors.green.shade800
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      title: Text(
                        row.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        isClients
                            ? '${row.orderCount} order(s)'
                            : '${row.boxes > 0 ? "${row.boxes} box(es)" : ""}'
                                  '${row.boxes > 0 && row.remainingPieces > 0 ? " + " : ""}'
                                  '${row.remainingPieces > 0 ? "${row.remainingPieces} pcs" : ""}'
                                  '${row.boxes == 0 && row.remainingPieces == 0 ? "—" : ""}',
                      ),
                      trailing: Text(
                        formatCurrency(row.totalAmount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isTop ? Colors.green.shade700 : null,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
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

  int _selectedIndex = -1;
  final FocusNode _listFocusNode = FocusNode();
  List<GlobalKey> _itemKeys = [];
  bool _pickingProduct = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _listFocusNode.dispose();
    super.dispose();
  }

  void _selectItem(int index) {
    if (index < 0 || index >= _items.length) return;
    setState(() => _selectedIndex = index);
    _listFocusNode.requestFocus();
    _ensureVisible(index);
  }

  void _ensureVisible(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (index < 0 || index >= _itemKeys.length) return;
      final ctx = _itemKeys[index].currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 150),
        );
      }
    });
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.insert) {
      _addItem();
      return KeyEventResult.handled;
    }

    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (_items.isEmpty) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      final next = _selectedIndex < 0
          ? 0
          : (_selectedIndex + 1).clamp(0, _items.length - 1);
      _selectItem(next);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      final prev = _selectedIndex < 0
          ? _items.length - 1
          : (_selectedIndex - 1).clamp(0, _items.length - 1);
      _selectItem(prev);
      return KeyEventResult.handled;
    }
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.delete ||
            event.logicalKey == LogicalKeyboardKey.backspace) &&
        _selectedIndex >= 0 &&
        _selectedIndex < _items.length) {
      _deleteItem(_items[_selectedIndex]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // Stock Pulled out entries recompute the linked invoice's totals as a
  // side effect of item mutations — refresh Invoice screens so they pick
  // it up immediately.
  void _invalidateInvoiceIfLinked() {
    if (widget.order.isStockPulledOut && widget.order.invoiceId != null) {
      ref.invalidate(invoicesListProvider);
      ref.invalidate(filteredInvoicesProvider);
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final itemsFuture = ref
        .read(badOrderRepositoryProvider)
        .getItems(widget.order.id);
    final productsFuture = ref.read(productRepositoryProvider).getAll();
    final pricesFuture = ref
        .read(productRepositoryProvider)
        .getAllCurrentPrices();
    final inventoryFuture = ref.read(inventoryRepositoryProvider).getAll();

    final results = await Future.wait([
      itemsFuture,
      productsFuture,
      pricesFuture,
      inventoryFuture,
    ]);
    final items = results[0] as List<BadOrderItem>;
    final products = results[1] as List<Product>;
    final prices = results[2] as Map<String, double>;
    final inventory = results[3] as List;

    final productsById = <String, Product>{for (final p in products) p.id: p};
    final inventoryQty = <String, int>{
      for (final i in inventory) i.productId as String: i.quantityPieces as int,
    };

    final amounts = <String, double>{};
    double total = 0;
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

    final previouslySelectedId =
        (_selectedIndex >= 0 && _selectedIndex < _items.length)
        ? _items[_selectedIndex].id
        : null;
    final newIndex = previouslySelectedId == null
        ? -1
        : items.indexWhere((i) => i.id == previouslySelectedId);

    if (!mounted) return;
    setState(() {
      _loading = false;
      _items = items;
      _productsById = productsById;
      _amounts = amounts;
      _grandTotal = total;
      _inventoryQty = inventoryQty;
      _itemKeys = List.generate(items.length, (_) => GlobalKey());
      _selectedIndex = newIndex;
    });
  }

  // Returns the set of product ids the client has ordered on or before this
  // bad order's date — mirrors _loadOrderedProducts in bad_order_form_screen.
  Future<Set<String>> _loadOrderedProductIds() async {
    final client = widget.client;
    if (client == null) return {};
    final cutoff = DateTime(
      widget.order.date.year,
      widget.order.date.month,
      widget.order.date.day,
      23,
      59,
      59,
    );
    final invoices = await ref.read(invoiceRepositoryProvider).getAll();
    final ids = <String>{};
    for (final inv in invoices.where(
      (i) => i.clientId == client.id && !i.invoiceDate.isAfter(cutoff),
    )) {
      final items = await ref.read(invoiceRepositoryProvider).getItems(inv.id);
      for (final item in items) {
        ids.add(item.productId);
      }
    }
    return ids;
  }

  Future<void> _addItem() async {
    if (_pickingProduct) return;
    setState(() => _pickingProduct = true);

    final alreadyIds = _items.map((i) => i.productId).toSet();
    // Stock releases and "no client" orders aren't tied to a client's order
    // history, so any product is eligible — same rule as the create form.
    final showAll =
        widget.client == null ||
        widget.client!.id == ClientRepository.noClientId ||
        widget.order.isStockRelease ||
        widget.order.isStockPulledOut;
    final orderedProductIds = showAll ? null : await _loadOrderedProductIds();

    if (!mounted) return;
    setState(() => _pickingProduct = false);

    final candidates =
        _productsById.values
            .where(
              (p) =>
                  !alreadyIds.contains(p.id) &&
                  (showAll || orderedProductIds!.contains(p.id)),
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            showAll
                ? 'No products available to add.'
                : 'No previously ordered products found for this client.',
          ),
        ),
      );
      return;
    }

    final restoresInventory = widget.order.restoresInventory;
    final product = await showSearchPicker<Product>(
      context: context,
      title: 'Select Product',
      items: candidates,
      labelOf: (p) => p.name,
      searchableOf: (p) => '${p.name} ${p.productCode ?? ''}',
      subtitleOf: restoresInventory
          ? null
          : (p) {
              final qty = _inventoryQty[p.id] ?? 0;
              final boxes = p.piecesPerBox > 0 ? qty ~/ p.piecesPerBox : 0;
              final pcs = p.piecesPerBox > 0 ? qty % p.piecesPerBox : qty;
              return boxes > 0
                  ? '$boxes box(es) + $pcs pcs available'
                  : '$pcs pcs available';
            },
    );
    if (product == null || !mounted) return;

    final piecesPerBox = product.piecesPerBox;
    final maxPieces =
        restoresInventory ? null : (_inventoryQty[product.id] ?? 0);

    String unitType = 'piece';
    final qtyCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) {
          final newQty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
          final newPieces = unitType == 'box' ? newQty * piecesPerBox : newQty;
          final isOver = maxPieces != null && newPieces > maxPieces;

          String availLabel = '';
          if (maxPieces != null) {
            final availBoxes = piecesPerBox > 0 ? maxPieces ~/ piecesPerBox : 0;
            final availPcs = piecesPerBox > 0
                ? maxPieces % piecesPerBox
                : maxPieces;
            availLabel = availBoxes > 0
                ? '$availBoxes box(es)${availPcs > 0 ? ' + $availPcs pcs' : ''}'
                : '$availPcs pcs';
          }

          return AlertDialog(
            title: Text('Add — ${product.name}'),
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
                  onSelectionChanged: (s) => setDlg(() => unitType = s.first),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: qtyCtrl,
                  autofocus: true,
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
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: (isOver || newQty <= 0)
                    ? null
                    : () => Navigator.pop(ctx, true),
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed != true || !mounted) return;
    final newQty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
    if (newQty <= 0) return;

    final newItem = BadOrderItem(
      id: const Uuid().v4(),
      badOrderId: widget.order.id,
      productId: product.id,
      unitType: unitType,
      quantity: newQty,
    );

    await ref
        .read(badOrderRepositoryProvider)
        .addItem(
          order: widget.order,
          item: newItem,
          piecesPerBox: piecesPerBox,
        );
    ref.invalidate(badOrdersListProvider);
    ref.invalidate(inventoryListProvider);
    _invalidateInvoiceIfLinked();
    await _loadData();
    if (!mounted) return;
    final idx = _items.indexWhere((i) => i.id == newItem.id);
    if (idx != -1) _selectItem(idx);
  }

  Future<void> _editItem(BadOrderItem item) async {
    final product = _productsById[item.productId];
    final piecesPerBox = product?.piecesPerBox ?? 1;
    final oldPieces = item.unitType == 'box'
        ? item.quantity * piecesPerBox
        : item.quantity;

    // For bad orders the old deduction is already in the DB, so effective
    // available = current stock + old pieces back − pieces held by other
    // lines for this same product.
    // Returns/stock-pulled-out have no stock constraint (they add stock back).
    int? maxPieces;
    if (!widget.order.restoresInventory) {
      int otherCommitted = 0;
      for (final other in _items) {
        if (other.id == item.id || other.productId != item.productId) continue;
        final ppb = _productsById[other.productId]?.piecesPerBox ?? 1;
        otherCommitted += other.unitType == 'box'
            ? other.quantity * ppb
            : other.quantity;
      }
      final stock = _inventoryQty[item.productId] ?? 0;
      final raw = stock + oldPieces - otherCommitted;
      maxPieces = raw < 0 ? 0 : raw;
    }

    String unitType = item.unitType;
    final qtyCtrl = TextEditingController(text: item.quantity.toString());

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) {
          final newQty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
          final newPieces = unitType == 'box' ? newQty * piecesPerBox : newQty;
          final isOver = maxPieces != null && newPieces > maxPieces;

          String availLabel = '';
          if (maxPieces != null) {
            final availBoxes = maxPieces ~/ piecesPerBox;
            final availPcs = maxPieces % piecesPerBox;
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
                  onSelectionChanged: (s) => setDlg(() => unitType = s.first),
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
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: isOver ? null : () => Navigator.pop(ctx, true),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed != true || !mounted) return;
    final newQty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
    if (newQty <= 0) return;

    await ref
        .read(badOrderRepositoryProvider)
        .updateItem(
          order: widget.order,
          oldItem: item,
          newUnitType: unitType,
          newQuantity: newQty,
          piecesPerBox: product?.piecesPerBox ?? 1,
        );
    ref.invalidate(badOrdersListProvider);
    ref.invalidate(inventoryListProvider);
    _invalidateInvoiceIfLinked();
    await _loadData();
  }

  Future<void> _deleteItem(BadOrderItem item) async {
    final product = _productsById[item.productId];
    final ok = await showConfirmDialog(
      context,
      title: 'Delete Item',
      message:
          'Remove "${product?.name ?? item.productId}" from this '
          '${widget.order.typeLabel}? The inventory will be adjusted.',
      confirmLabel: 'Delete',
    );
    if (!ok || !mounted) return;

    await ref
        .read(badOrderRepositoryProvider)
        .deleteItem(
          order: widget.order,
          item: item,
          piecesPerBox: product?.piecesPerBox ?? 1,
        );
    ref.invalidate(badOrdersListProvider);
    ref.invalidate(inventoryListProvider);
    _invalidateInvoiceIfLinked();

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
                      : widget.order.isStockRelease
                      ? Icons.output
                      : widget.order.isStockPulledOut
                      ? Icons.move_down
                      : Icons.remove_shopping_cart,
                  color: widget.order.restoresInventory
                      ? Colors.green
                      : widget.order.isStockRelease
                      ? Colors.red
                      : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.order.typeLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                _metaRow(
                  'Client',
                  widget.client?.name ?? widget.order.clientId,
                ),
                _metaRow('Date', dateFmt.format(widget.order.date)),
                if (widget.order.notes != null &&
                    widget.order.notes!.isNotEmpty)
                  _metaRow(
                    widget.order.isStockRelease ? 'Reason' : 'Notes',
                    widget.order.notes!,
                  ),
              ],
            ),
          ),

          const Divider(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Items',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  onPressed: (_loading || _pickingProduct) ? null : _addItem,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Body
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_items.isEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('No items.'),
              ),
            )
          else ...[
            Expanded(
              child: Focus(
                focusNode: _listFocusNode,
                autofocus: true,
                onKeyEvent: _handleKey,
                child: ListView.separated(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final item = _items[i];
                    final product = _productsById[item.productId];
                    final ppb = product?.piecesPerBox ?? 1;
                    final isSelected = _selectedIndex == i;
                    String qtyLabel;
                    if (item.unitType == 'box') {
                      qtyLabel = '${item.quantity} box(es)';
                    } else {
                      final boxes = ppb > 0 ? item.quantity ~/ ppb : 0;
                      final pcs = ppb > 0 ? item.quantity % ppb : item.quantity;
                      qtyLabel = boxes > 0
                          ? '$boxes box(es) + $pcs pcs'
                          : '$pcs pcs';
                    }
                    final amount = _amounts[item.id] ?? 0.0;
                    return ListTile(
                      key: i < _itemKeys.length ? _itemKeys[i] : null,
                      selected: isSelected,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      onTap: () => _selectItem(i),
                      contentPadding: EdgeInsets.zero,
                      title: Text(product?.name ?? item.productId),
                      subtitle: Text(
                        qtyLabel,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatCurrency(amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            tooltip: 'Edit item',
                            onPressed: () => _editItem(item),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            tooltip: 'Delete item',
                            onPressed: () => _deleteItem(item),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Grand total footer
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Grand Total: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    formatCurrency(_grandTotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
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
        child: Text(
          '$label:',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
    ],
  ),
);
