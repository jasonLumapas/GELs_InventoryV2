import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/product.dart';
import '../../models/van_stock.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/van_stock_repository.dart';
import '../../utils/currency_format.dart';
import '../../widgets/common/app_scaffold.dart';

class VanSellingScreen extends ConsumerStatefulWidget {
  const VanSellingScreen({super.key});

  @override
  ConsumerState<VanSellingScreen> createState() => _VanSellingScreenState();
}

class _VanSellingScreenState extends ConsumerState<VanSellingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<Product> _products = [];
  List<VanStock> _transactions = [];
  Map<String, int> _vanBalance = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _products = await ref.read(productRepositoryProvider).getAll();
    _transactions = await ref.read(vanStockRepositoryProvider).getAll();
    _vanBalance =
        await ref.read(vanStockRepositoryProvider).getCurrentVanStock();
    setState(() => _loading = false);
  }

  Future<void> _showTransactionDialog({required bool isOut}) async {
    Product? selectedProduct;
    final qtyCtrl = TextEditingController(text: '1');
    String unitType = 'piece';
    final notesCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(isOut ? 'Load Van (Out)' : 'Return to Warehouse (In)'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Product>(
                  decoration:
                      const InputDecoration(labelText: 'Product'),
                  isExpanded: true,
                  items: _products
                      .map((p) => DropdownMenuItem(
                          value: p, child: Text(p.name, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) => setD(() => selectedProduct = v),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'piece', label: Text('Pieces')),
                    ButtonSegment(value: 'box', label: Text('Boxes')),
                  ],
                  selected: {unitType},
                  onSelectionChanged: (s) => setD(() => unitType = s.first),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: qtyCtrl,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Notes (optional)'),
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
                final product = selectedProduct;
                if (product == null) return;
                final qty = int.tryParse(qtyCtrl.text) ?? 0;
                if (qty <= 0) return;
                final pieces = unitType == 'box'
                    ? qty * product.piecesPerBox
                    : qty;
                await ref.read(vanStockRepositoryProvider).record(
                      productId: product.id,
                      type: isOut ? 'out' : 'in',
                      quantityPieces: pieces,
                      notes: notesCtrl.text.trim().isEmpty
                          ? null
                          : notesCtrl.text.trim(),
                    );
                if (ctx.mounted) Navigator.pop(ctx);
                _load();
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsById = {for (final p in _products) p.id: p};
    final dateFmt = DateFormat('MMM dd HH:mm');

    return AppScaffold(
      title: 'Van Selling',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TabBar(
                  controller: _tabs,
                  tabs: const [
                    Tab(text: 'Van Stock'),
                    Tab(text: 'Transactions'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      // ── Van Stock summary ─────────────────────────────
                      Column(
                        children: [
                          // Action buttons
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    icon: const Icon(Icons.arrow_upward),
                                    label: const Text('Load Van (Out)'),
                                    onPressed: () => _showTransactionDialog(
                                        isOut: true),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.arrow_downward),
                                    label: const Text('Return (In)'),
                                    onPressed: () => _showTransactionDialog(
                                        isOut: false),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: _vanBalance.isEmpty
                                ? const Center(
                                    child: Text('No van stock yet.'))
                                : ListView.separated(
                                    itemCount: _products.length,
                                    separatorBuilder: (_, _) =>
                                        const Divider(height: 1),
                                    itemBuilder: (ctx, i) {
                                      final p = _products[i];
                                      final bal =
                                          _vanBalance[p.id] ?? 0;
                                      if (bal == 0) {
                                        return const SizedBox.shrink();
                                      }
                                      final boxes =
                                          bal ~/ p.piecesPerBox;
                                      final rem = bal % p.piecesPerBox;
                                      return ListTile(
                                        leading: const Icon(
                                            Icons.local_shipping),
                                        title: Text(p.name),
                                        subtitle: Text(
                                            '$boxes box(es) + $rem pcs'),
                                        trailing: Text(
                                          '${formatNumber(bal)} pcs',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),

                      // ── Transaction log ───────────────────────────────
                      _transactions.isEmpty
                          ? const Center(
                              child: Text('No transactions yet.'))
                          : ListView.separated(
                              itemCount: _transactions.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (ctx, i) {
                                final tx = _transactions[i];
                                final product = productsById[tx.productId];
                                final ppb = product?.piecesPerBox ?? 1;
                                final boxes =
                                    tx.quantityPieces ~/ ppb;
                                final rem = tx.quantityPieces % ppb;
                                return ListTile(
                                  leading: Icon(
                                    tx.isOut
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: tx.isOut
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  title: Text(product?.name ?? tx.productId),
                                  subtitle: Text(
                                    '${tx.isOut ? 'Out' : 'In'}  •  '
                                    '$boxes box(es) + $rem pcs'
                                    '${tx.notes != null ? '  •  ${tx.notes}' : ''}',
                                  ),
                                  trailing: Text(
                                      dateFmt.format(tx.date),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey)),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
