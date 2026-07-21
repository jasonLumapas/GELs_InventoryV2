import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/app_settings_service.dart';
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
import '../../repositories/supplier_repository.dart';
import '../../utils/currency_format.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/search_picker.dart';

class BadOrderFormScreen extends ConsumerStatefulWidget {
  /// If set, resumes the existing draft with this id instead of starting
  /// a new one.
  final String? draftId;

  const BadOrderFormScreen({super.key, this.draftId});

  @override
  ConsumerState<BadOrderFormScreen> createState() => _BadOrderFormScreenState();
}

class _BadOrderFormScreenState extends ConsumerState<BadOrderFormScreen> {
  // Captured during build so it can still be used in dispose(), where `ref`
  // throws (the ConsumerStatefulElement is already marked disposed by then).
  ProviderContainer? _container;

  final _notesCtrl = TextEditingController();
  List<Client> _clients = [];
  List<Product> _products = [];
  Client? _selectedClient;
  String _type = 'bad_order'; // 'bad_order' | 'return' | 'stock_release' | 'stock_pulled_out'
  DateTime _selectedDate = DateTime.now();
  final List<_BoItem> _items = [];
  Map<String, int> _inventoryQty = {};
  Map<String, double> _prices = {};
  Map<String, double> _costPrices = {};
  Map<String, String> _suppliersById = {};
  String? _reason; // stock_release only; stored in notes column
  List<Invoice> _invoices = [];
  Invoice? _selectedInvoice; // stock_pulled_out only
  bool _loading = true;
  bool _saving = false;
  Set<String> _orderedProductIds = {};
  bool _loadingOrderedProducts = false;
  bool _allowNoClient = false;
  bool _noClient = false;

  // ── Auto-save (draft) ────────────────────────────────────────────────────
  late String _draftId;
  late DateTime _createdAt;
  Timer? _autoSaveTimer;
  bool _draftPersisted = false;
  bool _finalized = false;

  @override
  void initState() {
    super.initState();
    _draftId = widget.draftId ?? const Uuid().v4();
    _createdAt = DateTime.now();
    _load();
  }

  Future<void> _load() async {
    final clientsFuture = ref.read(clientRepositoryProvider).getAll();
    final productsFuture = ref.read(productRepositoryProvider).getAll();
    final invFuture = ref.read(inventoryRepositoryProvider).getAll();
    final suppliersFuture = ref.read(supplierRepositoryProvider).getAll();
    final pricesFuture = ref.read(productRepositoryProvider).getAllCurrentPrices();
    final costPricesFuture =
        ref.read(productRepositoryProvider).getAllCurrentCostPrices();
    final invoicesFuture = ref.read(invoiceRepositoryProvider).getAll();
    _clients = await clientsFuture;
    _products = await productsFuture;
    final invItems = await invFuture;
    final suppliers = await suppliersFuture;
    _prices = await pricesFuture;
    _costPrices = await costPricesFuture;
    _invoices = await invoicesFuture;
    _allowNoClient = await AppSettingsService.getAllowBadOrderNoClient();
    _inventoryQty = {for (final i in invItems) i.productId: i.quantityPieces};
    _suppliersById = {for (final s in suppliers) s.id: s.name};

    if (widget.draftId != null) {
      await _loadDraft(widget.draftId!);
    }

    setState(() => _loading = false);

    if (_selectedClient != null && !_noClient) {
      await _loadOrderedProducts();
    }
  }

  // Loads a previously auto-saved draft and reconstructs client/date/type/
  // items from it.
  Future<void> _loadDraft(String id) async {
    final drafts = await ref.read(badOrderRepositoryProvider).getDrafts();
    final draft = drafts.where((d) => d.id == id).firstOrNull;
    if (draft == null) return;

    _createdAt = draft.createdAt;
    _draftPersisted = true;
    _type = draft.type;
    _selectedDate = draft.date;
    _noClient = draft.noClient;
    _selectedClient = draft.noClient
        ? null
        : _clients.where((c) => c.id == draft.clientId).firstOrNull;
    if (draft.type == 'stock_release') {
      _reason = draft.notes;
    } else {
      _notesCtrl.text = draft.notes ?? '';
    }

    final productsById = {for (final p in _products) p.id: p};
    for (final di in draft.items) {
      final product = productsById[di.productId];
      if (product == null) continue;
      _items.add(
        _BoItem(
            productId: product.id,
            productName: product.name,
            piecesPerBox: product.piecesPerBox,
          )
          ..boxes = di.boxes
          ..pieces = di.pieces,
      );
    }
  }

  // Debounce auto-saving so rapid edits don't trigger a DB write on every
  // keystroke.
  void _scheduleAutoSave() {
    if (_finalized) return;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), _autoSaveDraft);
  }

  bool get _clientOptional =>
      _type == 'stock_release' || _type == 'stock_pulled_out';

  bool get _hasDraftContent =>
      (_selectedClient != null || _noClient || _clientOptional) &&
      _items.isNotEmpty;

  BadOrderDraft _buildDraftPayload() => BadOrderDraft(
    id: _draftId,
    type: _type,
    clientId:
        (_noClient || (_clientOptional && _selectedClient == null))
        ? null
        : _selectedClient?.id,
    noClient:
        _noClient || (_clientOptional && _selectedClient == null),
    date: _selectedDate,
    notes: _type == 'stock_release'
        ? _reason
        : (_notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
    items: _items
        .map(
          (i) => BadOrderDraftItem(
            productId: i.productId,
            boxes: i.boxes,
            pieces: i.pieces,
          ),
        )
        .toList(),
    createdAt: _createdAt,
  );

  Future<void> _autoSaveDraft() async {
    if (_finalized || !mounted) return;
    if (!_hasDraftContent) return;
    await ref.read(badOrderRepositoryProvider).saveDraft(_buildDraftPayload());
    _draftPersisted = true;
    ref.invalidate(badOrderDraftsProvider);
  }

  double get _grandTotal => _items.fold(
    0.0,
    (sum, item) => sum + item.quantityInPieces * (_prices[item.productId] ?? 0),
  );

  double get _profitTotal => _items.fold(
    0.0,
    (sum, item) =>
        sum +
        item.quantityInPieces *
            ((_prices[item.productId] ?? 0) -
                (_costPrices[item.productId] ?? 0)),
  );

  int _committedPieces(String productId, {int? excludeIndex}) {
    int total = 0;
    for (int i = 0; i < _items.length; i++) {
      if (i == excludeIndex) continue;
      if (_items[i].productId == productId) total += _items[i].quantityInPieces;
    }
    return total;
  }

  int _effectiveAvailable(String productId, {int? excludeIndex}) {
    final stock = _inventoryQty[productId] ?? 0;
    final avail =
        stock - _committedPieces(productId, excludeIndex: excludeIndex);
    return avail < 0 ? 0 : (avail > stock ? stock : avail);
  }

  bool get _canSave {
    if (_saving) return false;
    if (_selectedClient == null && !_noClient && !_clientOptional)
      return false;
    if (_type == 'stock_release' && (_reason == null || _reason!.isEmpty))
      return false;
    if (_type == 'stock_pulled_out' && _selectedInvoice == null) return false;
    if (_items.isEmpty) return false;
    if (_type == 'bad_order' || _type == 'stock_release') {
      for (int i = 0; i < _items.length; i++) {
        final item = _items[i];
        if (item.quantityInPieces <= 0) return false;
        if (item.quantityInPieces >
            _effectiveAvailable(item.productId, excludeIndex: i)) {
          return false;
        }
      }
    } else {
      if (_items.any((item) => item.quantityInPieces <= 0)) return false;
    }
    return true;
  }

  void _toggleNoClient(bool value) {
    setState(() {
      _noClient = value;
      _selectedClient = null;
      _orderedProductIds = {};
      _items.clear();
    });
    _scheduleAutoSave();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
      _items.clear();
    });
    await _loadOrderedProducts();
    _scheduleAutoSave();
  }

  Future<void> _pickClient() async {
    final picked = await showSearchPicker<Client>(
      context: context,
      title: 'Select Client',
      items: _clients,
      labelOf: (c) => c.name,
      subtitleOf: (c) => c.address,
    );
    if (picked == null) return;
    setState(() {
      _selectedClient = picked;
      _items.clear();
    });
    await _loadOrderedProducts();
    _scheduleAutoSave();
  }

  Future<void> _pickInvoice() async {
    final clientsById = {for (final c in _clients) c.id: c.name};
    final dateFmt = DateFormat('MMM dd, yyyy');
    final picked = await showSearchPicker<Invoice>(
      context: context,
      title: 'Select Invoice',
      items: _invoices,
      labelOf: (i) => i.displayNumber,
      subtitleOf: (i) =>
          '${clientsById[i.clientId] ?? 'Unknown client'}  •  ${dateFmt.format(i.invoiceDate)}',
      searchableOf: (i) =>
          '${i.displayNumber} ${i.invoiceNumber ?? ''} ${clientsById[i.clientId] ?? ''}',
    );
    if (picked == null) return;
    setState(() => _selectedInvoice = picked);
    _scheduleAutoSave();
  }

  /// Loads the set of product IDs ordered by the selected client on or
  /// before the selected date — these are the only products returnable.
  Future<void> _loadOrderedProducts() async {
    final client = _selectedClient;
    if (client == null) return;
    setState(() {
      _orderedProductIds = {};
      _loadingOrderedProducts = true;
    });
    // Invoice dates are timestamps; include the entire selected day.
    final cutoff = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
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
    if (!mounted) return;
    setState(() {
      _orderedProductIds = ids;
      _loadingOrderedProducts = false;
    });
  }

  Future<void> _pickProduct() async {
    if (_selectedClient == null && !_noClient && !_clientOptional) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a client first.')));
      return;
    }
    final already = _items.map((i) => i.productId).toSet();
    final showAll = _noClient || _clientOptional;
    final available = showAll
        ? _products.where((p) => !already.contains(p.id)).toList()
        : _products
              .where(
                (p) =>
                    !already.contains(p.id) &&
                    _orderedProductIds.contains(p.id),
              )
              .toList();
    if (available.isEmpty) {
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
    final isBadOrder = _type == 'bad_order' || _type == 'stock_release';

    List<SearchFilter<Product>>? supplierFilters;
    final supplierIds = available.map((p) => p.supplierId).toSet();
    final supplierFilterList =
        supplierIds
            .where(_suppliersById.containsKey)
            .map(
              (id) => SearchFilter<Product>(
                label: _suppliersById[id]!,
                test: (p) => p.supplierId == id,
              ),
            )
            .toList()
          ..sort((a, b) => a.label.compareTo(b.label));
    if (supplierFilterList.isNotEmpty) supplierFilters = supplierFilterList;

    // Multi-pick mode: the dialog stays open after each selection so the
    // user can add several products in one go, closing only via "Done" or
    // dismissal.
    await showSearchPicker<Product>(
      context: context,
      title: 'Select Product',
      items: available,
      labelOf: (p) => p.name,
      searchableOf: (p) => '${p.name} ${p.productCode ?? ''}',
      filters: supplierFilters,
      leadingOf: isBadOrder
          ? (p) => Icon(
              _effectiveAvailable(p.id) > 0 ? Icons.check_circle : Icons.cancel,
              color: _effectiveAvailable(p.id) > 0 ? Colors.green : Colors.red,
              size: 20,
            )
          : null,
      subtitleOf: isBadOrder
          ? (p) {
              final qty = _effectiveAvailable(p.id);
              if (qty <= 0) return 'No stock';
              final ppb = p.piecesPerBox;
              final boxes = qty ~/ ppb;
              final pcs = qty % ppb;
              return boxes > 0
                  ? '$boxes box(es) + $pcs pcs  ($qty pcs total)'
                  : '$qty pcs available';
            }
          : null,
      subtitleStyleOf: isBadOrder
          ? (p) => TextStyle(
              color: _effectiveAvailable(p.id) > 0
                  ? Colors.green.shade700
                  : Colors.red,
            )
          : null,
      // Disable once already added (so it can't be picked twice in this
      // session) and, for bad orders, once out of stock.
      isDisabledOf: (p) =>
          _items.any((i) => i.productId == p.id) ||
          (isBadOrder && _effectiveAvailable(p.id) <= 0),
      onSelected: _addItem,
    );
  }

  void _addItem(Product picked) {
    setState(
      () => _items.add(
        _BoItem(
          productId: picked.id,
          productName: picked.name,
          piecesPerBox: picked.piecesPerBox,
        ),
      ),
    );
    _scheduleAutoSave();
  }

  Future<void> _save() async {
    if ((_selectedClient == null && !_noClient && !_clientOptional) ||
        _items.isEmpty) {
      return;
    }
    if (_type == 'stock_pulled_out' && _selectedInvoice == null) return;
    setState(() => _saving = true);
    _autoSaveTimer?.cancel();
    final now = DateTime.now();
    final clientId =
        (_noClient || (_clientOptional && _selectedClient == null))
        ? (await ref
                  .read(clientRepositoryProvider)
                  .getOrCreateNoClientPlaceholder())
              .id
        : _selectedClient!.id;
    final order = BadOrder(
      id: const Uuid().v4(),
      clientId: clientId,
      date: _selectedDate,
      type: _type,
      notes: _type == 'stock_release'
          ? _reason
          : (_notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
      createdAt: now,
      invoiceId: _type == 'stock_pulled_out' ? _selectedInvoice!.id : null,
    );
    final items = _items
        .map(
          (i) => BadOrderItem(
            id: const Uuid().v4(),
            badOrderId: order.id,
            productId: i.productId,
            unitType: 'piece',
            quantity: i.quantityInPieces,
          ),
        )
        .toList();
    final ppbMap = {for (final p in _products) p.id: p.piecesPerBox};
    await ref
        .read(badOrderRepositoryProvider)
        .save(order: order, items: items, piecesPerBoxByProduct: ppbMap);

    _finalized = true;
    if (_draftPersisted) {
      await ref.read(badOrderRepositoryProvider).discardDraft(_draftId);
    }
    ref.invalidate(badOrdersListProvider);
    ref.invalidate(inventoryListProvider);
    ref.invalidate(badOrderDraftsProvider);
    if (order.invoiceId != null) {
      ref.invalidate(invoicesListProvider);
      ref.invalidate(filteredInvoicesProvider);
    }
    if (mounted) context.go('/bad-orders');
  }

  Future<void> _cancel() async {
    _autoSaveTimer?.cancel();
    if (_draftPersisted && !_finalized) {
      await ref.read(badOrderRepositoryProvider).discardDraft(_draftId);
      _finalized = true;
      ref.invalidate(badOrderDraftsProvider);
    }
    if (mounted) context.go('/bad-orders');
  }

  @override
  void dispose() {
    final hadPendingSave = _autoSaveTimer?.isActive ?? false;
    _autoSaveTimer?.cancel();
    if (!_finalized) {
      if (_hasDraftContent) {
        // Flush any pending debounced save immediately so the draft shows up
        // in the list right away, instead of waiting for the next edit.
        if (hadPendingSave || !_draftPersisted) {
          _container
              ?.read(badOrderRepositoryProvider)
              .saveDraft(_buildDraftPayload());
        }
      } else if (_draftPersisted && widget.draftId == null) {
        // Only discard drafts created fresh during this session
        // (crash-recovery safety net). A resumed draft (widget.draftId !=
        // null) should remain saved so the user can come back to it again
        // later — only the explicit Cancel button discards those.
        _container?.read(badOrderRepositoryProvider).discardDraft(_draftId);
      }
      _container?.invalidate(badOrderDraftsProvider);
    }
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _container = ProviderScope.containerOf(context, listen: false);
    return AppScaffold(
      title: 'New Bad Order / Return',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type selector
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'bad_order',
                            icon: Icon(Icons.remove_shopping_cart, size: 16),
                            label: Text('Bad Order'),
                          ),
                          ButtonSegment(
                            value: 'return',
                            icon: Icon(Icons.undo, size: 16),
                            label: Text('Return'),
                          ),
                          ButtonSegment(
                            value: 'stock_release',
                            icon: Icon(Icons.output, size: 16),
                            label: Text('Stock Release'),
                          ),
                          ButtonSegment(
                            value: 'stock_pulled_out',
                            icon: Icon(Icons.move_down, size: 16),
                            label: Text('Stock Pulled out'),
                          ),
                        ],
                        selected: {_type},
                        onSelectionChanged: (s) {
                          setState(() {
                            _type = s.first;
                            _items.clear();
                            if (s.first != 'stock_release') _reason = null;
                            if (s.first != 'stock_pulled_out') {
                              _selectedInvoice = null;
                            }
                          });
                          _scheduleAutoSave();
                        },
                      ),
                      const SizedBox(height: 8),
                      if (_type == 'return')
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Returns will add the quantity back to inventory.',
                            style: TextStyle(fontSize: 12),
                          ),
                        )
                      else if (_type == 'stock_release')
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Stock releases will deduct the quantity from inventory (stock out).',
                            style: TextStyle(fontSize: 12),
                          ),
                        )
                      else if (_type == 'stock_pulled_out')
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Stock pulled out will add the quantity back to inventory '
                            '(it was never delivered) and reduce the linked invoice\'s '
                            'total and profit.',
                            style: TextStyle(fontSize: 12),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Bad orders will deduct the quantity from inventory (stock out).',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      if (_type == 'stock_release') ...[
                        const SizedBox(height: 8),
                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Reason *',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _reason,
                              isDense: true,
                              isExpanded: true,
                              hint: const Text('Select reason…'),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Missed delivery',
                                  child: Text('Missed delivery'),
                                ),
                                DropdownMenuItem(
                                  value: 'Give-aways',
                                  child: Text('Give-aways'),
                                ),
                                DropdownMenuItem(
                                  value: 'Warehouse BO',
                                  child: Text('Warehouse BO'),
                                ),
                              ],
                              onChanged: (v) {
                                setState(() => _reason = v);
                                _scheduleAutoSave();
                              },
                            ),
                          ),
                        ),
                      ],
                      if (_type == 'stock_pulled_out') ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickInvoice,
                          borderRadius: BorderRadius.circular(4),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Related Invoice *',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.search),
                            ),
                            child: Text(
                              _selectedInvoice == null
                                  ? 'Tap to search…'
                                  : '${_selectedInvoice!.displayNumber} — '
                                        '${formatCurrency(_selectedInvoice!.netTotal)}',
                              style: TextStyle(
                                color: _selectedInvoice == null
                                    ? Theme.of(context).hintColor
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      // Date
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(4),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today, size: 18),
                          ),
                          child: Text(
                            DateFormat('MMM dd, yyyy').format(_selectedDate),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Client
                      InkWell(
                        onTap: (_noClient && !_clientOptional)
                            ? null
                            : _pickClient,
                        borderRadius: BorderRadius.circular(4),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: _clientOptional
                                ? 'Client (optional)'
                                : 'Client',
                            border: const OutlineInputBorder(),
                            suffixIcon: (_noClient && !_clientOptional)
                                ? null
                                : const Icon(Icons.search),
                            enabled: !_noClient || _clientOptional,
                          ),
                          child: Text(
                            (_noClient && !_clientOptional)
                                ? 'No Client Specified'
                                : _selectedClient?.name ?? 'Tap to search…',
                            style: TextStyle(
                              color:
                                  ((_noClient && !_clientOptional) ||
                                      _selectedClient == null)
                                  ? Theme.of(context).hintColor
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      if (_allowNoClient && !_clientOptional)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                          title: const Text('No client specified'),
                          value: _noClient,
                          onChanged: (v) => _toggleNoClient(v ?? false),
                        ),
                      const SizedBox(height: 8),
                      // Notes (not shown for stock_release — reason is used instead)
                      if (_type != 'stock_release')
                        TextField(
                          controller: _notesCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Notes (optional)',
                          ),
                          onChanged: (_) => _scheduleAutoSave(),
                        ),
                    ],
                  ),
                ),
                // Items header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Items',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (_loadingOrderedProducts)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Product'),
                        onPressed: _loadingOrderedProducts
                            ? null
                            : _pickProduct,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _items.isEmpty
                      ? Center(
                          child: Text(
                            (_noClient || _clientOptional)
                                ? 'Add at least one product.'
                                : _selectedClient == null
                                ? 'Select a client, then add at least one product.'
                                : (!_loadingOrderedProducts &&
                                      _orderedProductIds.isEmpty)
                                ? 'This client has no orders on or before '
                                      '${DateFormat('MMM dd, yyyy').format(_selectedDate)} — '
                                      'nothing available to add.'
                                : 'Add at least one product.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _items.length,
                          itemBuilder: (_, i) => _BoItemTile(
                            item: _items[i],
                            availablePieces: _effectiveAvailable(
                              _items[i].productId,
                              excludeIndex: i,
                            ),
                            unitPrice: _prices[_items[i].productId] ?? 0,
                            isBadOrder:
                                _type == 'bad_order' || _type == 'stock_release',
                            onRemove: () {
                              setState(() => _items.removeAt(i));
                              _scheduleAutoSave();
                            },
                            onChanged: () {
                              setState(() {});
                              _scheduleAutoSave();
                            },
                          ),
                        ),
                ),
                if (_items.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Grand Total: ${formatCurrency(_grandTotal)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (_type == 'stock_pulled_out')
                          Text(
                            'Profit: ${formatCurrency(_profitTotal)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: _profitTotal >= 0
                                  ? Colors.green.shade700
                                  : Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ),
                // Save bar
                Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: _cancel,
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _canSave ? _save : null,
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _BoItem {
  final String productId;
  final String productName;
  final int piecesPerBox;
  int boxes = 0;
  int pieces = 0;

  _BoItem({
    required this.productId,
    required this.productName,
    required this.piecesPerBox,
  });

  int get quantityInPieces => boxes * piecesPerBox + pieces;
}

class _BoItemTile extends StatefulWidget {
  final _BoItem item;
  final int availablePieces;
  final double unitPrice;
  final bool isBadOrder;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _BoItemTile({
    required this.item,
    required this.availablePieces,
    required this.unitPrice,
    required this.isBadOrder,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<_BoItemTile> createState() => _BoItemTileState();
}

class _BoItemTileState extends State<_BoItemTile> {
  late TextEditingController _boxCtrl;
  late TextEditingController _pcsCtrl;

  @override
  void initState() {
    super.initState();
    _boxCtrl = TextEditingController(
      text: widget.item.boxes > 0 ? widget.item.boxes.toString() : '',
    );
    _pcsCtrl = TextEditingController(
      text: widget.item.pieces > 0 ? widget.item.pieces.toString() : '',
    );
  }

  @override
  void didUpdateWidget(_BoItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The ListView has no keys, so when a row above is removed, Flutter
    // reuses this State for a different _BoItem — resync the controllers.
    if (!identical(oldWidget.item, widget.item)) {
      _boxCtrl.text = widget.item.boxes > 0 ? widget.item.boxes.toString() : '';
      _pcsCtrl.text = widget.item.pieces > 0
          ? widget.item.pieces.toString()
          : '';
    }
  }

  @override
  void dispose() {
    _boxCtrl.dispose();
    _pcsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final avail = widget.availablePieces;
    final stockOk = !widget.isBadOrder || item.quantityInPieces <= avail;
    final ppb = item.piecesPerBox;
    final availBoxes = avail ~/ ppb;
    final availPcs = avail % ppb;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: stockOk ? null : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (widget.isBadOrder)
                    Text(
                      stockOk
                          ? 'Available: $availBoxes box(es) + $availPcs pcs'
                          : 'Only $availBoxes box(es) + $availPcs pcs available',
                      style: TextStyle(
                        fontSize: 12,
                        color: stockOk ? Colors.grey.shade600 : Colors.red,
                      ),
                    ),
                  Text(
                    formatCurrency(item.quantityInPieces * widget.unitPrice),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 64,
              child: TextField(
                controller: _boxCtrl,
                decoration: const InputDecoration(
                  labelText: 'Box',
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) {
                  item.boxes = int.tryParse(v) ?? 0;
                  widget.onChanged();
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 64,
              child: TextField(
                controller: _pcsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Pcs',
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) {
                  item.pieces = int.tryParse(v) ?? 0;
                  widget.onChanged();
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: widget.onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
