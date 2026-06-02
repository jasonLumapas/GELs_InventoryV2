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
import '../../repositories/client_repository.dart';
import '../../repositories/inventory_repository.dart';
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
      return discount!.discountValue.clamp(0.0, originalAmount);
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
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final invoices = await ref.read(invoiceRepositoryProvider).getAll();
    _invoice =
        invoices.where((i) => i.id == widget.invoiceId).firstOrNull;
    if (_invoice == null) {
      if (mounted) context.go('/invoices');
      return;
    }

    _originalItems =
        await ref.read(invoiceRepositoryProvider).getItems(widget.invoiceId);
    _clients = await ref.read(clientRepositoryProvider).getAll();
    _products = await ref.read(productRepositoryProvider).getAll();
    _productsById = {for (final p in _products) p.id: p};
    _selectedClient =
        _clients.where((c) => c.id == _invoice!.clientId).firstOrNull;

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
      labelOf: (p) => p.name,
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

  bool get _canSave {
    if (_selectedClient == null || _editItems.isEmpty) return false;
    return _editItems.every((item) {
      final currentInv = item.inventory?.quantityPieces ?? 0;
      return item.hasEnoughStock(currentInv);
    });
  }

  Future<void> _saveAndPrint() async {
    setState(() => _saving = true);

    final updatedInvoice = _invoice!.copyWith(
      clientId: _selectedClient!.id,
      totalAmount: _total,
      status: 'printed',
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

    if (mounted) context.go('/invoices');
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
      if (mounted) context.go('/invoices');
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
                      Text(dateFmt.format(_invoice!.invoiceDate),
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

                  // Items header + add button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        const Text('Items',
                            style:
                                TextStyle(fontWeight: FontWeight.bold)),
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
                          child: Text(
                            'Total: ${formatCurrency(_total)}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => context.go('/invoices'),
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
                    item.product.name,
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
                  Text(item.product.name,
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
