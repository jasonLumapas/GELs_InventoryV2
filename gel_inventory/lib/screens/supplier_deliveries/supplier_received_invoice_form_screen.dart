import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/product.dart';
import '../../models/supplier.dart';
import '../../models/supplier_received_invoice.dart';
import '../../models/supplier_received_invoice_item.dart';
import '../../models/product_price.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/supplier_received_invoice_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../utils/currency_format.dart';
import '../../utils/pdf_generator.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/search_picker.dart';

// ── Line item ─────────────────────────────────────────────────────────────────

class _LineItem {
  final Product product;
  final double systemPrice;
  int quantity;
  int quantityPieces;
  bool isFree;
  final TextEditingController supplierPriceCtrl;

  _LineItem({
    required this.product,
    required this.systemPrice,
    this.quantity = 0,
    this.quantityPieces = 0,
    this.isFree = false,
    double? supplierPrice,
  }) : supplierPriceCtrl = TextEditingController(
          text: ((supplierPrice ?? systemPrice) * product.piecesPerBox)
              .toStringAsFixed(2),
        );

  int get quantityInPieces =>
      quantity * product.piecesPerBox + quantityPieces;

  double get systemPricePerBox => systemPrice * product.piecesPerBox;

  double get supplierPrice => product.piecesPerBox > 0
      ? (double.tryParse(supplierPriceCtrl.text) ?? systemPricePerBox) /
          product.piecesPerBox
      : (double.tryParse(supplierPriceCtrl.text) ?? systemPrice);

  double get subtotalSystem => isFree ? 0 : quantityInPieces * systemPrice;
  double get subtotalSupplier =>
      isFree ? 0 : quantityInPieces * supplierPrice;

  bool get pricesDiffer => supplierPrice != systemPrice;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class SupplierReceivedInvoiceFormScreen extends ConsumerStatefulWidget {
  final String? invoiceId;
  final String? draftId;

  const SupplierReceivedInvoiceFormScreen(
      {super.key, this.invoiceId, this.draftId});

  @override
  ConsumerState<SupplierReceivedInvoiceFormScreen> createState() =>
      _SupplierReceivedInvoiceFormScreenState();
}

class _SupplierReceivedInvoiceFormScreenState
    extends ConsumerState<SupplierReceivedInvoiceFormScreen> {
  bool get isNew => widget.invoiceId == null;

  late String _invoiceId;
  late DateTime _createdAt;
  DateTime _receivedDate = DateTime.now();
  Supplier? _selectedSupplier;
  String _status = 'received';
  final _referenceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final List<_LineItem> _lineItems = [];
  List<SupplierReceivedInvoiceItem> _oldItems = [];

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
    _invoiceId = widget.invoiceId ?? widget.draftId ?? const Uuid().v4();
    _createdAt = DateTime.now();
    _loadData();
  }

  @override
  void dispose() {
    final hadPendingSave = _autoSaveTimer?.isActive ?? false;
    _autoSaveTimer?.cancel();
    if (!_finalized && isNew) {
      final repo = _container?.read(supplierReceivedInvoiceRepositoryProvider);
      if (repo != null) {
        if (_hasDraftContent) {
          if (hadPendingSave || !_draftPersisted) {
            final payload = _buildDraftPayload();
            repo.saveDraftInvoice(
                invoice: payload.invoice, items: payload.items);
          }
        } else if (_draftPersisted && widget.draftId == null) {
          repo.discardDraft(_invoiceId);
        }
        _container?.invalidate(draftSupplierReceivedInvoicesProvider);
      }
    }
    _referenceCtrl.dispose();
    _notesCtrl.dispose();
    for (final item in _lineItems) {
      item.supplierPriceCtrl.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    final suppliers = await ref.read(supplierRepositoryProvider).getAll();
    final products = await ref.read(productRepositoryProvider).getAll();

    final loadId = widget.invoiceId ?? widget.draftId;
    if (loadId != null) {
      final repo = ref.read(supplierReceivedInvoiceRepositoryProvider);
      final invoice = await repo.getById(loadId);
      if (invoice != null) {
        _createdAt = invoice.createdAt;
        _receivedDate = invoice.receivedDate;
        _status = invoice.status == 'draft' ? 'received' : invoice.status;
        _referenceCtrl.text = invoice.referenceNumber ?? '';
        _notesCtrl.text = invoice.notes ?? '';
        _selectedSupplier =
            suppliers.where((s) => s.id == invoice.supplierId).firstOrNull;
        if (widget.draftId != null) _draftPersisted = true;

        final items = await repo.getItems(invoice.id);
        _oldItems = items;
        final productsById = {for (final p in products) p.id: p};
        for (final it in items) {
          final product = productsById[it.productId];
          if (product == null) continue;
          final currentPrice = await ref
              .read(productRepositoryProvider)
              .getCurrentPrice(product.id);
          _lineItems.add(_LineItem(
            product: product,
            systemPrice: currentPrice?.withdrawalPrice ?? it.systemPrice,
            quantity: product.piecesPerBox > 0
                ? it.quantity ~/ product.piecesPerBox
                : it.quantity,
            quantityPieces: product.piecesPerBox > 0
                ? it.quantity % product.piecesPerBox
                : 0,
            isFree: it.isFree,
            supplierPrice: it.supplierPrice,
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
      initialDate: _receivedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _receivedDate = picked);
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
    final filtered = _selectedSupplier == null
        ? List<Product>.from(_products)
        : _products
            .where((p) => p.supplierId == _selectedSupplier!.id)
            .toList();
    filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    await showSearchPicker<Product>(
      context: context,
      title: 'Select Product',
      items: filtered,
      labelOf: (p) => p.name,
      searchableOf: (p) => '${p.name} ${p.productCode ?? ''}',
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
    setState(() {
      _lineItems.add(_LineItem(
        product: product,
        systemPrice: price?.withdrawalPrice ?? 0,
      ));
    });
    _scheduleAutoSave();
  }

  double get _totalSystem =>
      _lineItems.fold(0.0, (sum, item) => sum + item.subtotalSystem);
  double get _totalSupplier =>
      _lineItems.fold(0.0, (sum, item) => sum + item.subtotalSupplier);

  bool get _canSave =>
      !_saving &&
      _status != 'cancelled' &&
      _selectedSupplier != null &&
      _lineItems.isNotEmpty &&
      _lineItems.every((item) => item.quantityInPieces > 0);

  ({SupplierReceivedInvoice invoice, List<SupplierReceivedInvoiceItem> items})
      _buildPayload() {
    final invoice = SupplierReceivedInvoice(
      id: _invoiceId,
      supplierId: _selectedSupplier!.id,
      receivedDate: _receivedDate,
      referenceNumber: _referenceCtrl.text.trim().isEmpty
          ? null
          : _referenceCtrl.text.trim(),
      totalAmountSystem: _totalSystem,
      totalAmountSupplier: _totalSupplier,
      status: _status,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: _createdAt,
    );
    final items = _lineItems
        .map((li) => SupplierReceivedInvoiceItem(
              id: const Uuid().v4(),
              receivedInvoiceId: _invoiceId,
              productId: li.product.id,
              unitType: 'box',
              quantity: li.quantityInPieces,
              systemPrice: li.systemPrice,
              supplierPrice: li.supplierPrice,
              subtotalSystem: li.subtotalSystem,
              subtotalSupplier: li.subtotalSupplier,
              isFree: li.isFree,
            ))
        .toList();
    return (invoice: invoice, items: items);
  }

  bool get _hasDraftContent =>
      _selectedSupplier != null && _lineItems.isNotEmpty;

  ({SupplierReceivedInvoice invoice, List<SupplierReceivedInvoiceItem> items})
      _buildDraftPayload() {
    final invoice = SupplierReceivedInvoice(
      id: _invoiceId,
      supplierId: _selectedSupplier!.id,
      receivedDate: _receivedDate,
      referenceNumber: _referenceCtrl.text.trim().isEmpty
          ? null
          : _referenceCtrl.text.trim(),
      totalAmountSystem: _totalSystem,
      totalAmountSupplier: _totalSupplier,
      status: 'draft',
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: _createdAt,
    );
    final items = _lineItems
        .map((li) => SupplierReceivedInvoiceItem(
              id: const Uuid().v4(),
              receivedInvoiceId: _invoiceId,
              productId: li.product.id,
              unitType: 'box',
              quantity: li.quantityInPieces,
              systemPrice: li.systemPrice,
              supplierPrice: li.supplierPrice,
              subtotalSystem: li.subtotalSystem,
              subtotalSupplier: li.subtotalSupplier,
              isFree: li.isFree,
            ))
        .toList();
    return (invoice: invoice, items: items);
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
        .read(supplierReceivedInvoiceRepositoryProvider)
        .saveDraftInvoice(invoice: payload.invoice, items: payload.items);
    _draftPersisted = true;
    ref.invalidate(draftSupplierReceivedInvoicesProvider);
    if (mounted) {
      setState(() {
        _autoSaving = false;
        _lastAutoSaved = DateTime.now();
      });
    }
  }

  Future<({SupplierReceivedInvoice invoice, List<SupplierReceivedInvoiceItem> items})>
      _persist() async {
    _autoSaveTimer?.cancel();
    final payload = _buildPayload();
    final repo = ref.read(supplierReceivedInvoiceRepositoryProvider);
    if (isNew) {
      if (_draftPersisted) {
        await repo.finalizeDraft(
          invoice: payload.invoice,
          items: payload.items,
          supplier: _selectedSupplier!,
        );
      } else {
        await repo.saveInvoice(
          invoice: payload.invoice,
          items: payload.items,
          supplier: _selectedSupplier!,
        );
      }
    } else {
      await repo.editInvoice(
        invoice: payload.invoice,
        newItems: payload.items,
        oldItems: _oldItems,
        supplier: _selectedSupplier!,
      );
    }
    _finalized = true;
    ref.invalidate(supplierReceivedInvoicesListProvider);
    ref.invalidate(filteredSupplierReceivedInvoicesProvider);
    ref.invalidate(inventoryListProvider);
    ref.invalidate(draftSupplierReceivedInvoicesProvider);
    return payload;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _persist();
    if (mounted) context.go('/supplier-deliveries');
  }

  Future<void> _print() async {
    setState(() => _saving = true);
    final persisted = await _persist();

    final productsById = {
      for (final li in _lineItems) li.product.id: li.product
    };
    await printSupplierReceivedInvoice(
      invoice: persisted.invoice,
      supplier: _selectedSupplier!,
      items: persisted.items,
      productsById: productsById,
    );

    if (mounted) context.go('/supplier-deliveries');
  }

  Future<void> _cancelInvoice() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Delivery'),
        content: const Text(
            'This will reverse the inventory added by this delivery. Continue?'),
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

    await ref
        .read(supplierReceivedInvoiceRepositoryProvider)
        .cancelInvoice(_invoiceId);
    ref.invalidate(supplierReceivedInvoicesListProvider);
    ref.invalidate(filteredSupplierReceivedInvoicesProvider);
    ref.invalidate(inventoryListProvider);
    if (mounted) context.go('/supplier-deliveries');
  }

  @override
  Widget build(BuildContext context) {
    _container ??= ProviderScope.containerOf(context, listen: false);
    return AppScaffold(
      title: isNew ? 'New Supplier Delivery' : 'Supplier Delivery',
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
                      'This delivery has been cancelled.',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),

                // Date selector
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: InkWell(
                    onTap: _status == 'cancelled' ? null : _pickDate,
                    borderRadius: BorderRadius.circular(4),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Received Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today, size: 18),
                      ),
                      child: Text(
                        DateFormat('MMM dd, yyyy').format(_receivedDate),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Supplier selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: InkWell(
                    onTap: _status == 'cancelled' ? null : _pickSupplier,
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
                const SizedBox(height: 8),

                // Reference number
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _referenceCtrl,
                    enabled: _status != 'cancelled',
                    decoration: const InputDecoration(
                      labelText: 'Supplier Reference / DR Number',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => _scheduleAutoSave(),
                  ),
                ),
                const SizedBox(height: 8),

                // Notes
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _notesCtrl,
                    enabled: _status != 'cancelled',
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    maxLines: 2,
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
                        onPressed: _status == 'cancelled' ? null : _pickProduct,
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
                                  'System Total: ${formatCurrency(_totalSystem)}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Supplier Total: ${formatCurrency(_totalSupplier)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _totalSupplier != _totalSystem
                                        ? Colors.orange.shade800
                                        : null,
                                  ),
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
                          if (!isNew && _status == 'received')
                            OutlinedButton(
                              onPressed: _saving ? null : _cancelInvoice,
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red),
                              child: const Text('Cancel Invoice'),
                            ),
                          const Spacer(),
                          OutlinedButton(
                            onPressed: () =>
                                context.go('/supplier-deliveries'),
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
                          if (!isNew)
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

class _LineItemTile extends StatefulWidget {
  final _LineItem item;
  final bool enabled;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _LineItemTile({
    required this.item,
    required this.enabled,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<_LineItemTile> createState() => _LineItemTileState();
}

class _LineItemTileState extends State<_LineItemTile> {
  late TextEditingController _qtyCtrl;
  late TextEditingController _qtyPiecesCtrl;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(
      text: widget.item.quantity > 0 ? widget.item.quantity.toString() : '',
    );
    _qtyPiecesCtrl = TextEditingController(
      text: widget.item.quantityPieces > 0
          ? widget.item.quantityPieces.toString()
          : '',
    );
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _qtyPiecesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

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
                if (!widget.enabled)
                  const SizedBox()
                else
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: widget.onRemove,
                  ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Widrawal Price (Box): ${formatCurrency(item.systemPricePerBox)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                SizedBox(
                  width: 170,
                  child: TextField(
                    controller: item.supplierPriceCtrl,
                    enabled: widget.enabled,
                    decoration: const InputDecoration(
                        labelText: 'Supplier Price (Box)', isDense: true),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'))
                    ],
                    onChanged: (_) => widget.onChanged(),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _qtyCtrl,
                    enabled: widget.enabled,
                    decoration: const InputDecoration(
                        labelText: 'Qty (Box)', isDense: true),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: (v) {
                      item.quantity = int.tryParse(v) ?? 0;
                      widget.onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _qtyPiecesCtrl,
                    enabled: widget.enabled,
                    decoration: const InputDecoration(
                        labelText: 'Qty (pcs)', isDense: true),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: (v) {
                      item.quantityPieces = int.tryParse(v) ?? 0;
                      widget.onChanged();
                    },
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
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Subtotal (System): ${formatCurrency(item.subtotalSystem)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Subtotal (Supplier): ${formatCurrency(item.subtotalSupplier)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: item.pricesDiffer
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: item.pricesDiffer
                                    ? Colors.orange.shade800
                                    : null,
                              ),
                            ),
                          ],
                        ),
                ),
                const Text('Free', style: TextStyle(fontSize: 12)),
                Switch(
                  value: item.isFree,
                  onChanged: widget.enabled
                      ? (v) {
                          setState(() => item.isFree = v);
                          widget.onChanged();
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
