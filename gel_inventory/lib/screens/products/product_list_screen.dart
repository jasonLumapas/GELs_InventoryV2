import 'dart:io';

import 'package:excel/excel.dart' as xlsx;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/product.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../utils/currency_format.dart';
import '../../utils/pdf_generator.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/confirm_dialog.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen>
    with SingleTickerProviderStateMixin {
  // Persisted across navigations away from and back to this screen.
  static String? _persistedSupplierId;
  static double _persistedScrollOffset = 0;

  late String? _selectedSupplierId;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  late ScrollController _scrollCtrl;

  late final TabController _tabController =
      TabController(length: 2, vsync: this);
  final _priceListSearchCtrl = TextEditingController();
  String _priceListSearch = '';

  @override
  void initState() {
    super.initState();
    _selectedSupplierId = _persistedSupplierId;
    _scrollCtrl = ScrollController(initialScrollOffset: _persistedScrollOffset);
    _scrollCtrl.addListener(() {
      _persistedScrollOffset = _scrollCtrl.offset;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _tabController.dispose();
    _priceListSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Products',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Add product',
          onPressed: () => context.go('/products/new'),
        ),
      ],
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Products'),
              Tab(text: 'Price List'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsTab(),
                _buildPriceListTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    final productsAsync  = ref.watch(productsListProvider);
    final suppliersAsync = ref.watch(suppliersListProvider);
    final suppliers      = suppliersAsync.valueOrNull ?? [];
    final suppliersMap   = {for (final s in suppliers) s.id: s};

    return Column(
      children: [
        // ── Search ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              hintText: 'Search product…',
              prefixIcon: Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _searchQuery = v.trim()),
          ),
        ),

        // ── Supplier filter ──────────────────────────────────────────
        if (suppliers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                const Text('Supplier:',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String?>(
                    value: _selectedSupplierId,
                    isDense: true,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('All Suppliers')),
                      ...suppliers.map((s) => DropdownMenuItem(
                          value: s.id, child: Text(s.name))),
                    ],
                    onChanged: (v) => setState(() {
                      _selectedSupplierId = v;
                      _persistedSupplierId = v;
                    }),
                  ),
                ),
              ],
            ),
          ),
        const Divider(height: 1),

        // ── Product list ─────────────────────────────────────────────
        Expanded(
          child: productsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (allProducts) {
              final q = _searchQuery.toLowerCase();
              final products = allProducts.where((p) {
                final matchesSupplier = _selectedSupplierId == null ||
                    p.supplierId == _selectedSupplierId;
                final matchesSearch = q.isEmpty ||
                    p.name.toLowerCase().contains(q) ||
                    (p.productCode?.toLowerCase().contains(q) ?? false);
                return matchesSupplier && matchesSearch;
              }).toList()
                ..sort((a, b) =>
                    a.name.toLowerCase().compareTo(b.name.toLowerCase()));

              if (products.isEmpty) {
                return const Center(child: Text('No products found.'));
              }

              // Group by supplier/principal, groups sorted by supplier name.
              final grouped = <String, List<Product>>{};
              for (final p in products) {
                grouped.putIfAbsent(p.supplierId, () => []).add(p);
              }
              final supplierIds = grouped.keys.toList()
                ..sort((a, b) {
                  final an = suppliersMap[a]?.name ?? 'Unknown Supplier';
                  final bn = suppliersMap[b]?.name ?? 'Unknown Supplier';
                  return an.toLowerCase().compareTo(bn.toLowerCase());
                });

              return ListView.builder(
                controller: _scrollCtrl,
                itemCount: supplierIds.length,
                itemBuilder: (ctx, groupIndex) {
                  final supplierId = supplierIds[groupIndex];
                  final supplierName =
                      suppliersMap[supplierId]?.name ?? 'Unknown Supplier';
                  final groupProducts = grouped[supplierId]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(
                          '$supplierName (${groupProducts.length})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      for (final p in groupProducts) ...[
                        _buildProductTile(ctx, p),
                        const Divider(height: 1),
                      ],
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductTile(BuildContext ctx, Product p) {
    return ListTile(
      leading: const Icon(Icons.inventory_2),
      title: Text(p.productCode != null && p.productCode!.isNotEmpty
          ? '${p.name} (${p.productCode})'
          : p.name),
      subtitle: Text('${p.piecesPerBox} pcs/box'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/products/${p.id}'),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final ok = await showConfirmDialog(
                ctx,
                title: 'Delete Product',
                message: 'Delete "${p.name}"? This cannot be undone.',
              );
              if (ok) {
                await ref.read(productRepositoryProvider).deleteProduct(p.id);
                ref.invalidate(productsListProvider);
              }
            },
          ),
        ],
      ),
    );
  }

  /// Price list of every product with its current withdrawal/selling price
  /// per piece, with export-to-file and print actions.
  Widget _buildPriceListTab() {
    final productsAsync = ref.watch(productsListProvider);
    final withdrawalAsync = ref.watch(productCurrentWithdrawalPricesProvider);
    final sellingAsync = ref.watch(productCurrentSellingPricesProvider);
    final suppliersAsync = ref.watch(suppliersListProvider);
    final suppliers = suppliersAsync.valueOrNull ?? [];
    final suppliersMap = {for (final s in suppliers) s.id: s};

    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (allProducts) {
        final withdrawalPrices = withdrawalAsync.valueOrNull ?? {};
        final sellingPrices = sellingAsync.valueOrNull ?? {};
        final q = _priceListSearch.toLowerCase();
        final filtered = allProducts
            .where((p) => q.isEmpty || p.name.toLowerCase().contains(q))
            .toList()
          ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        // Group by supplier/principal, groups sorted by supplier name.
        final grouped = <String, List<Product>>{};
        for (final p in filtered) {
          grouped.putIfAbsent(p.supplierId, () => []).add(p);
        }
        final supplierIds = grouped.keys.toList()
          ..sort((a, b) {
            final an = suppliersMap[a]?.name ?? 'Unknown Supplier';
            final bn = suppliersMap[b]?.name ?? 'Unknown Supplier';
            return an.toLowerCase().compareTo(bn.toLowerCase());
          });
        // Flattened in the same order as displayed, so exported/printed
        // rows follow the on-screen grouping too.
        final rows = [for (final id in supplierIds) ...grouped[id]!];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _priceListSearchCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Search product…',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) =>
                          setState(() => _priceListSearch = v.trim()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.table_chart, size: 18),
                    label: const Text('Export'),
                    onPressed: rows.isEmpty
                        ? null
                        : () => _exportPriceList(
                            rows, withdrawalPrices, sellingPrices),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.print, size: 18),
                    label: const Text('Print'),
                    onPressed: rows.isEmpty
                        ? null
                        : () => _printPriceList(
                            rows, withdrawalPrices, sellingPrices),
                  ),
                ],
              ),
            ),
            if (rows.isNotEmpty)
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text('Product Name',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('Withdrawal/pc',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('Selling/pc',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right),
                    ),
                  ],
                ),
              ),
            const Divider(height: 1),
            Expanded(
              child: rows.isEmpty
                  ? const Center(child: Text('No products found.'))
                  : ListView.builder(
                      itemCount: supplierIds.length,
                      itemBuilder: (ctx, groupIndex) {
                        final supplierId = supplierIds[groupIndex];
                        final supplierName =
                            suppliersMap[supplierId]?.name ??
                                'Unknown Supplier';
                        final groupProducts = grouped[supplierId]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              child: Text(
                                '$supplierName (${groupProducts.length})',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            for (final p in groupProducts)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color:
                                            Theme.of(context).dividerColor,
                                        width: 0.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(flex: 3, child: Text(p.name)),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                          withdrawalPrices[p.id] != null
                                              ? formatCurrency(
                                                  withdrawalPrices[p.id]!)
                                              : '—',
                                          textAlign: TextAlign.right),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                          sellingPrices[p.id] != null
                                              ? formatCurrency(
                                                  sellingPrices[p.id]!)
                                              : '—',
                                          textAlign: TextAlign.right),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  /// Exports the price list rows to an .xlsx file on the Desktop.
  Future<void> _exportPriceList(
    List<Product> rows,
    Map<String, double> withdrawalPrices,
    Map<String, double> sellingPrices,
  ) async {
    final book = xlsx.Excel.createExcel();
    final sheet = book[book.sheets.keys.first];

    // Product Name stays left-aligned; the two price columns are right-aligned.
    const aligns = [
      xlsx.HorizontalAlign.Left,
      xlsx.HorizontalAlign.Right,
      xlsx.HorizontalAlign.Right,
    ];

    void addRow(int r, List<Object> cells, {bool bold = false}) {
      for (int c = 0; c < cells.length; c++) {
        final cell = sheet.cell(
          xlsx.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r),
        );
        cell.value = cells[c];
        cell.cellStyle = xlsx.CellStyle(
          bold: bold,
          horizontalAlign: c < aligns.length ? aligns[c] : xlsx.HorizontalAlign.Left,
        );
      }
    }

    int r = 0;
    addRow(r++, ['Product Name', 'Withdrawal Price/pc', 'Selling Price/pc'],
        bold: true);
    for (final p in rows) {
      addRow(r++, [
        p.name,
        (withdrawalPrices[p.id] ?? 0).toStringAsFixed(2),
        (sellingPrices[p.id] ?? 0).toStringAsFixed(2),
      ]);
    }

    final bytes = book.save();
    if (bytes == null) return;

    final home = Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '';
    final tag = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
    final file = File('$home\\Desktop\\product_price_list_$tag.xlsx');
    await file.writeAsBytes(bytes);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported to ${file.path}')),
    );
  }

  /// Prints the price list rows via the OS print dialog.
  Future<void> _printPriceList(
    List<Product> rows,
    Map<String, double> withdrawalPrices,
    Map<String, double> sellingPrices,
  ) async {
    await printProductPriceList(
      rows: [
        for (final p in rows)
          ProductPriceListRow(
            productName: p.name,
            withdrawalPricePerPiece: withdrawalPrices[p.id] ?? 0,
            sellingPricePerPiece: sellingPrices[p.id] ?? 0,
          ),
      ],
    );
  }
}
