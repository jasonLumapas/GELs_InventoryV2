import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/app_settings_service.dart';
import '../../models/client.dart';
import '../../models/invoice.dart';
import '../../models/invoice_item.dart';
import '../../models/product.dart';
import '../../repositories/client_repository.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/invoice_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../utils/currency_format.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/search_picker.dart';

// ── Line item ─────────────────────────────────────────────────────────────────

class _LineItem {
  final Product product;
  String unitType;
  final TextEditingController quantityCtrl;
  final TextEditingController priceCtrl;
  int availablePieces;

  _LineItem({
    required this.product,
    required double pricePerPiece,
    this.unitType = 'box',
    int quantity = 0,
    this.availablePieces = 0,
  })  : quantityCtrl = TextEditingController(
            text: quantity > 0 ? '$quantity' : ''),
        priceCtrl = TextEditingController(
            text: pricePerPiece.toStringAsFixed(2));

  void dispose() {
    quantityCtrl.dispose();
    priceCtrl.dispose();
  }

  int get quantity => int.tryParse(quantityCtrl.text) ?? 0;

  double get pricePerPiece => double.tryParse(priceCtrl.text) ?? 0;

  int get quantityInPieces =>
      unitType == 'box' ? quantity * product.piecesPerBox : quantity;

  double get subtotal => quantityInPieces * pricePerPiece;

  bool get isSufficient => quantityInPieces <= availablePieces;

  int get avlBoxes =>
      product.piecesPerBox > 0 ? availablePieces ~/ product.piecesPerBox : 0;
  int get avlPcs =>
      product.piecesPerBox > 0 ? availablePieces % product.piecesPerBox : availablePieces;

  String get packagingLabel {
    final ppb = product.piecesPerBox;
    return unitType == 'box' ? '$ppb pcs/box' : 'pcs';
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class PreOrderFormScreen extends ConsumerStatefulWidget {
  /// null = new pre-order draft, non-null = edit existing draft
  final String? draftId;

  const PreOrderFormScreen({super.key, this.draftId});

  @override
  ConsumerState<PreOrderFormScreen> createState() =>
      _PreOrderFormScreenState();
}

class _PreOrderFormScreenState extends ConsumerState<PreOrderFormScreen> {
  bool get isNew => widget.draftId == null;

  late String _id;
  late DateTime _createdAt;
  DateTime _invoiceDate = DateTime.now().add(const Duration(days: 1));
  Client? _selectedClient;
  final List<_LineItem> _lineItems = [];
  bool _loading = true;
  bool _saving = false;
  bool _useOpSellingPrice = false;
  Timer? _autoSaveTimer;
  bool _autoSaving = false;
  DateTime? _lastAutoSaved;

  @override
  void initState() {
    super.initState();
    _id = widget.draftId ?? const Uuid().v4();
    _createdAt = DateTime.now();
    _loadData();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    for (final li in _lineItems) {
      li.dispose();
    }
    super.dispose();
  }

  bool get _hasDraftContent =>
      _selectedClient != null && _lineItems.isNotEmpty;

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), _autoSaveDraft);
  }

  Future<void> _autoSaveDraft() async {
    if (!mounted || !_hasDraftContent) return;
    setState(() => _autoSaving = true);
    final invoice = Invoice(
      id: _id,
      clientId: _selectedClient!.id,
      invoiceDate: _invoiceDate,
      totalAmount: _grandTotal,
      status: 'draft',
      createdAt: _createdAt,
      invoiceType: 'pre_order',
      paymentType: 'cash',
    );
    final items = _lineItems
        .map((li) => InvoiceItem(
              id: const Uuid().v4(),
              invoiceId: _id,
              productId: li.product.id,
              unitType: li.unitType,
              quantity: li.quantityInPieces,
              pricePerPiece: li.pricePerPiece,
              subtotal: li.subtotal,
            ))
        .toList();
    await ref
        .read(invoiceRepositoryProvider)
        .saveDraftInvoice(invoice: invoice, items: items);
    ref.invalidate(preOrderDraftsProvider);
    if (mounted) {
      setState(() {
        _autoSaving = false;
        _lastAutoSaved = DateTime.now();
      });
    }
  }

  Future<void> _loadData() async {
    _useOpSellingPrice = await ref.read(useOpSellingPriceProvider.future);
    final clients = await ref.read(clientRepositoryProvider).getAll();
    final products = await ref.read(productRepositoryProvider).getAll();
    final inventoryRepo = ref.read(inventoryRepositoryProvider);

    if (widget.draftId != null) {
      final repo = ref.read(invoiceRepositoryProvider);
      final invoice = await repo.getById(widget.draftId!);
      if (invoice != null) {
        _createdAt = invoice.createdAt;
        _invoiceDate = invoice.invoiceDate;
        _selectedClient =
            clients.where((c) => c.id == invoice.clientId).firstOrNull;
        final items = await repo.getItems(widget.draftId!);
        final productsById = {for (final p in products) p.id: p};
        for (final it in items) {
          final product = productsById[it.productId];
          if (product == null) continue;
          final inv = await inventoryRepo.getByProductId(it.productId);
          final displayQty = it.unitType == 'box' && product.piecesPerBox > 0
              ? it.quantity ~/ product.piecesPerBox
              : it.quantity;
          _lineItems.add(_LineItem(
            product: product,
            pricePerPiece: it.pricePerPiece,
            unitType: it.unitType,
            quantity: displayQty,
            availablePieces: inv?.quantityPieces ?? 0,
          ));
        }
      }
    }

    await _computeEffectiveAvailability();
    if (mounted) setState(() => _loading = false);
  }

  /// Recomputes each line item's [_LineItem.availablePieces] to reflect what
  /// remains after higher-priority (earlier-dated) valid drafts consume stock.
  Future<void> _computeEffectiveAvailability() async {
    if (_lineItems.isEmpty) return;

    final invoiceRepo = ref.read(invoiceRepositoryProvider);
    final inventoryRepo = ref.read(inventoryRepositoryProvider);

    final allDrafts = await invoiceRepo.getPreOrderDrafts();

    // Load items for every other draft.
    final otherItems = <String, List<InvoiceItem>>{};
    for (final d in allDrafts) {
      if (d.id == _id) continue;
      otherItems[d.id] = await invoiceRepo.getItems(d.id);
    }

    // Seed inventory for all products referenced across all drafts.
    final allProductIds = {
      ..._lineItems.map((li) => li.product.id),
      for (final items in otherItems.values)
        for (final item in items) item.productId,
    };
    final remaining = <String, int>{};
    for (final productId in allProductIds) {
      final inv = await inventoryRepo.getByProductId(productId);
      remaining[productId] = inv?.quantityPieces ?? 0;
    }

    // Drafts that rank higher priority: earlier delivery date, or same date
    // but created earlier (matching the list screen's stable sort order).
    final higherPriority = allDrafts.where((d) {
      if (d.id == _id) return false;
      final dateCmp = d.invoiceDate.compareTo(_invoiceDate);
      if (dateCmp < 0) return true;
      if (dateCmp > 0) return false;
      return d.createdAt.isBefore(_createdAt);
    }).toList()
      ..sort((a, b) {
        final dateCmp = a.invoiceDate.compareTo(b.invoiceDate);
        return dateCmp != 0 ? dateCmp : a.createdAt.compareTo(b.createdAt);
      });

    for (final draft in higherPriority) {
      final items = otherItems[draft.id]!;
      final valid = items.every(
          (item) => (remaining[item.productId] ?? 0) >= item.quantity);
      if (valid) {
        for (final item in items) {
          remaining[item.productId] =
              (remaining[item.productId] ?? 0) - item.quantity;
        }
      }
    }

    if (!mounted) return;
    setState(() {
      for (final li in _lineItems) {
        li.availablePieces = remaining[li.product.id] ?? 0;
      }
    });
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
      _scheduleAutoSave();
      _computeEffectiveAvailability();
    }
  }

  Future<void> _pickClient() async {
    final clients = await ref.read(clientRepositoryProvider).getAll();
    final sorted = List<Client>.from(clients)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    if (!mounted) return;
    final picked = await showSearchPicker<Client>(
      context: context,
      title: 'Select Client / Store',
      items: sorted,
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
                  if (dup) {
                    return 'A client with the same name and address already exists';
                  }
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
              await ref.read(clientRepositoryProvider).upsert(newClient);
              ref.invalidate(clientsListProvider);
              if (ctx.mounted) Navigator.pop(ctx, newClient);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addProduct() async {
    final products = await ref.read(productRepositoryProvider).getAll();
    final suppliers = await ref.read(supplierRepositoryProvider).getAll();
    final suppById = {for (final s in suppliers) s.id: s.name};

    final alreadyAdded = _lineItems.map((li) => li.product.id).toSet();
    final available = products
        .where((p) => !alreadyAdded.contains(p.id))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    if (!mounted) return;

    // Build one filter chip per supplier that has at least one available product.
    final supplierChips = <String, String>{};
    for (final p in available) {
      final name = suppById[p.supplierId];
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
      title: 'Add Product',
      items: available,
      labelOf: (p) => p.name,
      searchableOf: (p) => '${p.name} ${p.productCode ?? ''}',
      filters: supplierFilters,
      onSelected: (p) => _addLineItem(p),
    );
  }

  Future<void> _addLineItem(Product product) async {
    final price =
        await ref.read(productRepositoryProvider).getCurrentPrice(product.id);
    final inv =
        await ref.read(inventoryRepositoryProvider).getByProductId(product.id);
    final effectivePrice = _useOpSellingPrice && price?.sellingPriceOp != null
        ? price!.sellingPriceOp!
        : (price?.sellingPrice ?? 0);
    setState(() {
      _lineItems.add(_LineItem(
        product: product,
        pricePerPiece: effectivePrice,
        availablePieces: inv?.quantityPieces ?? 0,
      ));
    });
    _scheduleAutoSave();
  }

  bool get _canSave =>
      !_saving &&
      _selectedClient != null &&
      _lineItems.isNotEmpty &&
      _lineItems.every((li) => li.quantity > 0);

  bool get _canSaveAsInvoice =>
      !_saving &&
      _selectedClient != null &&
      _lineItems.isNotEmpty &&
      _lineItems.every((li) => li.quantity > 0) &&
      _lineItems.every((li) => li.isSufficient);

  double get _grandTotal =>
      _lineItems.fold(0.0, (s, li) => s + li.subtotal);

  Future<void> _save() async {
    setState(() => _saving = true);
    final invoice = Invoice(
      id: _id,
      clientId: _selectedClient!.id,
      invoiceDate: _invoiceDate,
      totalAmount: _grandTotal,
      status: 'draft',
      createdAt: _createdAt,
      invoiceType: 'pre_order',
      paymentType: 'cash',
    );
    final items = _lineItems
        .map((li) => InvoiceItem(
              id: const Uuid().v4(),
              invoiceId: _id,
              productId: li.product.id,
              unitType: li.unitType,
              quantity: li.quantityInPieces,
              pricePerPiece: li.pricePerPiece,
              subtotal: li.subtotal,
            ))
        .toList();

    await ref
        .read(invoiceRepositoryProvider)
        .saveDraftInvoice(invoice: invoice, items: items);
    ref.invalidate(preOrderDraftsProvider);

    if (mounted) context.go('/pre-orders');
  }

  Future<void> _saveAsInvoice() async {
    // invoiceType and paymentType are mutated directly by onChanged — no StatefulBuilder needed.
    String invoiceType = 'delivery';
    String paymentType = 'cash';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save as Invoice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will create a final invoice and deduct the quantities '
              'from inventory. This cannot be undone.',
            ),
            const SizedBox(height: 16),
            const Text('Invoice type:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: invoiceType,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), isDense: true),
              items: const [
                DropdownMenuItem(value: 'delivery', child: Text('Delivery')),
                DropdownMenuItem(value: 'walk_in',  child: Text('Walk-in')),
              ],
              onChanged: (v) { if (v != null) invoiceType = v; },
            ),
            const SizedBox(height: 12),
            const Text('Payment type:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: paymentType,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), isDense: true),
              items: const [
                DropdownMenuItem(value: 'cash',   child: Text('Cash')),
                DropdownMenuItem(value: 'credit', child: Text('Credit')),
                DropdownMenuItem(value: 'check',  child: Text('Check')),
              ],
              onChanged: (v) { if (v != null) paymentType = v; },
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save as Invoice')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    try {
      final repo = ref.read(invoiceRepositoryProvider);
      // Use today+1 (the standard delivery date) so the invoice appears
      // in the day filter, matching invoices created from invoice_create_screen.
      final invoiceDate = DateTime.now().add(const Duration(days: 1));
      final invoiceNumber = await repo.generateInvoiceNumber(invoiceDate);

      final invoice = Invoice(
        id: _id,
        clientId: _selectedClient!.id,
        invoiceDate: invoiceDate,
        totalAmount: _grandTotal,
        status: 'printed',
        createdAt: _createdAt,
        invoiceNumber: invoiceNumber,
        invoiceType: invoiceType,
        paymentType: paymentType,
      );
      final items = _lineItems
          .map((li) => InvoiceItem(
                id: const Uuid().v4(),
                invoiceId: _id,
                productId: li.product.id,
                unitType: li.unitType,
                quantity: li.quantityInPieces,
                pricePerPiece: li.pricePerPiece,
                subtotal: li.subtotal,
              ))
          .toList();

      await repo.finalizeDraft(invoice: invoice, items: items);
      ref.invalidate(preOrderDraftsProvider);
      ref.invalidate(invoicesListProvider);
      ref.invalidate(filteredInvoicesProvider);
      ref.invalidate(inventoryListProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice $invoiceNumber created.'),
          duration: const Duration(seconds: 1),
        ),
      );
      context.go('/pre-orders');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create invoice: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM dd, yyyy');

    return AppScaffold(
      title: isNew ? 'New Pre-Order' : 'Edit Pre-Order',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Auto-save status
                if (_autoSaving || _lastAutoSaved != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _autoSaving
                            ? 'Saving draft…'
                            : 'Draft saved at ${DateFormat('HH:mm').format(_lastAutoSaved!)}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant),
                      ),
                    ),
                  ),

                // Delivery date
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(4),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Delivery Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today, size: 18),
                      ),
                      child: Text(dateFmt.format(_invoiceDate)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Client
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
                        _selectedClient?.name ?? 'Tap to search...',
                        style: TextStyle(
                          color: _selectedClient == null
                              ? Theme.of(context).hintColor
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Items header
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
                        onPressed: _addProduct,
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

                // Footer
                Container(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Total: ${formatCurrency(_grandTotal)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text('${_lineItems.length} item(s)',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Spacer(),
                          OutlinedButton(
                            onPressed: () => context.go('/pre-orders'),
                            child: const Text('Back'),
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
                                        strokeWidth: 2,
                                        color: Colors.white))
                                : const Icon(Icons.receipt_long),
                            label: const Text('Save as Invoice'),
                            style: FilledButton.styleFrom(
                                backgroundColor: Colors.green.shade700),
                            onPressed:
                                _canSaveAsInvoice ? _saveAsInvoice : null,
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
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _LineItemTile({
    required this.item,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<_LineItemTile> createState() => _LineItemTileState();
}

class _LineItemTileState extends State<_LineItemTile> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.product.name,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Unit type
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'box', label: Text('Box')),
                    ButtonSegment(value: 'piece', label: Text('Pcs')),
                  ],
                  selected: {item.unitType},
                  onSelectionChanged: (s) {
                    setState(() => item.unitType = s.first);
                    widget.onChanged();
                  },
                  style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),
                Text(item.packagingLabel,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
                const Spacer(),
                // Quantity
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: item.quantityCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(
                      labelText:
                          item.unitType == 'box' ? 'Qty (Box)' : 'Qty (Pcs)',
                      isDense: true,
                    ),
                    onChanged: (_) => widget.onChanged(),
                  ),
                ),
                const SizedBox(width: 8),
                // Price per piece
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: item.priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'))
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Price/pc',
                      isDense: true,
                      prefixText: '₱ ',
                    ),
                    onChanged: (_) => widget.onChanged(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Inventory badge
                Row(
                  children: [
                    Icon(
                      item.isSufficient
                          ? Icons.check_circle_outline
                          : Icons.warning_amber_rounded,
                      size: 14,
                      color: item.isSufficient
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      () {
                        final b = item.avlBoxes;
                        final p = item.avlPcs;
                        if (b > 0 && p > 0) return 'In stock: $b box(es) + $p pcs';
                        if (b > 0) return 'In stock: $b box(es)';
                        if (p > 0) return 'In stock: $p pcs';
                        return 'Out of stock';
                      }(),
                      style: TextStyle(
                        fontSize: 11,
                        color: item.isSufficient
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Subtotal: ${formatCurrency(item.subtotal)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
