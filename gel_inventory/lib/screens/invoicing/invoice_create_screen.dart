import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../models/client.dart';
import '../../models/invoice.dart';
import '../../models/invoice_item.dart';
import '../../models/inventory_item.dart';
import '../../models/product.dart';
import '../../models/product_discount.dart';
import '../../models/product_price.dart';
import '../../repositories/client_repository.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/invoice_repository.dart';
import '../../repositories/product_discount_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../utils/currency_format.dart';
import '../../utils/pdf_generator.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/search_picker.dart';

// ── Line item ─────────────────────────────────────────────────────────────────

class _LineItem {
  final Product product;
  final ProductPrice price;
  final InventoryItem? inventory;
  final ProductDiscount? discount;
  String unitType = 'piece';
  int quantity = 0;
  bool isFree = false;
  // Highest "buy X get Y" cycle count the user has already been prompted
  // about for this line item (so we don't re-prompt on every keystroke,
  // but do re-prompt if the quantity grows enough for another cycle).
  int promptedFreeCycles = 0;
  // The free line item added in response to this item's promo, if any.
  _LineItem? linkedFreeItem;

  _LineItem({
    required this.product,
    required this.price,
    required this.inventory,
    required this.discount,
  });

  int get quantityInPieces =>
      unitType == 'box' ? quantity * product.piecesPerBox : quantity;

  bool get _thresholdMet =>
      !isFree && discount != null &&
      quantityInPieces >= discount!.minQuantityPieces;

  double get originalAmount => quantityInPieces * price.sellingPrice;

  double get discountAmount {
    if (!_thresholdMet) return 0;
    if (discount!.isPercent) {
      return originalAmount * discount!.discountValue / 100;
    } else {
      final multiples = quantityInPieces ~/ discount!.minQuantityPieces;
      return (multiples * discount!.discountValue).clamp(0.0, originalAmount);
    }
  }

  double get subtotal {
    if (isFree) return 0;
    return (originalAmount - discountAmount).clamp(0.0, double.infinity);
  }

  String get discountLabel {
    if (!_thresholdMet) return '';
    return discount!.isPercent
        ? 'Less ${discount!.discountValue.toStringAsFixed(0)}%'
        : 'Less ${formatCurrency(discount!.discountValue)}';
  }

  bool get hasEnoughStock =>
      inventory == null ? false : inventory!.quantityPieces >= quantityInPieces;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class InvoiceCreateScreen extends ConsumerStatefulWidget {
  /// If set, resumes the existing draft invoice with this id instead of
  /// starting a new one.
  final String? draftId;

  const InvoiceCreateScreen({super.key, this.draftId});

  @override
  ConsumerState<InvoiceCreateScreen> createState() =>
      _InvoiceCreateScreenState();
}

class _InvoiceCreateScreenState extends ConsumerState<InvoiceCreateScreen> {
  // Captured during build so it can still be used in dispose(), where `ref`
  // throws (the ConsumerStatefulElement is already marked disposed by then).
  ProviderContainer? _container;

  List<Client> _clients = [];
  List<Product> _products = [];
  Map<String, String> _supplierNames = {}; // productId → supplier name
  final Map<String, ProductPrice?> _priceCache = {};
  final Map<String, InventoryItem?> _inventoryCache = {};
  final Map<String, ProductDiscount?> _discountCache = {};
  Client? _selectedClient;
  static DateTime _lastInvoiceDate =
      DateTime.now().add(const Duration(days: 1));

  String _invoiceType  = 'delivery';
  String _paymentType  = 'cash';
  DateTime _invoiceDate = _lastInvoiceDate;
  String? _invoiceNumber;
  int? _displaySequenceNumber;
  final List<_LineItem> _lineItems = [];
  final _notesCtrl = TextEditingController();
  final _actualAmountCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  // ── Auto-save (draft) ────────────────────────────────────────────────────
  late final InvoiceRepository _invoiceRepo;
  late String _invoiceId;
  late DateTime _createdAt;
  Timer? _autoSaveTimer;
  bool _draftPersisted = false;
  bool _finalized = false;
  bool _autoSaving = false;
  DateTime? _lastAutoSaved;

  @override
  void initState() {
    super.initState();
    _invoiceRepo = ref.read(invoiceRepositoryProvider);
    _invoiceId = widget.draftId ?? const Uuid().v4();
    _createdAt = DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    final clients   = await ref.read(clientRepositoryProvider).getAll();
    final products  = await ref.read(productRepositoryProvider).getAll();
    final suppliers = await ref.read(supplierRepositoryProvider).getAll();
    final suppMap = {for (final s in suppliers) s.id: s.name};

    String? invoiceNum;
    if (widget.draftId != null) {
      await _loadDraft(widget.draftId!, clients, products);
      invoiceNum = _invoiceNumber;
    } else {
      invoiceNum = await ref
          .read(invoiceRepositoryProvider)
          .generateInvoiceNumber(_invoiceDate);
    }

    final displaySeq = _displaySequenceNumber ??
        await ref.read(invoiceRepositoryProvider).getNextSequenceNumber();

    setState(() {
      _clients  = clients;
      _products = products;
      _supplierNames = {for (final p in products) p.id: suppMap[p.supplierId] ?? ''};
      _invoiceNumber = invoiceNum;
      _displaySequenceNumber = displaySeq;
      _loading  = false;
    });
  }

  // Loads a previously auto-saved draft invoice and reconstructs the
  // _lineItems list from its stored items.
  Future<void> _loadDraft(
      String draftId, List<Client> clients, List<Product> products) async {
    final draft = await _invoiceRepo.getById(draftId);
    if (draft == null) return;

    _createdAt = draft.createdAt;
    _draftPersisted = true;
    _selectedClient =
        clients.where((c) => c.id == draft.clientId).firstOrNull;
    _invoiceDate = draft.invoiceDate;
    _invoiceNumber = draft.invoiceNumber;
    _displaySequenceNumber = draft.sequenceNumber;
    _invoiceType = draft.invoiceType;
    _paymentType = draft.paymentType;
    _notesCtrl.text = draft.notes ?? '';
    _actualAmountCtrl.text = draft.actualAmount != null
        ? draft.actualAmount!.toStringAsFixed(2)
        : '';

    final items = await _invoiceRepo.getItems(draftId);
    final productsById = {for (final p in products) p.id: p};

    for (final dItem in items) {
      final product = productsById[dItem.productId];
      if (product == null) continue;

      var price = _priceCache[product.id];
      if (!_priceCache.containsKey(product.id)) {
        price = await ref
            .read(productRepositoryProvider)
            .getCurrentPrice(product.id);
        _priceCache[product.id] = price;
      }
      var inv = _inventoryCache[product.id];
      if (!_inventoryCache.containsKey(product.id)) {
        inv = await ref
            .read(inventoryRepositoryProvider)
            .getByProductId(product.id);
        _inventoryCache[product.id] = inv;
      }
      var disc = _discountCache[product.id];
      if (!_discountCache.containsKey(product.id)) {
        disc = await ref
            .read(productDiscountRepositoryProvider)
            .getForProduct(product.id);
        _discountCache[product.id] = disc;
      }
      price ??= ProductPrice(
        id: '',
        productId: product.id,
        withdrawalPrice: 0,
        sellingPrice: dItem.pricePerPiece,
        effectiveFrom: DateTime.now(),
      );

      final ppb = product.piecesPerBox;
      final lineItem = _LineItem(
        product: product,
        price: price,
        inventory: inv,
        discount: disc,
      )
        ..unitType = dItem.unitType
        ..quantity = dItem.unitType == 'box' && ppb > 0
            ? dItem.quantity ~/ ppb
            : dItem.quantity
        ..isFree = dItem.isFree;

      if (disc != null && disc.isBuyXGetY && disc.minQuantityPieces > 0) {
        lineItem.promptedFreeCycles =
            dItem.quantity ~/ disc.minQuantityPieces;
      }

      _lineItems.add(lineItem);
    }

    // Re-link previously added free items to the line that grants them.
    for (final item in _lineItems) {
      if (item.isFree || item.discount == null || !item.discount!.isBuyXGetY) {
        continue;
      }
      item.linkedFreeItem = _lineItems.where((other) =>
          other.isFree &&
          other.product.id == item.product.id &&
          other != item).firstOrNull;
    }
  }

  // Debounce auto-saving the invoice as a draft so rapid edits don't trigger
  // a DB write on every keystroke.
  void _scheduleAutoSave() {
    if (_finalized) return;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), _autoSaveDraft);
  }

  // Persists the current invoice as a draft (status == 'draft'). Drafts
  // never affect inventory and are excluded from invoice list queries.
  // Requires a client to be selected since clientId is a foreign key.
  bool get _hasDraftContent =>
      _selectedClient != null && _lineItems.isNotEmpty;

  double? get _actualAmount =>
      double.tryParse(_actualAmountCtrl.text.trim());

  ({Invoice invoice, List<InvoiceItem> items}) _buildDraftPayload() {
    final invoice = Invoice(
      id: _invoiceId,
      clientId: _selectedClient!.id,
      invoiceDate: _invoiceDate,
      totalAmount: _total,
      status: 'draft',
      createdAt: _createdAt,
      invoiceNumber: _invoiceNumber,
      invoiceType: _invoiceType,
      paymentType: _paymentType,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      actualAmount: _actualAmount,
    );
    final items = _lineItems.map((li) => InvoiceItem(
          id: const Uuid().v4(),
          invoiceId: _invoiceId,
          productId: li.product.id,
          unitType: li.unitType,
          quantity: li.quantityInPieces,
          pricePerPiece: li.price.sellingPrice,
          subtotal: li.subtotal,
          isFree: li.isFree,
          discountPercent: (li._thresholdMet && li.discount!.isPercent)
              ? li.discount!.discountValue
              : 0,
        )).toList();
    return (invoice: invoice, items: items);
  }

  Future<void> _autoSaveDraft() async {
    if (_finalized || !mounted) return;
    if (!_hasDraftContent) return;

    setState(() => _autoSaving = true);
    final payload = _buildDraftPayload();
    await _invoiceRepo.saveDraftInvoice(
        invoice: payload.invoice, items: payload.items);
    _draftPersisted = true;
    ref.invalidate(draftInvoicesProvider);
    if (mounted) {
      setState(() {
        _autoSaving = false;
        _lastAutoSaved = DateTime.now();
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _invoiceDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _invoiceDate = picked);
      _lastInvoiceDate = picked;
      final num = await ref
          .read(invoiceRepositoryProvider)
          .generateInvoiceNumber(picked);
      if (mounted) setState(() => _invoiceNumber = num);
      _scheduleAutoSave();
    }
  }

  Future<void> _pickClient() async {
    final picked = await showSearchPicker<Client>(
      context: context,
      title: 'Select Client / Store',
      items: _clients,
      labelOf: (c) => c.name,
      subtitleOf: (c) => c.address,
      onAdd: (existing) => _promptAddClient(existing),
    );
    if (picked != null) {
      setState(() => _selectedClient = picked);
      _scheduleAutoSave();
    }
  }

  Future<Client?> _promptAddClient(List<Client> existing) async {
    final nameCtrl    = TextEditingController();
    final addressCtrl = TextEditingController();
    final formKey     = GlobalKey<FormState>();

    return showDialog<Client>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Client / Store'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Name *', isDense: true),
                autofocus: true,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Name is required';
                  final name    = v.trim().toLowerCase();
                  final address = addressCtrl.text.trim().toLowerCase();
                  final dup = existing.any((c) =>
                      c.name.trim().toLowerCase() == name &&
                      (c.address?.trim().toLowerCase() ?? '') == address);
                  if (dup) return 'A client with the same name and address already exists';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: addressCtrl,
                decoration: const InputDecoration(
                    labelText: 'Address', isDense: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final newClient = Client(
                id: const Uuid().v4(),
                name: nameCtrl.text.trim(),
                address: addressCtrl.text.trim().isEmpty
                    ? null
                    : addressCtrl.text.trim(),
                createdAt: DateTime.now(),
              );
              await ref
                  .read(clientRepositoryProvider)
                  .upsert(newClient);
              // Keep local _clients list in sync and refresh all watchers
              // (client list page, invoice list name lookup, etc.).
              setState(() => _clients.insert(0, newClient));
              ref.invalidate(clientsListProvider);
              if (ctx.mounted) Navigator.pop(ctx, newClient);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickProduct() async {
    final available = _products;
    if (available.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No products available.')));
      }
      return;
    }

    await Future.wait(available.map((p) async {
      if (!_inventoryCache.containsKey(p.id)) {
        _inventoryCache[p.id] = await ref
            .read(inventoryRepositoryProvider)
            .getByProductId(p.id);
      }
    }));

    if (!mounted) return;

    final supplierChips = <String, String>{};
    for (final p in available) {
      final name = _supplierNames[p.id];
      if (name != null && name.isNotEmpty) supplierChips[p.supplierId] = name;
    }
    final supplierFilters = (supplierChips.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value)))
        .map((e) => SearchFilter<Product>(
              label: e.value,
              test: (p) => p.supplierId == e.key,
            ))
        .toList();

    await showSearchPicker<Product>(
      context: context,
      title: 'Select Product',
      items: available,
      labelOf: (p) => '${p.name} x ${p.piecesPerBox}',
      searchableOf: (p) => '${p.name} ${p.productCode ?? ''}',
      leadingOf: (p) => _stockIndicator(_effectiveAvailable(p.id)),
      subtitleOf: (p) => _stockLabel(p, _effectiveAvailable(p.id)),
      subtitleStyleOf: (p) {
        final qty = _effectiveAvailable(p.id);
        return TextStyle(
            color: qty > 0 ? Colors.green.shade700 : Colors.red);
      },
      isDisabledOf: (p) => _effectiveAvailable(p.id) <= 0,
      onSelected: (p) => _addProduct(p),
      filters: supplierFilters,
    );
  }

  Widget _stockIndicator(int qty) => Icon(
        qty > 0 ? Icons.check_circle : Icons.cancel,
        color: qty > 0 ? Colors.green : Colors.red,
        size: 20,
      );

  String _stockLabel(Product p, int qty) {
    if (qty <= 0) return 'No stock';
    final boxes = qty ~/ p.piecesPerBox;
    final rem = qty % p.piecesPerBox;
    return boxes > 0
        ? '$boxes box(es) + $rem pcs  ($qty pcs total)'
        : '$qty pcs available';
  }

  Future<void> _addProduct(Product product) async {
    var price = _priceCache[product.id];
    if (!_priceCache.containsKey(product.id)) {
      price = await ref
          .read(productRepositoryProvider)
          .getCurrentPrice(product.id);
      _priceCache[product.id] = price;
    }
    var inv = _inventoryCache[product.id];
    if (!_inventoryCache.containsKey(product.id)) {
      inv = await ref
          .read(inventoryRepositoryProvider)
          .getByProductId(product.id);
      _inventoryCache[product.id] = inv;
    }
    var disc = _discountCache[product.id];
    if (!_discountCache.containsKey(product.id)) {
      disc = await ref
          .read(productDiscountRepositoryProvider)
          .getForProduct(product.id);
      _discountCache[product.id] = disc;
    }
    if (price == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No price set for this product.')),
        );
      }
      return;
    }
    setState(() {
      _lineItems.add(_LineItem(
        product: product,
        price: price!,
        inventory: inv,
        discount: disc,
      ));
    });
    _scheduleAutoSave();
  }

  // Checks whether the entered quantity now satisfies a "buy X get Y free"
  // promo for this line, and if so, asks the user whether to add the free
  // item to the invoice. Re-prompts if the quantity grows enough to reach
  // another cycle of the promo, even if a previous prompt was declined.
  Future<void> _maybeOfferFreeItem(_LineItem item) async {
    final discount = item.discount;
    if (item.isFree || discount == null || !discount.isBuyXGetY) return;
    final freeQtyPieces = discount.freeQuantityPieces ?? 0;
    if (freeQtyPieces <= 0) return;

    final cycles = item.quantityInPieces ~/ discount.minQuantityPieces;
    if (cycles <= item.promptedFreeCycles) return;
    item.promptedFreeCycles = cycles;
    if (cycles <= 0) return;

    final ppb = item.product.piecesPerBox;
    final buyBoxes = ppb > 0 ? discount.minQuantityPieces ~/ ppb : discount.minQuantityPieces;

    final freeUnit = discount.freeQuantityUnit;
    final freeQtyPerCycle =
        freeUnit == 'box' && ppb > 0 ? freeQtyPieces ~/ ppb : freeQtyPieces;
    final totalFreeQty = freeQtyPerCycle * cycles;
    final freeUnitLabel = freeUnit == 'box' ? 'box(es)' : 'piece(s)';

    final add = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Free Item Available'),
        content: Text(
          '${item.product.name} qualifies for a "Buy $buyBoxes box(es) '
          'get $freeQtyPerCycle $freeUnitLabel free" promo.\n\n'
          'Add $totalFreeQty $freeUnitLabel of ${item.product.name} to this invoice for free?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (add == true && mounted) {
      setState(() {
        final existing = item.linkedFreeItem;
        if (existing != null && _lineItems.contains(existing)) {
          existing.quantity = totalFreeQty;
        } else {
          final freeItem = _LineItem(
            product: item.product,
            price: item.price,
            inventory: item.inventory,
            discount: item.discount,
          )
            ..unitType = freeUnit == 'box' ? 'box' : 'piece'
            ..quantity = totalFreeQty
            ..isFree = true;
          item.linkedFreeItem = freeItem;
          _lineItems.add(freeItem);
        }
      });
      _scheduleAutoSave();
    }
  }

  // Total pieces already committed to _lineItems for a product, optionally
  // excluding one index (used so a tile can check its own slot fairly).
  int _committedPieces(String productId, {int? excludeIndex}) {
    int total = 0;
    for (int i = 0; i < _lineItems.length; i++) {
      if (i == excludeIndex) continue;
      if (_lineItems[i].product.id == productId) {
        total += _lineItems[i].quantityInPieces;
      }
    }
    return total;
  }

  int _effectiveAvailable(String productId, {int? excludeIndex}) {
    final inv = _inventoryCache[productId]?.quantityPieces ?? 0;
    return (inv - _committedPieces(productId, excludeIndex: excludeIndex))
        .clamp(0, inv);
  }

  double get _total =>
      _lineItems.fold(0.0, (sum, item) => sum + item.subtotal);

  bool get _canPrint {
    if (_selectedClient == null || _lineItems.isEmpty) return false;
    for (int i = 0; i < _lineItems.length; i++) {
      final item = _lineItems[i];
      if (item.quantity <= 0) { return false; }
      if (_effectiveAvailable(item.product.id, excludeIndex: i) <
          item.quantityInPieces) { return false; }
    }
    return true;
  }

  Future<({Invoice invoice, List<InvoiceItem> items})> _persistInvoice() async {
    _autoSaveTimer?.cancel();
    _finalized = true;

    final invoice = Invoice(
      id: _invoiceId,
      clientId: _selectedClient!.id,
      invoiceDate: _invoiceDate,
      totalAmount: _total,
      status: 'printed',
      createdAt: _createdAt,
      invoiceNumber: _invoiceNumber,
      invoiceType:  _invoiceType,
      paymentType:  _paymentType,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      actualAmount: _actualAmount,
    );

    final items = _lineItems.map((li) {
      return InvoiceItem(
        id: const Uuid().v4(),
        invoiceId: _invoiceId,
        productId: li.product.id,
        unitType: li.unitType,
        quantity: li.quantityInPieces,
        pricePerPiece: li.price.sellingPrice,
        subtotal: li.subtotal,
        isFree: li.isFree,
        discountPercent: (li._thresholdMet && li.discount!.isPercent)
            ? li.discount!.discountValue
            : 0,
      );
    }).toList();

    final Invoice savedInvoice;
    if (_draftPersisted) {
      savedInvoice =
          await _invoiceRepo.finalizeDraft(invoice: invoice, items: items);
    } else {
      savedInvoice = await _invoiceRepo.saveInvoice(invoice: invoice, items: items);
    }

    ref.invalidate(invoicesListProvider);
    ref.invalidate(filteredInvoicesProvider);
    ref.invalidate(inventoryListProvider);
    ref.invalidate(draftInvoicesProvider);

    return (invoice: savedInvoice, items: items);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _persistInvoice();
    if (mounted) context.go('/invoices');
  }

  Future<void> _print() async {
    setState(() => _saving = true);
    final persisted = await _persistInvoice();

    final productsById = {
      for (final li in _lineItems) li.product.id: li.product
    };
    await printInvoice(
      invoice: persisted.invoice,
      client: _selectedClient!,
      items: persisted.items,
      productsById: productsById,
    );

    if (mounted) context.go('/invoices');
  }

  Future<void> _cancel() async {
    _autoSaveTimer?.cancel();
    if (_draftPersisted && !_finalized) {
      await _invoiceRepo.discardDraft(_invoiceId);
      _finalized = true;
      ref.invalidate(draftInvoicesProvider);
    }
    if (mounted) context.go('/invoices');
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
          final payload = _buildDraftPayload();
          _invoiceRepo.saveDraftInvoice(
              invoice: payload.invoice, items: payload.items);
        }
      } else if (_draftPersisted && widget.draftId == null) {
        // Only discard drafts created fresh during this session
        // (crash-recovery safety net). A resumed draft (widget.draftId !=
        // null) should remain saved so the user can come back to it again
        // later — only the explicit Cancel button discards those.
        _invoiceRepo.discardDraft(_invoiceId);
      }
      _container?.invalidate(draftInvoicesProvider);
    }
    _notesCtrl.dispose();
    _actualAmountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _container = ProviderScope.containerOf(context, listen: false);
    return AppScaffold(
      title: 'New Invoice',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Invoice ID header
                Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        'Invoice #: ${_displaySequenceNumber != null ? _displaySequenceNumber!.toString().padLeft(8, '0') : '...'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      if (_autoSaving)
                        Text(
                          'Saving draft…',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant),
                        )
                      else if (_lastAutoSaved != null)
                        Text(
                          'Draft saved at ${DateFormat('HH:mm').format(_lastAutoSaved!)}',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),

                // Invoice type + payment type
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                              value: 'delivery',
                              icon: Icon(Icons.local_shipping, size: 16),
                              label: Text('Delivery')),
                          ButtonSegment(
                              value: 'walk_in',
                              icon: Icon(Icons.storefront, size: 16),
                              label: Text('Walk-in')),
                        ],
                        selected: {_invoiceType},
                        onSelectionChanged: (s) {
                          setState(() => _invoiceType = s.first);
                          _scheduleAutoSave();
                        },
                      ),
                      const Spacer(),
                      DropdownButton<String>(
                        value: _paymentType,
                        isDense: true,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'cash',    child: Text('Cash')),
                          DropdownMenuItem(value: 'check',   child: Text('Check')),
                          DropdownMenuItem(value: 'credit',  child: Text('Credit')),
                          DropdownMenuItem(value: 'partial', child: Text('Partial')),
                        ],
                        onChanged: (v) {
                          setState(() => _paymentType = v!);
                          _scheduleAutoSave();
                        },
                      ),
                    ],
                  ),
                ),

                // Date selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(4),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Invoice Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today, size: 18),
                      ),
                      child: Text(
                        DateFormat('MMM dd, yyyy').format(_invoiceDate),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Client selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: InkWell(
                    onTap: _pickClient,
                    borderRadius: BorderRadius.circular(4),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Client / Store',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                      child: Text(
                        _selectedClient?.name ?? 'Tap to search…',
                        style: TextStyle(
                          color: _selectedClient == null
                              ? Theme.of(context).hintColor
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Notes (internal only — not printed on the invoice)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _notesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Notes (not included when printing)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    maxLines: 2,
                    onChanged: (_) => _scheduleAutoSave(),
                  ),
                ),
                const SizedBox(height: 8),

                // Actual amount on referenced receipt (optional, internal only)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _actualAmountCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Actual Amount (referenced receipt, optional)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    onChanged: (_) => _scheduleAutoSave(),
                  ),
                ),
                const SizedBox(height: 4),

                // Add item row
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      const Text('Items',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Product'),
                        onPressed: _pickProduct,
                      ),
                    ],
                  ),
                ),

                // Line items
                Expanded(
                  child: _lineItems.isEmpty
                      ? const Center(
                          child: Text('Tap "Add Product" to add items'))
                      : ListView.builder(
                          itemCount: _lineItems.length,
                          itemBuilder: (ctx, i) => _LineItemTile(
                            item: _lineItems[i],
                            effectiveAvailable: _effectiveAvailable(
                                _lineItems[i].product.id,
                                excludeIndex: i),
                            onRemove: () {
                              setState(() => _lineItems.removeAt(i));
                              _scheduleAutoSave();
                            },
                            onChanged: () {
                              setState(() {});
                              _scheduleAutoSave();
                            },
                            onQuantityEntered: (item) =>
                                _maybeOfferFreeItem(item),
                          ),
                        ),
                ),

                // Total + actions
                Container(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Total: ${formatCurrency(_total)}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${_lineItems.length} item(s)',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: _cancel,
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.save_outlined),
                        label: const Text('Save'),
                        onPressed:
                            _canPrint && !_saving ? _save : null,
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white))
                            : const Icon(Icons.print),
                        label: const Text('Print'),
                        onPressed:
                            _canPrint && !_saving ? _print : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Line item tile ────────────────────────────────────────────────────────────

class _LineItemTile extends StatefulWidget {
  final _LineItem item;
  final int effectiveAvailable;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  final ValueChanged<_LineItem> onQuantityEntered;

  const _LineItemTile({
    required this.item,
    required this.effectiveAvailable,
    required this.onRemove,
    required this.onChanged,
    required this.onQuantityEntered,
  });

  @override
  State<_LineItemTile> createState() => _LineItemTileState();
}

class _LineItemTileState extends State<_LineItemTile> {
  late TextEditingController _qtyCtrl;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(
      text: widget.item.quantity > 0 ? widget.item.quantity.toString() : '',
    );
  }

  @override
  void didUpdateWidget(_LineItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.item, widget.item)) {
      final text =
          widget.item.quantity > 0 ? widget.item.quantity.toString() : '';
      if (_qtyCtrl.text != text) _qtyCtrl.text = text;
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  String _availLabel(_LineItem item, int availQty, bool stockOk) {
    final ppb = item.product.piecesPerBox;
    final boxes = availQty ~/ ppb;
    final pcs = availQty % ppb;
    final qty = boxes > 0
        ? '$boxes box(es)${pcs > 0 ? ' + $pcs pcs' : ''}'
        : '$availQty pcs';
    return stockOk ? 'Available: $qty' : 'Only $qty available';
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final availQty = widget.effectiveAvailable;
    final stockOk = item.isFree || availQty >= item.quantityInPieces;
    final hasDiscount = item.discountAmount > 0;

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
                  Text('${item.product.name} x ${item.product.piecesPerBox}',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    _availLabel(item, availQty, stockOk),
                    style: TextStyle(
                        color: stockOk
                            ? Colors.grey.shade600
                            : Colors.red,
                        fontSize: 12),
                  ),
                  if (item.isFree)
                    Text('FREE',
                        style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12))
                  else if (hasDiscount) ...[
                    Text(
                      'Original:  ${formatCurrency(item.originalAmount)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      '${item.discountLabel}:  -${formatCurrency(item.discountAmount)}',
                      style: TextStyle(
                          color: Colors.green.shade700, fontSize: 12),
                    ),
                    Text(
                      'Subtotal:  ${formatCurrency(item.subtotal)}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ] else
                    Text(
                      'Subtotal:  ${formatCurrency(item.subtotal)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
            // Free toggle
            IconButton(
              icon: Icon(
                item.isFree ? Icons.card_giftcard : Icons.card_giftcard_outlined,
                color: item.isFree ? Colors.green : Colors.grey,
                size: 20,
              ),
              tooltip: item.isFree ? 'Remove free' : 'Mark as free',
              onPressed: () {
                setState(() => item.isFree = !item.isFree);
                widget.onChanged();
              },
            ),
            // Unit toggle
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'piece', label: Text('Pcs')),
                ButtonSegment(value: 'box', label: Text('Box')),
              ],
              selected: {item.unitType},
              onSelectionChanged: (s) {
                setState(() => item.unitType = s.first);
                widget.onChanged();
                widget.onQuantityEntered(item);
              },
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 70,
              child: TextField(
                controller: _qtyCtrl,
                enabled: widget.effectiveAvailable > 0,
                decoration: const InputDecoration(
                    labelText: 'Qty', isDense: true),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                onChanged: (v) {
                  item.quantity = int.tryParse(v) ?? 0;
                  widget.onChanged();
                  widget.onQuantityEntered(item);
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
