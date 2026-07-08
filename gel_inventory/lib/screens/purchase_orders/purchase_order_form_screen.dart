import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/product.dart';
import '../../models/product_price.dart';
import '../../models/purchase_order.dart';
import '../../models/purchase_order_item.dart';
import '../../models/product_supplier_price.dart';
import '../../models/supplier.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/product_supplier_price_repository.dart';
import '../../repositories/purchase_order_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../utils/currency_format.dart';
import '../../utils/pdf_generator.dart';
import '../../utils/product_format.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/search_picker.dart';

// ── Line item ─────────────────────────────────────────────────────────────────

class _LineItem {
  final Product product;
  final double systemPrice;
  bool isFree;
  final TextEditingController supplierPriceCtrl;
  final TextEditingController casesCtrl;
  final double Function() discountMultiplier;

  _LineItem({
    required this.product,
    required this.systemPrice,
    required this.discountMultiplier,
    this.isFree = false,
    double? supplierPrice,
    double cases = 0,
  })  : supplierPriceCtrl = TextEditingController(
          text: (supplierPrice ?? systemPrice).toStringAsFixed(2),
        ),
        casesCtrl = TextEditingController(
          text: cases > 0 ? formatNumber(cases) : '',
        );

  double get cases => double.tryParse(casesCtrl.text) ?? 0;

  /// Supplier price (box) as typed, before discounts/VAT are applied.
  double get rawPrice =>
      double.tryParse(supplierPriceCtrl.text) ?? systemPrice;

  /// Supplier price (box) after cascading discounts and optional VAT — this
  /// is the value actually used for the amount computation.
  double get price => rawPrice * discountMultiplier();

  double get amount => isFree ? 0 : cases * price;

  bool get pricesDiffer =>
      (price * 100).round() != (systemPrice * 100).round();
}

// ── Screen ────────────────────────────────────────────────────────────────────

class PurchaseOrderFormScreen extends ConsumerStatefulWidget {
  final String? orderId;
  final String? draftId;

  const PurchaseOrderFormScreen({super.key, this.orderId, this.draftId});

  @override
  ConsumerState<PurchaseOrderFormScreen> createState() =>
      _PurchaseOrderFormScreenState();
}

class _PurchaseOrderFormScreenState
    extends ConsumerState<PurchaseOrderFormScreen> {
  bool get isNew => widget.orderId == null;

  late String _orderId;
  late DateTime _createdAt;
  DateTime _orderDate = DateTime.now();
  Supplier? _selectedSupplier;
  String _status = 'open';
  final _referenceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final List<_LineItem> _lineItems = [];
  final List<double> _discountPercents = [];
  bool _vatEnabled = false;
  final _productPickerState = SearchPickerState();

  List<Supplier> _suppliers = [];
  List<Product> _products = [];
  bool _loading = true;
  bool _saving = false;

  Timer? _autoSaveTimer;
  bool _draftPersisted = false;
  bool _finalized = false;
  bool _autoSaving = false;
  DateTime? _lastAutoSaved;
  ProviderContainer? _container;

  @override
  void initState() {
    super.initState();
    _orderId = widget.orderId ?? widget.draftId ?? const Uuid().v4();
    _createdAt = DateTime.now();
    _loadData();
  }

  @override
  void dispose() {
    final hadPendingSave = _autoSaveTimer?.isActive ?? false;
    _autoSaveTimer?.cancel();
    if (!_finalized && isNew) {
      final repo = _container?.read(purchaseOrderRepositoryProvider);
      if (repo != null) {
        if (_hasDraftContent) {
          if (hadPendingSave || !_draftPersisted) {
            final payload = _buildDraftPayload();
            repo.saveDraftOrder(order: payload.order, items: payload.items);
          }
        } else if (_draftPersisted && widget.draftId == null) {
          repo.discardDraft(_orderId);
        }
        _container?.invalidate(draftPurchaseOrdersProvider);
      }
    }
    _referenceCtrl.dispose();
    _notesCtrl.dispose();
    for (final item in _lineItems) {
      item.casesCtrl.dispose();
      item.supplierPriceCtrl.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    final suppliers = await ref.read(supplierRepositoryProvider).getAll();
    final products = await ref.read(productRepositoryProvider).getAll();

    final loadId = widget.orderId ?? widget.draftId;
    if (loadId != null) {
      final repo = ref.read(purchaseOrderRepositoryProvider);
      final order = await repo.getById(loadId);
      if (order != null) {
        _createdAt = order.createdAt;
        _orderDate = order.orderDate;
        _status = order.status == 'draft' ? 'open' : order.status;
        _referenceCtrl.text = order.referenceNumber ?? '';
        _notesCtrl.text = order.notes ?? '';
        _selectedSupplier =
            suppliers.where((s) => s.id == order.supplierId).firstOrNull;
        if (widget.draftId != null) _draftPersisted = true;
        _discountPercents.addAll(order.discountPercents);
        _vatEnabled = order.vatEnabled;

        final items = await repo.getItems(order.id);
        final productsById = {for (final p in products) p.id: p};
        for (final it in items) {
          final product = productsById[it.productId];
          if (product == null) continue;
          final currentPrice = await ref
              .read(productRepositoryProvider)
              .getCurrentPrice(product.id);
          _lineItems.add(_LineItem(
            product: product,
            systemPrice: currentPrice != null
                ? currentPrice.withdrawalPrice * product.piecesPerBox
                : it.systemPrice,
            discountMultiplier: () => _discountMultiplier,
            isFree: it.isFree,
            supplierPrice: it.rawPrice ?? it.price,
            cases: it.cases,
          ));
        }
      }
    }

    setState(() {
      _suppliers = suppliers;
      _products = products;
      _loading = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _orderDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _orderDate = picked);
      _scheduleAutoSave();
    }
  }

  Future<void> _pickSupplier() async {
    final sorted = List<Supplier>.from(_suppliers)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final picked = await showSearchPicker<Supplier>(
      context: context,
      title: 'Select Supplier',
      items: sorted,
      labelOf: (s) => s.name,
      subtitleOf: (s) => s.address,
      onAdd: (existing) => _promptAddSupplier(existing),
    );
    if (picked != null) {
      setState(() => _selectedSupplier = picked);
      _scheduleAutoSave();
    }
  }

  Future<Supplier?> _promptAddSupplier(List<Supplier> existing) async {
    final nameCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<Supplier>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Supplier'),
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
                  final name = v.trim().toLowerCase();
                  final dup = existing
                      .any((s) => s.name.trim().toLowerCase() == name);
                  if (dup) return 'A supplier with this name already exists';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: contactCtrl,
                decoration: const InputDecoration(
                    labelText: 'Contact', isDense: true),
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
              final newSupplier = Supplier(
                id: const Uuid().v4(),
                name: nameCtrl.text.trim(),
                contact: contactCtrl.text.trim().isEmpty
                    ? null
                    : contactCtrl.text.trim(),
                address: addressCtrl.text.trim().isEmpty
                    ? null
                    : addressCtrl.text.trim(),
                createdAt: DateTime.now(),
              );
              await ref.read(supplierRepositoryProvider).upsert(newSupplier);
              setState(() => _suppliers.insert(0, newSupplier));
              ref.invalidate(suppliersListProvider);
              if (ctx.mounted) Navigator.pop(ctx, newSupplier);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickProduct() async {
    final sorted = List<Product>.from(_products)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final suppliersById = {for (final s in _suppliers) s.id: s.name};
    final supplierFilters = sorted
        .map((p) => p.supplierId)
        .toSet()
        .where(suppliersById.containsKey)
        .map((id) => SearchFilter<Product>(
              label: suppliersById[id]!,
              test: (p) => p.supplierId == id,
            ))
        .toList()
      ..sort((a, b) => a.label.compareTo(b.label));

    // Default the filter to the currently selected supplier (if any), but
    // still let the user switch to another supplier or "All Suppliers".
    _productPickerState.filterLabel = _selectedSupplier?.name;

    await showSearchPicker<Product>(
      context: context,
      title: 'Select Product',
      items: sorted,
      labelOf: (p) => p.name,
      searchableOf: (p) => '${p.name} ${p.productCode ?? ''}',
      filters: supplierFilters,
      state: _productPickerState,
      onAdd: (existing) => _promptAddProduct(existing),
      onSelected: (p) => _addProduct(p),
    );
  }

  Future<Product?> _promptAddProduct(List<Product> existing) async {
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Select a supplier first.')));
      return null;
    }

    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final piecesCtrl = TextEditingController();
    final withdrawalCtrl = TextEditingController();
    final sellingCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<Product>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Product'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Name *', isDense: true),
                  autofocus: true,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Product Code', isDense: true),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: piecesCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Pieces per Box *', isDense: true),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: withdrawalCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Withdrawal Price *', isDense: true),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                  ],
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n < 0) return 'Enter a valid price';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: sellingCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Selling Price *', isDense: true),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                  ],
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n < 0) return 'Enter a valid price';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final newProduct = Product(
                id: const Uuid().v4(),
                name: nameCtrl.text.trim(),
                productCode: codeCtrl.text.trim().isEmpty
                    ? null
                    : codeCtrl.text.trim(),
                supplierId: _selectedSupplier!.id,
                piecesPerBox: int.parse(piecesCtrl.text),
                createdAt: DateTime.now(),
              );
              await ref
                  .read(productRepositoryProvider)
                  .upsertProduct(newProduct);
              await ref.read(productRepositoryProvider).addPrice(ProductPrice(
                    id: const Uuid().v4(),
                    productId: newProduct.id,
                    withdrawalPrice: double.parse(withdrawalCtrl.text),
                    sellingPrice: double.parse(sellingCtrl.text),
                    effectiveFrom: DateTime.now(),
                  ));
              setState(() => _products.insert(0, newProduct));
              ref.invalidate(productsListProvider);
              if (ctx.mounted) Navigator.pop(ctx, newProduct);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addProduct(Product product) async {
    final price = await ref
        .read(productRepositoryProvider)
        .getCurrentPrice(product.id);
    final supplierPrice = await ref
        .read(productSupplierPriceRepositoryProvider)
        .getForProduct(product.id);
    setState(() {
      _lineItems.add(_LineItem(
        product: product,
        systemPrice: (price?.withdrawalPrice ?? 0) * product.piecesPerBox,
        discountMultiplier: () => _discountMultiplier,
        supplierPrice: supplierPrice?.priceBox,
      ));
    });
    _scheduleAutoSave();
  }

  double get _grandTotal =>
      _lineItems.fold(0.0, (sum, item) => sum + item.amount);

  /// Combined multiplier applying every discount in sequence (cascading,
  /// each discount taken off the previous net value), then VAT if enabled.
  double get _discountMultiplier {
    double m = 1.0;
    for (final d in _discountPercents) {
      m *= (1 - d / 100);
    }
    if (_vatEnabled) m *= 1.12;
    return m;
  }

  Future<void> _promptAddDiscount() async {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final value = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Discount'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Discount %',
              isDense: true,
              suffixText: '%',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
            ],
            validator: (v) {
              final n = double.tryParse(v ?? '');
              if (n == null || n <= 0 || n > 100) {
                return 'Enter a value between 0 and 100';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx, double.parse(ctrl.text));
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (value != null) {
      setState(() => _discountPercents.add(value));
      _scheduleAutoSave();
    }
  }

  bool get _canSave =>
      !_saving &&
      _status != 'cancelled' &&
      _selectedSupplier != null &&
      _lineItems.isNotEmpty &&
      _lineItems.every((item) => item.cases > 0);

  ({PurchaseOrder order, List<PurchaseOrderItem> items}) _buildPayload() {
    final order = PurchaseOrder(
      id: _orderId,
      supplierId: _selectedSupplier!.id,
      orderDate: _orderDate,
      referenceNumber: _referenceCtrl.text.trim().isEmpty
          ? null
          : _referenceCtrl.text.trim(),
      totalAmount: _grandTotal,
      status: _status,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: _createdAt,
      discountPercents: List<double>.from(_discountPercents),
      vatEnabled: _vatEnabled,
    );
    final items = _lineItems
        .map((li) => PurchaseOrderItem(
              id: const Uuid().v4(),
              purchaseOrderId: _orderId,
              productId: li.product.id,
              systemPrice: li.systemPrice,
              price: li.price,
              cases: li.cases,
              amount: li.amount,
              isFree: li.isFree,
              rawPrice: li.rawPrice,
            ))
        .toList();
    return (order: order, items: items);
  }

  bool get _hasDraftContent =>
      _selectedSupplier != null && _lineItems.isNotEmpty;

  ({PurchaseOrder order, List<PurchaseOrderItem> items}) _buildDraftPayload() {
    final order = PurchaseOrder(
      id: _orderId,
      supplierId: _selectedSupplier!.id,
      orderDate: _orderDate,
      referenceNumber: _referenceCtrl.text.trim().isEmpty
          ? null
          : _referenceCtrl.text.trim(),
      totalAmount: _grandTotal,
      status: 'draft',
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: _createdAt,
      discountPercents: List<double>.from(_discountPercents),
      vatEnabled: _vatEnabled,
    );
    final items = _lineItems
        .map((li) => PurchaseOrderItem(
              id: const Uuid().v4(),
              purchaseOrderId: _orderId,
              productId: li.product.id,
              systemPrice: li.systemPrice,
              price: li.price,
              cases: li.cases,
              amount: li.amount,
              isFree: li.isFree,
              rawPrice: li.rawPrice,
            ))
        .toList();
    return (order: order, items: items);
  }

  void _scheduleAutoSave() {
    if (_finalized || !isNew) return;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), _autoSaveDraft);
  }

  Future<void> _autoSaveDraft() async {
    if (_finalized || !mounted) return;
    if (!_hasDraftContent) return;
    setState(() => _autoSaving = true);
    final payload = _buildDraftPayload();
    await ref
        .read(purchaseOrderRepositoryProvider)
        .saveDraftOrder(order: payload.order, items: payload.items);
    _draftPersisted = true;
    ref.invalidate(draftPurchaseOrdersProvider);
    if (mounted) {
      setState(() {
        _autoSaving = false;
        _lastAutoSaved = DateTime.now();
      });
    }
  }

  Future<({PurchaseOrder order, List<PurchaseOrderItem> items})> _persist() async {
    _autoSaveTimer?.cancel();
    final payload = _buildPayload();
    final repo = ref.read(purchaseOrderRepositoryProvider);
    if (isNew) {
      if (_draftPersisted) {
        await repo.finalizeDraft(order: payload.order, items: payload.items);
      } else {
        await repo.saveOrder(order: payload.order, items: payload.items);
      }
    } else {
      await repo.editOrder(order: payload.order, newItems: payload.items);
    }
    await _syncSupplierPrices();
    _finalized = true;
    ref.invalidate(purchaseOrdersListProvider);
    ref.invalidate(filteredPurchaseOrdersProvider);
    ref.invalidate(draftPurchaseOrdersProvider);
    return payload;
  }

  /// Persists each line item's box price back into that product's
  /// Supplier Pricing record, so the next order for the same product
  /// prefills with the latest price.
  Future<void> _syncSupplierPrices() async {
    final priceRepo = ref.read(productSupplierPriceRepositoryProvider);
    for (final li in _lineItems) {
      final existing = await priceRepo.getForProduct(li.product.id);
      await priceRepo.upsert(ProductSupplierPrice(
        id: existing?.id ?? const Uuid().v4(),
        productId: li.product.id,
        priceBox: li.rawPrice,
        discountPercents: existing?.discountPercents ?? const [],
        vatEnabled: existing?.vatEnabled ?? false,
      ));
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _persist();
    if (mounted) context.go('/purchase-orders');
  }

  Future<void> _print() async {
    setState(() => _saving = true);
    final persisted = await _persist();

    final productsById = {
      for (final li in _lineItems) li.product.id: li.product
    };
    await printPurchaseOrder(
      order: persisted.order,
      supplier: _selectedSupplier!,
      items: persisted.items,
      productsById: productsById,
    );

    if (mounted) context.go('/purchase-orders');
  }

  Future<void> _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Purchase Order'),
        content: const Text('Cancel this purchase order?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Yes, Cancel')),
        ],
      ),
    );
    if (confirm != true) return;

    await ref.read(purchaseOrderRepositoryProvider).cancelOrder(_orderId);
    ref.invalidate(purchaseOrdersListProvider);
    ref.invalidate(filteredPurchaseOrdersProvider);
    if (mounted) context.go('/purchase-orders');
  }

  @override
  Widget build(BuildContext context) {
    _container ??= ProviderScope.containerOf(context, listen: false);
    return AppScaffold(
      title: isNew ? 'New Purchase Order' : 'Purchase Order',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (isNew && (_autoSaving || _lastAutoSaved != null))
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _autoSaving
                            ? 'Saving draft…'
                            : 'Draft saved at ${DateFormat('HH:mm').format(_lastAutoSaved!)}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ),
                if (_status == 'cancelled')
                  Container(
                    width: double.infinity,
                    color: Colors.red.shade100,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: const Text(
                      'This purchase order has been cancelled.',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),

                // Date + Supplier selectors
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _status == 'cancelled' ? null : _pickDate,
                          borderRadius: BorderRadius.circular(4),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Order Date',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today, size: 18),
                            ),
                            child: Text(
                              DateFormat('MMM dd, yyyy').format(_orderDate),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap:
                              _status == 'cancelled' ? null : _pickSupplier,
                          borderRadius: BorderRadius.circular(4),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Supplier',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.search),
                            ),
                            child: Text(
                              _selectedSupplier?.name ?? 'Tap to search…',
                              style: TextStyle(
                                color: _selectedSupplier == null
                                    ? Theme.of(context).hintColor
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Reference number + Notes
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _referenceCtrl,
                          enabled: _status != 'cancelled',
                          decoration: const InputDecoration(
                            labelText: 'Reference Number',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (_) => _scheduleAutoSave(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _notesCtrl,
                          enabled: _status != 'cancelled',
                          decoration: const InputDecoration(
                            labelText: 'Notes',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (_) => _scheduleAutoSave(),
                        ),
                      ),
                    ],
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
                        onPressed: _status == 'cancelled' ? null : _pickProduct,
                      ),
                    ],
                  ),
                ),

                // Discount / VAT controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.percent, size: 16),
                        label: const Text('Add Discount %'),
                        onPressed:
                            _status == 'cancelled' ? null : _promptAddDiscount,
                      ),
                      for (int i = 0; i < _discountPercents.length; i++)
                        Chip(
                          label: Text(
                              '${formatNumber(_discountPercents[i])}% off'),
                          onDeleted: _status == 'cancelled'
                              ? null
                              : () {
                                  setState(
                                      () => _discountPercents.removeAt(i));
                                  _scheduleAutoSave();
                                },
                        ),
                      FilterChip(
                        label: const Text('Add VAT (12%)'),
                        selected: _vatEnabled,
                        onSelected: _status == 'cancelled'
                            ? null
                            : (v) {
                                setState(() => _vatEnabled = v);
                                _scheduleAutoSave();
                              },
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
                            key: ValueKey(_lineItems[i].product.id),
                            item: _lineItems[i],
                            enabled: _status != 'cancelled',
                            onRemove: () {
                              setState(() => _lineItems.removeAt(i));
                              _scheduleAutoSave();
                            },
                            onChanged: () {
                              setState(() {});
                              _scheduleAutoSave();
                            },
                          ),
                        ),
                ),

                // Totals + actions
                Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Grand Total: ${formatCurrency(_grandTotal)}',
                                  style: const TextStyle(
                                      fontSize: 16,
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
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (!isNew && _status == 'open')
                            OutlinedButton(
                              onPressed: _saving ? null : _cancelOrder,
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red),
                              child: const Text('Cancel Order'),
                            ),
                          const Spacer(),
                          OutlinedButton(
                            onPressed: () => context.go('/purchase-orders'),
                            child: const Text('Back'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            icon: _saving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child:
                                        CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.save_outlined),
                            label: const Text('Save'),
                            onPressed: _canSave ? _save : null,
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            icon: _saving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.print),
                            label: const Text('Print'),
                            onPressed: _canSave ? _print : null,
                          ),
                        ],
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

class _LineItemTile extends StatelessWidget {
  final _LineItem item;
  final bool enabled;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _LineItemTile({
    super.key,
    required this.item,
    required this.enabled,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: item.pricesDiffer ? Colors.orange.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Text(
                  packagingLabel(item.product),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (enabled)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: onRemove,
                  ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'System Price (Box): ${formatCurrency(item.systemPrice)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: item.supplierPriceCtrl,
                    enabled: enabled,
                    decoration: const InputDecoration(
                        labelText: 'Supplier Price (Box)', isDense: true),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'))
                    ],
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 170,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Net Value (Box)',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      formatCurrency(item.price),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 130,
                  child: TextField(
                    controller: item.casesCtrl,
                    enabled: enabled,
                    decoration: const InputDecoration(
                        labelText: '# of Case', isDense: true),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'))
                    ],
                    onChanged: (_) => onChanged(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: item.isFree
                      ? const Text(
                          'FREE — not included in totals',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        )
                      : Text(
                          'Amount: ${formatCurrency(item.amount)}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                ),
                const Text('Free', style: TextStyle(fontSize: 12)),
                Switch(
                  value: item.isFree,
                  onChanged: enabled
                      ? (v) {
                          item.isFree = v;
                          onChanged();
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
