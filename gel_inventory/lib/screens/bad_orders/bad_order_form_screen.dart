import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/bad_order.dart';
import '../../models/bad_order_item.dart';
import '../../models/client.dart';
import '../../models/product.dart';
import '../../repositories/bad_order_repository.dart';
import '../../repositories/client_repository.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/invoice_repository.dart';
import '../../repositories/product_repository.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/search_picker.dart';

class BadOrderFormScreen extends ConsumerStatefulWidget {
  const BadOrderFormScreen({super.key});

  @override
  ConsumerState<BadOrderFormScreen> createState() => _BadOrderFormScreenState();
}

class _BadOrderFormScreenState extends ConsumerState<BadOrderFormScreen> {
  final _notesCtrl = TextEditingController();
  List<Client> _clients = [];
  List<Product> _products = [];
  Client? _selectedClient;
  String _type = 'bad_order'; // 'bad_order' | 'return'
  DateTime _selectedDate = DateTime.now();
  final List<_BoItem> _items = [];
  bool _loading = true;
  bool _saving = false;
  Set<String> _orderedProductIds = {};
  bool _loadingOrderedProducts = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _clients = await ref.read(clientRepositoryProvider).getAll();
    _products = await ref.read(productRepositoryProvider).getAll();
    setState(() => _loading = false);
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
        _selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);
    final invoices = await ref.read(invoiceRepositoryProvider).getAll();
    final ids = <String>{};
    for (final inv in invoices.where(
        (i) => i.clientId == client.id && !i.invoiceDate.isAfter(cutoff))) {
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
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select a client first.')));
      return;
    }
    final already = _items.map((i) => i.productId).toSet();
    final available = _products
        .where((p) =>
            !already.contains(p.id) && _orderedProductIds.contains(p.id))
        .toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('No previously ordered products found for this client.')));
      return;
    }
    final picked = await showSearchPicker<Product>(
      context: context,
      title: 'Select Product',
      items: available,
      labelOf: (p) => p.name,
      searchableOf: (p) => '${p.name} ${p.productCode ?? ''}',
    );
    if (picked != null) {
      setState(() => _items.add(_BoItem(
            productId: picked.id,
            productName: picked.name,
            piecesPerBox: picked.piecesPerBox,
          )));
    }
  }

  Future<void> _save() async {
    if (_selectedClient == null || _items.isEmpty) return;
    setState(() => _saving = true);
    final now = DateTime.now();
    final order = BadOrder(
      id: const Uuid().v4(),
      clientId: _selectedClient!.id,
      date: _selectedDate,
      type: _type,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: now,
    );
    final items = _items
        .map((i) => BadOrderItem(
              id: const Uuid().v4(),
              badOrderId: order.id,
              productId: i.productId,
              unitType: i.unitType,
              quantity: i.quantity,
            ))
        .toList();
    final ppbMap = {for (final p in _products) p.id: p.piecesPerBox};
    await ref
        .read(badOrderRepositoryProvider)
        .save(order: order, items: items, piecesPerBoxByProduct: ppbMap);
    ref.invalidate(badOrdersListProvider);
    ref.invalidate(inventoryListProvider);
    if (mounted) context.go('/bad-orders');
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                              label: Text('Bad Order')),
                          ButtonSegment(
                              value: 'return',
                              icon: Icon(Icons.undo, size: 16),
                              label: Text('Return')),
                        ],
                        selected: {_type},
                        onSelectionChanged: (s) =>
                            setState(() => _type = s.first),
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
                      else
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Bad orders will NOT restore inventory.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
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
                              DateFormat('MMM dd, yyyy').format(_selectedDate)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Client
                      InkWell(
                        onTap: _pickClient,
                        borderRadius: BorderRadius.circular(4),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Client',
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
                      const SizedBox(height: 8),
                      // Notes
                      TextField(
                        controller: _notesCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Notes (optional)'),
                      ),
                    ],
                  ),
                ),
                // Items header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      const Text('Items',
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
                        onPressed: _loadingOrderedProducts ? null : _pickProduct,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _items.isEmpty
                      ? Center(
                          child: Text(
                            _selectedClient == null
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
                            onRemove: () =>
                                setState(() => _items.removeAt(i)),
                            onChanged: () => setState(() {}),
                          ),
                        ),
                ),
                // Save bar
                Container(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => context.go('/bad-orders'),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: (_selectedClient != null &&
                                _items.isNotEmpty &&
                                !_saving)
                            ? _save
                            : null,
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
  String unitType = 'piece';
  int quantity = 1;

  _BoItem({
    required this.productId,
    required this.productName,
    required this.piecesPerBox,
  });
}

class _BoItemTile extends StatefulWidget {
  final _BoItem item;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _BoItemTile({
    required this.item,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<_BoItemTile> createState() => _BoItemTileState();
}

class _BoItemTileState extends State<_BoItemTile> {
  late TextEditingController _qtyCtrl;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Text(item.productName,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
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
                decoration: const InputDecoration(
                    labelText: 'Qty', isDense: true),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) {
                  item.quantity = int.tryParse(v) ?? 1;
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
