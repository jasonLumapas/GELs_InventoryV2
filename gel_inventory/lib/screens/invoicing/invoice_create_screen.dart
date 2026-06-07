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
  const InvoiceCreateScreen({super.key});

  @override
  ConsumerState<InvoiceCreateScreen> createState() =>
      _InvoiceCreateScreenState();
}

class _InvoiceCreateScreenState extends ConsumerState<InvoiceCreateScreen> {
  List<Client> _clients = [];
  List<Product> _products = [];
  Map<String, String> _supplierNames = {}; // productId → supplier name
  final Map<String, ProductPrice?> _priceCache = {};
  final Map<String, InventoryItem?> _inventoryCache = {};
  final Map<String, ProductDiscount?> _discountCache = {};
  Client? _selectedClient;
  String _invoiceType  = 'delivery';
  String _paymentType  = 'cash';
  DateTime _invoiceDate =
      DateTime.now().add(const Duration(days: 1));
  String? _invoiceNumber;
  final List<_LineItem> _lineItems = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final clients   = await ref.read(clientRepositoryProvider).getAll();
    final products  = await ref.read(productRepositoryProvider).getAll();
    final suppliers = await ref.read(supplierRepositoryProvider).getAll();
    final invoiceNum = await ref
        .read(invoiceRepositoryProvider)
        .generateInvoiceNumber(_invoiceDate);
    final suppMap = {for (final s in suppliers) s.id: s.name};
    setState(() {
      _clients  = clients;
      _products = products;
      _supplierNames = {for (final p in products) p.id: suppMap[p.supplierId] ?? ''};
      _invoiceNumber = invoiceNum;
      _loading  = false;
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
      final num = await ref
          .read(invoiceRepositoryProvider)
          .generateInvoiceNumber(picked);
      if (mounted) setState(() => _invoiceNumber = num);
    }
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
      labelOf: (p) => p.name,
      searchableOf: (p) => '${p.name} ${p.productCode ?? ''}',
      leadingOf: (p) => _stockIndicator(_effectiveAvailable(p.id)),
      subtitleOf: (p) => _stockLabel(p, _effectiveAvailable(p.id)),
      subtitleStyleOf: (p) {
        final qty = _effectiveAvailable(p.id);
        return TextStyle(
            color: qty > 0 ? Colors.green.shade700 : Colors.red);
      },
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

  Future<void> _print() async {
    setState(() => _saving = true);
    final invoiceId = const Uuid().v4();
    final invoiceNumber = await ref
        .read(invoiceRepositoryProvider)
        .generateInvoiceNumber(_invoiceDate);
    final invoice = Invoice(
      id: invoiceId,
      clientId: _selectedClient!.id,
      invoiceDate: _invoiceDate,
      totalAmount: _total,
      status: 'printed',
      createdAt: DateTime.now(),
      invoiceNumber: invoiceNumber,
      invoiceType:  _invoiceType,
      paymentType:  _paymentType,
    );

    final items = _lineItems.map((li) {
      return InvoiceItem(
        id: const Uuid().v4(),
        invoiceId: invoiceId,
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

    await ref.read(invoiceRepositoryProvider).saveInvoice(
          invoice: invoice,
          items: items,
        );

    ref.invalidate(invoicesListProvider);
    ref.invalidate(filteredInvoicesProvider);
    ref.invalidate(inventoryListProvider);

    final productsById = {
      for (final li in _lineItems) li.product.id: li.product
    };
    await printInvoice(
      invoice: invoice,
      client: _selectedClient!,
      items: items,
      productsById: productsById,
    );

    if (mounted) context.go('/invoices');
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Text(
                    'Invoice #: ${_invoiceNumber ?? '...'}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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
                        onSelectionChanged: (s) =>
                            setState(() => _invoiceType = s.first),
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
                        onChanged: (v) => setState(() => _paymentType = v!),
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
                            onRemove: () =>
                                setState(() => _lineItems.removeAt(i)),
                            onChanged: () => setState(() {}),
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
                        child: Text(
                          'Total: ${formatCurrency(_total)}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => context.go('/invoices'),
                        child: const Text('Cancel'),
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

  const _LineItemTile({
    required this.item,
    required this.effectiveAvailable,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<_LineItemTile> createState() => _LineItemTileState();
}

class _LineItemTileState extends State<_LineItemTile> {
  late TextEditingController _qtyCtrl;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(text: '');
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
                  Text(item.product.name,
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
