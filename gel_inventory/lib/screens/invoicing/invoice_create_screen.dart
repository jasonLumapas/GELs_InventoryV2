import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../models/client.dart';
import '../../models/invoice.dart';
import '../../models/invoice_item.dart';
import '../../models/inventory_item.dart';
import '../../models/product.dart';
import '../../models/product_price.dart';
import '../../repositories/client_repository.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/invoice_repository.dart';
import '../../repositories/product_repository.dart';
import '../../utils/currency_format.dart';
import '../../utils/pdf_generator.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/search_picker.dart';

class _LineItem {
  final Product product;
  final ProductPrice price;
  final InventoryItem? inventory;
  String unitType = 'piece'; // 'box' | 'piece'
  int quantity = 1;

  _LineItem({
    required this.product,
    required this.price,
    required this.inventory,
  });

  int get quantityInPieces =>
      unitType == 'box' ? quantity * product.piecesPerBox : quantity;

  double get subtotal => quantityInPieces * price.sellingPrice;

  bool get hasEnoughStock =>
      inventory == null
          ? false
          : inventory!.quantityPieces >= quantityInPieces;
}

class InvoiceCreateScreen extends ConsumerStatefulWidget {
  const InvoiceCreateScreen({super.key});

  @override
  ConsumerState<InvoiceCreateScreen> createState() =>
      _InvoiceCreateScreenState();
}

class _InvoiceCreateScreenState extends ConsumerState<InvoiceCreateScreen> {
  List<Client> _clients = [];
  List<Product> _products = [];
  final Map<String, ProductPrice?> _priceCache = {};
  final Map<String, InventoryItem?> _inventoryCache = {};
  Client? _selectedClient;
  final List<_LineItem> _lineItems = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final clients = await ref.read(clientRepositoryProvider).getAll();
    final products = await ref.read(productRepositoryProvider).getAll();
    setState(() {
      _clients = clients;
      _products = products;
      _loading = false;
    });
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
    final alreadyAdded = _lineItems.map((li) => li.product.id).toSet();
    final available =
        _products.where((p) => !alreadyAdded.contains(p.id)).toList();
    if (available.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All products already added.')));
      }
      return;
    }

    // Pre-load inventory for products not yet cached so the picker can show stock levels
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
    return boxes > 0 ? '$boxes box(es) + $rem pcs  ($qty pcs total)' : '$qty pcs available';
  }

  Future<void> _addProduct(Product product) async {
    var price = _priceCache[product.id];
    if (!_priceCache.containsKey(product.id)) {
      price =
          await ref.read(productRepositoryProvider).getCurrentPrice(product.id);
      _priceCache[product.id] = price;
    }
    var inv = _inventoryCache[product.id];
    if (!_inventoryCache.containsKey(product.id)) {
      inv = await ref
          .read(inventoryRepositoryProvider)
          .getByProductId(product.id);
      _inventoryCache[product.id] = inv;
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
      _lineItems.add(_LineItem(product: product, price: price!, inventory: inv));
    });
  }

  double get _total =>
      _lineItems.fold(0.0, (sum, item) => sum + item.subtotal);

  bool get _canPrint =>
      _selectedClient != null &&
      _lineItems.isNotEmpty &&
      _lineItems.every((i) => i.hasEnoughStock);

  Future<void> _print() async {
    setState(() => _saving = true);
    final invoiceId = const Uuid().v4();
    final now = DateTime.now();
    final invoiceNumber = await ref
        .read(invoiceRepositoryProvider)
        .generateInvoiceNumber(now);
    final invoice = Invoice(
      id: invoiceId,
      clientId: _selectedClient!.id,
      invoiceDate: now,
      totalAmount: _total,
      status: 'printed',
      createdAt: now,
      invoiceNumber: invoiceNumber,
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
                // Client selector
                Padding(
                  padding: const EdgeInsets.all(12),
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

                // Add item row
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                            onRemove: () =>
                                setState(() => _lineItems.removeAt(i)),
                            onChanged: () => setState(() {}),
                          ),
                        ),
                ),

                // Total + actions
                Container(
                  color:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total: ${formatCurrency(_total)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.print),
                        label: const Text('Print'),
                        onPressed: _canPrint && !_saving ? _print : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

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
    final stockOk = item.hasEnoughStock;
    final availQty = item.inventory?.quantityPieces ?? 0;
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
                      'Only $availQty pcs available',
                      style:
                          const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  Text('Subtotal: ${formatCurrency(item.subtotal)}',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
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
                decoration:
                    const InputDecoration(labelText: 'Qty', isDense: true),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
