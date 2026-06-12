import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/client.dart';
import '../../models/inventory_item.dart';
import '../../models/invoice.dart';
import '../../models/invoice_item.dart';
import '../../models/product.dart';
import '../../models/product_price.dart';
import '../../models/product_discount.dart';
import '../../models/invoice_payment.dart';
import '../../repositories/client_repository.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/invoice_payment_repository.dart';
import '../../repositories/invoice_repository.dart';
import '../../repositories/product_discount_repository.dart';
import '../../repositories/product_repository.dart';
import '../../utils/currency_format.dart';
import '../../utils/pdf_generator.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/search_picker.dart';

// ── Editable line item ────────────────────────────────────────────────────────

class _EditItem {
  final String itemId;
  final Product product;
  final double pricePerPiece;
  final ProductDiscount? discount;
  InventoryItem? inventory;
  String unitType;
  int quantity;
  bool isFree;
  final int originalPieces;

  _EditItem({
    required this.itemId,
    required this.product,
    required this.pricePerPiece,
    required this.inventory,
    required this.unitType,
    required this.quantity,
    required this.originalPieces,
    this.discount,
    this.isFree = false,
  });

  int get quantityInPieces =>
      unitType == 'box' ? quantity * product.piecesPerBox : quantity;

  bool get _thresholdMet =>
      !isFree && discount != null &&
      quantityInPieces >= discount!.minQuantityPieces;

  double get originalAmount => quantityInPieces * pricePerPiece;

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

  int effectiveAvailable(int currentInvPieces) =>
      currentInvPieces + originalPieces;

  bool hasEnoughStock(int currentInvPieces) =>
      isFree || quantityInPieces <= effectiveAvailable(currentInvPieces);

  InvoiceItem toInvoiceItem(String invoiceId) => InvoiceItem(
        id: itemId,
        invoiceId: invoiceId,
        productId: product.id,
        unitType: unitType,
        quantity: quantityInPieces,
        pricePerPiece: pricePerPiece,
        subtotal: subtotal,
        isFree: isFree,
        discountPercent: (_thresholdMet && discount!.isPercent)
            ? discount!.discountValue
            : 0,
      );
}

// ── Screen ────────────────────────────────────────────────────────────────────

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final String invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailScreen> createState() =>
      _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  Invoice? _invoice;
  List<InvoiceItem> _originalItems = [];
  List<_EditItem> _editItems = [];
  Client? _selectedClient;
  List<Client> _clients = [];
  List<Product> _products = [];
  Map<String, Product> _productsById = {};
  final Map<String, ProductPrice?> _priceCache = {};
  final Map<String, InventoryItem?> _inventoryCache = {};
  final Map<String, ProductDiscount?> _discountCache = {};
  DateTime _invoiceDate = DateTime.now();
  String _paymentType = 'cash';
  final _partialAmountCtrl = TextEditingController();
  final _checkRefCtrl      = TextEditingController();
  final _checkAmountCtrl   = TextEditingController();
  final _notesCtrl         = TextEditingController();
  final _actualAmountCtrl  = TextEditingController();
  DateTime? _checkDueDate;
  DateTime? _partialDate;
  List<InvoicePayment> _payments = [];
  bool _loading = true;
  bool _saving = false;

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/invoices');
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _partialAmountCtrl.dispose();
    _checkRefCtrl.dispose();
    _checkAmountCtrl.dispose();
    _notesCtrl.dispose();
    _actualAmountCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final invoices = await ref.read(invoiceRepositoryProvider).getAll();
    _invoice =
        invoices.where((i) => i.id == widget.invoiceId).firstOrNull;
    if (_invoice == null) {
      if (mounted) _goBack();
      return;
    }

    _originalItems =
        await ref.read(invoiceRepositoryProvider).getItems(widget.invoiceId);
    _clients = await ref.read(clientRepositoryProvider).getAll();
    _products = await ref.read(productRepositoryProvider).getAll();
    _productsById = {for (final p in _products) p.id: p};
    _selectedClient =
        _clients.where((c) => c.id == _invoice!.clientId).firstOrNull;
    _invoiceDate = _invoice!.invoiceDate;
    _paymentType = _invoice!.paymentType;
    if (_invoice!.partialAmount != null) {
      _partialAmountCtrl.text =
          _invoice!.partialAmount!.toStringAsFixed(2);
    }
    _partialDate = _invoice!.partialDate;
    _checkRefCtrl.text    = _invoice!.checkReference ?? '';
    _checkAmountCtrl.text = _invoice!.checkAmount != null
        ? _invoice!.checkAmount!.toStringAsFixed(2)
        : '';
    _checkDueDate = _invoice!.checkDueDate;
    _notesCtrl.text = _invoice!.notes ?? '';
    _actualAmountCtrl.text = _invoice!.actualAmount != null
        ? _invoice!.actualAmount!.toStringAsFixed(2)
        : '';
    _payments = await ref
        .read(invoicePaymentRepositoryProvider)
        .getForInvoice(widget.invoiceId);

    // Pre-load inventory + discounts for products in this invoice
    for (final item in _originalItems) {
      final inv = await ref
          .read(inventoryRepositoryProvider)
          .getByProductId(item.productId);
      _inventoryCache[item.productId] = inv;
      final disc = await ref
          .read(productDiscountRepositoryProvider)
          .getForProduct(item.productId);
      _discountCache[item.productId] = disc;
    }

    // Build editable items from original invoice items
    _editItems = _originalItems
        .map((item) {
          final product = _productsById[item.productId];
          if (product == null) return null;
          final displayQty = item.unitType == 'box'
              ? item.quantity ~/ product.piecesPerBox
              : item.quantity;
          return _EditItem(
            itemId: item.id,
            product: product,
            pricePerPiece: item.pricePerPiece,
            inventory: _inventoryCache[item.productId],
            unitType: item.unitType,
            quantity: displayQty,
            originalPieces: item.quantity,
            isFree: item.isFree,
            discount: _discountCache[item.productId],
          );
        })
        .whereType<_EditItem>()
        .toList();

    setState(() => _loading = false);
  }

  Future<void> _addPayment() async {
    final amount = double.tryParse(_partialAmountCtrl.text);
    if (amount == null || amount <= 0) return;
    final payment = InvoicePayment(
      id: const Uuid().v4(),
      invoiceId: widget.invoiceId,
      amount: amount,
      paymentDate: _partialDate ?? DateTime.now(),
      createdAt: DateTime.now(),
    );
    await ref.read(invoicePaymentRepositoryProvider).add(payment);
    setState(() {
      _payments = [..._payments, payment];
      _partialAmountCtrl.clear();
      _partialDate = null;
    });
  }

  Future<void> _deletePayment(String id) async {
    await ref.read(invoicePaymentRepositoryProvider).delete(id);
    setState(() => _payments = _payments.where((p) => p.id != id).toList());
  }

  Future<void> _pickClient() async {
    final picked = await showSearchPicker<Client>(
      context: context,
      title: 'Select Client / Store',
      items: _clients,
      labelOf: (c) => c.name,
      subtitleOf: (c) => c.address,
    );
    if (picked != null) setState(() => _selectedClient = picked);
  }

  Future<void> _pickProduct() async {
    final alreadyAdded = _editItems.map((li) => li.product.id).toSet();
    final available =
        _products.where((p) => !alreadyAdded.contains(p.id)).toList();
    if (available.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All products already added.')));
      }
      return;
    }

    // Pre-load inventory for products not yet cached
    for (final p in available) {
      if (!_inventoryCache.containsKey(p.id)) {
        _inventoryCache[p.id] = await ref
            .read(inventoryRepositoryProvider)
            .getByProductId(p.id);
      }
    }

    if (!mounted) return;
    final picked = await showSearchPicker<Product>(
      context: context,
      title: 'Select Product',
      items: available,
      labelOf: (p) => '${p.name} x ${p.piecesPerBox}',
      searchableOf: (p) => '${p.name} ${p.productCode ?? ''}',
      leadingOf: (p) => _stockIndicator(_inventoryCache[p.id]?.quantityPieces ?? 0),
      subtitleOf: (p) => _stockLabel(p, _inventoryCache[p.id]?.quantityPieces ?? 0),
      subtitleStyleOf: (p) {
        final qty = _inventoryCache[p.id]?.quantityPieces ?? 0;
        return TextStyle(color: qty > 0 ? Colors.green.shade700 : Colors.red);
      },
      isDisabledOf: (p) => (_inventoryCache[p.id]?.quantityPieces ?? 0) <= 0,
    );
    if (picked != null) await _addProduct(picked);
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
      _editItems.add(_EditItem(
        itemId: const Uuid().v4(),
        product: product,
        pricePerPiece: price!.sellingPrice,
        inventory: inv,
        unitType: 'piece',
        quantity: 1,
        originalPieces: 0,
        discount: disc,
      ));
    });
  }

  double get _total =>
      _editItems.fold(0.0, (sum, item) => sum + item.subtotal);

  double? get _actualAmount =>
      double.tryParse(_actualAmountCtrl.text.trim());

  bool get _canSave {
    if (_selectedClient == null || _editItems.isEmpty) return false;
    return _editItems.every((item) {
      final currentInv = item.inventory?.quantityPieces ?? 0;
      return item.hasEnoughStock(currentInv);
    });
  }

  Future<void> _saveOnly() async {
    setState(() => _saving = true);

    final partial = _paymentType == 'partial';
    final updatedInvoice = _invoice!.copyWith(
      clientId: _selectedClient!.id,
      invoiceDate: _invoiceDate,
      totalAmount: _total,
      paymentType: _paymentType,
      partialAmount: partial
          ? double.tryParse(_partialAmountCtrl.text)
          : null,
      partialDate: partial ? _partialDate : null,
      checkReference: _paymentType == 'check'
          ? (_checkRefCtrl.text.trim().isEmpty ? null : _checkRefCtrl.text.trim())
          : null,
      checkAmount: _paymentType == 'check'
          ? double.tryParse(_checkAmountCtrl.text)
          : null,
      checkDueDate: _paymentType == 'check' ? _checkDueDate : null,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      actualAmount: _actualAmount,
    );
    final newItems = _editItems
        .map((li) => li.toInvoiceItem(widget.invoiceId))
        .toList();

    await ref.read(invoiceRepositoryProvider).editInvoice(
          invoice: updatedInvoice,
          newItems: newItems,
          oldItems: _originalItems,
        );

    ref.invalidate(invoicesListProvider);
    ref.invalidate(filteredInvoicesProvider);
    ref.invalidate(inventoryListProvider);

    if (mounted) _goBack();
  }

  Future<void> _saveAndPrint() async {
    setState(() => _saving = true);

    final partial = _paymentType == 'partial';
    final updatedInvoice = _invoice!.copyWith(
      clientId: _selectedClient!.id,
      totalAmount: _total,
      status: 'printed',
      paymentType: _paymentType,
      partialAmount: partial
          ? double.tryParse(_partialAmountCtrl.text)
          : null,
      partialDate: partial ? _partialDate : null,
      checkReference: _paymentType == 'check'
          ? (_checkRefCtrl.text.trim().isEmpty ? null : _checkRefCtrl.text.trim())
          : null,
      checkAmount: _paymentType == 'check'
          ? double.tryParse(_checkAmountCtrl.text)
          : null,
      checkDueDate: _paymentType == 'check' ? _checkDueDate : null,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      actualAmount: _actualAmount,
    );
    final newItems = _editItems
        .map((li) => li.toInvoiceItem(widget.invoiceId))
        .toList();

    await ref.read(invoiceRepositoryProvider).editInvoice(
          invoice: updatedInvoice,
          newItems: newItems,
          oldItems: _originalItems,
        );

    ref.invalidate(invoicesListProvider);
    ref.invalidate(filteredInvoicesProvider);
    ref.invalidate(inventoryListProvider);

    final productsById = {
      for (final li in _editItems) li.product.id: li.product
    };
    await printInvoice(
      invoice: updatedInvoice,
      client: _selectedClient!,
      items: newItems,
      productsById: productsById,
    );

    if (mounted) _goBack();
  }

  Future<void> _deleteInvoice() async {
    final isPrinted = _invoice!.status == 'printed';
    final ok = await showConfirmDialog(
      context,
      title: 'Delete Invoice',
      message: isPrinted
          ? 'Delete this invoice? Since it was printed, the ordered stock will be restored to inventory.'
          : 'Delete this invoice? This cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (ok) {
      await ref.read(invoiceRepositoryProvider).deleteInvoice(_invoice!);
      ref.invalidate(invoicesListProvider);
      ref.invalidate(filteredInvoicesProvider);
      ref.invalidate(inventoryListProvider);
      if (mounted) _goBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = _invoice?.status == 'cancelled';
    final dateFmt = DateFormat('MMM dd, yyyy HH:mm');

    return AppScaffold(
      title: 'Invoice Detail',
      actions: [
        if (!isCancelled && !_loading)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Delete Invoice',
            onPressed: _saving ? null : _deleteInvoice,
          ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Invoice header chip row
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'Invoice ${_invoice!.displayNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      if (!isCancelled)
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _invoiceDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _invoiceDate = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    _invoiceDate.hour,
                                    _invoiceDate.minute,
                                    _invoiceDate.second,
                                  ));
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(dateFmt.format(_invoiceDate),
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              const SizedBox(width: 4),
                              const Icon(Icons.edit_calendar,
                                  size: 14, color: Colors.grey),
                            ],
                          ),
                        )
                      else
                        Text(dateFmt.format(_invoiceDate),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      const Spacer(),
                      Chip(
                        label: Text(_invoice!.invoiceType == 'delivery'
                            ? 'Delivery'
                            : 'Walk-in'),
                        backgroundColor: _invoice!.isDelivery
                            ? Colors.blue.shade100
                            : Colors.purple.shade100,
                        padding: EdgeInsets.zero,
                        labelPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      const SizedBox(width: 4),
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
                        onChanged: !isCancelled
                            ? (v) => setState(() => _paymentType = v!)
                            : null,
                      ),
                      const SizedBox(width: 4),
                      Chip(
                        label: Text(_invoice!.status.toUpperCase()),
                        backgroundColor: isCancelled
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                        padding: EdgeInsets.zero,
                        labelPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ],
                  ),
                ),

                if (!isCancelled) ...[
                  // Check fields
                  if (_paymentType == 'check') ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _checkAmountCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Check Amount',
                                prefixText: '₱ ',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: const TextInputType
                                  .numberWithOptions(decimal: true),
                              readOnly: isCancelled,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: isCancelled ? null : () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      _checkDueDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() => _checkDueDate = picked);
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Due Date',
                                  suffixIcon: Icon(
                                      Icons.calendar_today, size: 18),
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                child: Text(
                                  _checkDueDate == null
                                      ? 'Select date'
                                      : '${_checkDueDate!.year}-'
                                        '${_checkDueDate!.month.toString().padLeft(2, '0')}-'
                                        '${_checkDueDate!.day.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    color: _checkDueDate == null
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: TextField(
                        controller: _checkRefCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Check Reference No.',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        readOnly: isCancelled,
                      ),
                    ),

                    // Add cash payment row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _partialAmountCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Add Payment',
                                prefixText: '₱ ',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: const TextInputType
                                  .numberWithOptions(decimal: true),
                              readOnly: isCancelled,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: InkWell(
                              onTap: isCancelled ? null : () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      _partialDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() => _partialDate = picked);
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date',
                                  suffixIcon: Icon(
                                      Icons.calendar_today, size: 18),
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                child: Text(
                                  _partialDate == null
                                      ? 'Select date'
                                      : DateFormat('MMM dd, yyyy')
                                          .format(_partialDate!),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _partialDate == null
                                        ? Theme.of(context).hintColor
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          FilledButton(
                            onPressed:
                                isCancelled ? null : _addPayment,
                            style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12)),
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    ),

                    // Payment history
                    if (_payments.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(12, 4, 12, 2),
                        child: Text('Payment History',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                      ..._payments.map((p) => ListTile(
                            dense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            title: Text(formatCurrency(p.amount),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            subtitle: p.paymentDate == null
                                ? null
                                : Text(DateFormat('MMM dd, yyyy')
                                    .format(p.paymentDate!)),
                            trailing: isCancelled
                                ? null
                                : IconButton(
                                    icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                        size: 18),
                                    onPressed: () =>
                                        _deletePayment(p.id),
                                  ),
                          )),
                    ],

                    // Balance summary
                    Builder(builder: (_) {
                      final checkAmt =
                          double.tryParse(_checkAmountCtrl.text) ?? 0.0;
                      final cashPaid =
                          _payments.fold(0.0, (s, p) => s + p.amount);
                      final balance =
                          (_total - checkAmt - cashPaid)
                              .clamp(0.0, double.infinity);
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                        child: Column(
                          children: [
                            const Divider(height: 8),
                            Row(children: [
                              const Text('Check Amount:',
                                  style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 8),
                              Text(formatCurrency(checkAmt),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ]),
                            if (cashPaid > 0) ...[
                              const SizedBox(height: 2),
                              Row(children: [
                                const Text('Cash Payments:',
                                    style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 8),
                                Text(formatCurrency(cashPaid),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                              ]),
                            ],
                            const SizedBox(height: 2),
                            Row(children: [
                              const Text('Balance:',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(width: 8),
                              Text(
                                formatCurrency(balance),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: balance > 0
                                      ? Colors.red.shade700
                                      : Colors.green.shade700,
                                ),
                              ),
                            ]),
                          ],
                        ),
                      );
                    }),
                  ],

                  // Partial payment — add form + history
                  if (_paymentType == 'partial') ...[
                    // Add payment row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _partialAmountCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Amount',
                                prefixText: '₱ ',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: const TextInputType
                                  .numberWithOptions(decimal: true),
                              readOnly: isCancelled,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: InkWell(
                              onTap: isCancelled ? null : () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      _partialDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() => _partialDate = picked);
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date',
                                  suffixIcon: Icon(
                                      Icons.calendar_today, size: 18),
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                child: Text(
                                  _partialDate == null
                                      ? 'Select date'
                                      : DateFormat('MMM dd, yyyy')
                                          .format(_partialDate!),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _partialDate == null
                                        ? Theme.of(context).hintColor
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          FilledButton(
                            onPressed: isCancelled ? null : _addPayment,
                            style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12)),
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    ),

                    // Payment history
                    if (_payments.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(12, 4, 12, 2),
                        child: Text('Payment History',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                      ..._payments.map((p) => ListTile(
                            dense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            title: Text(formatCurrency(p.amount),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            subtitle: p.paymentDate == null
                                ? null
                                : Text(DateFormat('MMM dd, yyyy')
                                    .format(p.paymentDate!)),
                            trailing: isCancelled
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red, size: 18),
                                    onPressed: () => _deletePayment(p.id),
                                  ),
                          )),
                    ],

                    // Totals
                    Builder(builder: (_) {
                      final totalPaid =
                          _payments.fold(0.0, (s, p) => s + p.amount);
                      final balance = (_total - totalPaid)
                          .clamp(0.0, double.infinity);
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                        child: Column(
                          children: [
                            const Divider(height: 8),
                            Row(children: [
                              const Text('Total Paid:',
                                  style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 8),
                              Text(formatCurrency(totalPaid),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ]),
                            const SizedBox(height: 2),
                            Row(children: [
                              const Text('Balance:',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(width: 8),
                              Text(
                                formatCurrency(balance),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: balance > 0
                                      ? Colors.red.shade700
                                      : Colors.green.shade700,
                                ),
                              ),
                            ]),
                          ],
                        ),
                      );
                    }),
                  ],

                  // Client selector
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
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
                  if (_selectedClient?.address != null &&
                      _selectedClient!.address!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _selectedClient!.address!,
                          style: TextStyle(
                              fontSize: 12, color: Theme.of(context).hintColor),
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
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Items header + add button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          'Items (${_editItems.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Product'),
                          onPressed: _pickProduct,
                        ),
                      ],
                    ),
                  ),

                  // Editable items list
                  Expanded(
                    child: _editItems.isEmpty
                        ? const Center(
                            child: Text('No items. Tap "Add Product".'))
                        : ListView.builder(
                            itemCount: _editItems.length,
                            itemBuilder: (ctx, i) {
                              final item = _editItems[i];
                              final currentInv =
                                  item.inventory?.quantityPieces ?? 0;
                              return _EditItemTile(
                                item: item,
                                currentInventoryPieces: currentInv,
                                onRemove: () =>
                                    setState(() => _editItems.removeAt(i)),
                                onChanged: () => setState(() {}),
                              );
                            },
                          ),
                  ),

                  // Total + actions bar
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
                                '${_editItems.length} item${_editItems.length == 1 ? '' : 's'}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                'Total: ${formatCurrency(_total)}',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => _goBack(),
                          child: const Text('Back'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          icon: _saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))
                              : const Icon(Icons.save_outlined),
                          label: const Text('Save'),
                          onPressed:
                              _canSave && !_saving ? _saveOnly : null,
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
                          label: const Text('Save & Print'),
                          onPressed:
                              _canSave && !_saving ? _saveAndPrint : null,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Read-only view for cancelled invoices
                  Expanded(child: _buildCancelledView()),
                ],
              ],
            ),
    );
  }

  Widget _buildCancelledView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedClient != null) ...[
            Text('Client: ${_selectedClient!.name}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (_selectedClient!.address != null)
              Text(_selectedClient!.address!),
            const SizedBox(height: 12),
          ],
          Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            columnWidths: const {
              0: FlexColumnWidth(4),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(2),
            },
            children: [
              _headerRow(['Product', 'Unit', 'Qty', 'Subtotal']),
              ..._editItems.map((item) => _dataRow([
                    '${item.product.name} x ${item.product.piecesPerBox}',
                    item.unitType,
                    '${item.quantity}',
                    formatCurrency(item.subtotal),
                  ])),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text('Total: ${formatCurrency(_total)}',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          if (_invoice?.notes != null && _invoice!.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Notes', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(_invoice!.notes!),
          ],
        ],
      ),
    );
  }

  TableRow _headerRow(List<String> cells) => TableRow(
        decoration: BoxDecoration(color: Colors.grey.shade200),
        children: cells
            .map((c) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(c,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                ))
            .toList(),
      );

  TableRow _dataRow(List<String> cells) => TableRow(
        children: cells
            .map((c) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(c),
                ))
            .toList(),
      );
}

// ── Editable item tile ────────────────────────────────────────────────────────

class _EditItemTile extends StatefulWidget {
  final _EditItem item;
  final int currentInventoryPieces;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _EditItemTile({
    required this.item,
    required this.currentInventoryPieces,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<_EditItemTile> createState() => _EditItemTileState();
}

class _EditItemTileState extends State<_EditItemTile> {
  late TextEditingController _qtyCtrl;

  @override
  void initState() {
    super.initState();
    _qtyCtrl =
        TextEditingController(text: widget.item.quantity.toString());
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final stockOk = item.hasEnoughStock(widget.currentInventoryPieces);
    final effectiveAvail =
        item.effectiveAvailable(widget.currentInventoryPieces);

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
                  if (!stockOk)
                    Text(
                      'Only $effectiveAvail pcs available',
                      style: const TextStyle(
                          color: Colors.red, fontSize: 12),
                    ),
                  if (item.isFree)
                    Text('FREE',
                        style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12))
                  else if (item.discountAmount > 0) ...[
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
                      '@ ${formatCurrency(item.pricePerPiece)}/pc  •  ${formatCurrency(item.subtotal)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
            // Free toggle
            IconButton(
              icon: Icon(
                item.isFree
                    ? Icons.card_giftcard
                    : Icons.card_giftcard_outlined,
                color: item.isFree ? Colors.green : Colors.grey,
                size: 20,
              ),
              tooltip:
                  item.isFree ? 'Remove free' : 'Mark as free',
              onPressed: () {
                setState(() => item.isFree = !item.isFree);
                widget.onChanged();
              },
            ),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'piece', label: Text('Pcs')),
                ButtonSegment(value: 'box', label: Text('Box')),
              ],
              selected: {item.unitType},
              onSelectionChanged: (s) {
                final pieces = item.quantityInPieces;
                setState(() {
                  item.unitType = s.first;
                  item.quantity = item.unitType == 'box'
                      ? (pieces / item.product.piecesPerBox)
                          .round()
                          .clamp(1, 9999)
                      : pieces;
                  _qtyCtrl.text = item.quantity.toString();
                });
                widget.onChanged();
              },
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 70,
              child: TextField(
                controller: _qtyCtrl,
                decoration: const InputDecoration(
                    labelText: 'Qty', isDense: true),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                onChanged: (v) {
                  item.quantity = int.tryParse(v) ?? 1;
                  if (item.quantity < 1) item.quantity = 1;
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
