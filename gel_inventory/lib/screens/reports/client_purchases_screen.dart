import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/product.dart';
import '../../models/supplier.dart';
import '../../repositories/client_repository.dart';
import '../../repositories/invoice_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../utils/currency_format.dart';
import '../../utils/pdf_generator.dart';
import '../../widgets/common/app_scaffold.dart';

/// Sentinel passed as the `supplierId` query parameter when the "All
/// Suppliers" filter is active, so [ClientPurchaseDetailScreen] knows to
/// skip supplier-specific product filtering.
const kAllSuppliersId = 'all';

class _ClientPurchaseRow {
  final String clientId;
  final String clientName;
  final int totalPieces;

  const _ClientPurchaseRow({
    required this.clientId,
    required this.clientName,
    required this.totalPieces,
  });
}

class ClientPurchasesScreen extends ConsumerStatefulWidget {
  const ClientPurchasesScreen({super.key});

  @override
  ConsumerState<ClientPurchasesScreen> createState() =>
      _ClientPurchasesScreenState();
}

class _ClientPurchasesScreenState
    extends ConsumerState<ClientPurchasesScreen> {
  Supplier? _selectedSupplier;
  Product? _selectedProduct;
  DateTimeRange _range = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day),
  );
  bool _loading = false;
  List<_ClientPurchaseRow> _rows = [];

  String get _supplierLabel => _selectedSupplier?.name ?? 'All Suppliers';

  String get _filterLabel => _selectedProduct == null
      ? _supplierLabel
      : '$_supplierLabel • Product: ${_selectedProduct!.name}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  DateTime get _startDate => _range.start;

  // Exclusive upper bound: the picked end date is inclusive of that whole day.
  DateTime get _endDate => _range.end.add(const Duration(days: 1));

  String get _periodLabel {
    final dateFmt = DateFormat('MMM d, y');
    return '${dateFmt.format(_range.start)} - ${dateFmt.format(_range.end)}';
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _range = DateTimeRange(
            start: DateTime(picked.start.year, picked.start.month,
                picked.start.day),
            end:
                DateTime(picked.end.year, picked.end.month, picked.end.day),
          ));
      _load();
    }
  }

  List<ClientPurchaseRow> get _pdfRows => _rows
      .map((r) => ClientPurchaseRow(
            clientName: r.clientName,
            totalPieces: r.totalPieces,
          ))
      .toList();

  Future<void> _print() async {
    await printClientPurchases(
      supplierName: _filterLabel,
      periodLabel: _periodLabel,
      rows: _pdfRows,
    );
  }

  Future<void> _download() async {
    final path = await exportClientPurchasesReport(
      supplierName: _filterLabel,
      periodLabel: _periodLabel,
      rows: _pdfRows,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved to $path')),
    );
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final selectedSupplierId = _selectedSupplier?.id;
    final products = await ref.read(productRepositoryProvider).getAll();
    // null = no supplier filter, i.e. every product counts.
    final supplierProductIds = selectedSupplierId == null
        ? null
        : products
            .where((p) => p.supplierId == selectedSupplierId)
            .map((p) => p.id)
            .toSet();

    final clients = await ref.read(clientRepositoryProvider).getAll();
    final clientsById = {for (final c in clients) c.id: c};

    final invoices = await ref
        .read(invoiceRepositoryProvider)
        .getAll(startDate: _startDate, endDate: _endDate);

    final selectedProductId = _selectedProduct?.id;
    final invoiceRepo = ref.read(invoiceRepositoryProvider);
    final Map<String, int> totalsByClient = {};
    for (final inv in invoices) {
      final items = await invoiceRepo.getItems(inv.id);
      for (final item in items) {
        if (supplierProductIds != null &&
            !supplierProductIds.contains(item.productId)) {
          continue;
        }
        if (selectedProductId != null && item.productId != selectedProductId) {
          continue;
        }
        totalsByClient[inv.clientId] =
            (totalsByClient[inv.clientId] ?? 0) + item.quantity;
      }
    }

    final rows = totalsByClient.entries
        .map((e) => _ClientPurchaseRow(
              clientId: e.key,
              clientName: clientsById[e.key]?.name ?? e.key,
              totalPieces: e.value,
            ))
        .toList()
      ..sort((a, b) => b.totalPieces.compareTo(a.totalPieces));

    if (!mounted) return;
    setState(() {
      _rows = rows;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(suppliersListProvider);
    final productsAsync = ref.watch(productsListProvider);
    final grandTotal =
        _rows.fold<int>(0, (s, r) => s + r.totalPieces);

    final canExport = _rows.isNotEmpty;

    return AppScaffold(
      title: 'Client Purchases',
      actions: [
        IconButton(
          icon: const Icon(Icons.print),
          tooltip: 'Print',
          onPressed: canExport ? _print : null,
        ),
        IconButton(
          icon: const Icon(Icons.file_download),
          tooltip: 'Download as PDF',
          onPressed: canExport ? _download : null,
        ),
      ],
      body: Column(
        children: [
          // Supplier picker
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: suppliersAsync.maybeWhen(
              data: (suppliers) => Row(
                children: [
                  const Text('Supplier:',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String?>(
                      value: _selectedSupplier?.id,
                      isDense: true,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('All Suppliers')),
                        ...suppliers.map((s) => DropdownMenuItem(
                            value: s.id, child: Text(s.name))),
                      ],
                      onChanged: (id) {
                        setState(() {
                          _selectedSupplier =
                              suppliers.where((s) => s.id == id).firstOrNull;
                          // Clear the product filter if it no longer belongs
                          // to the newly selected supplier.
                          if (_selectedSupplier != null &&
                              _selectedProduct?.supplierId !=
                                  _selectedSupplier!.id) {
                            _selectedProduct = null;
                          }
                        });
                        _load();
                      },
                    ),
                  ),
                ],
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ),

          // Product picker
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: productsAsync.maybeWhen(
              data: (products) {
                final visibleProducts = _selectedSupplier == null
                    ? products
                    : products
                        .where((p) => p.supplierId == _selectedSupplier!.id)
                        .toList();
                return Row(
                  children: [
                    const Text('Product:',
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String?>(
                        value: _selectedProduct?.id,
                        isDense: true,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('All Products')),
                          ...visibleProducts.map((p) => DropdownMenuItem(
                              value: p.id, child: Text(p.name))),
                        ],
                        onChanged: (id) {
                          setState(() => _selectedProduct = visibleProducts
                              .where((p) => p.id == id)
                              .firstOrNull);
                          _load();
                        },
                      ),
                    ),
                  ],
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
          ),

          // Date range filter
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: Row(
              children: [
                const Icon(Icons.date_range, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: _pickDateRange,
                    child: Text(
                      _periodLabel,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _pickDateRange,
                  style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact),
                  child: const Text('Change'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _rows.isEmpty
                    ? Center(
                        child: Text(
                            'No purchases of $_filterLabel '
                            'for $_periodLabel.'))
                    : ListView.separated(
                            padding: const EdgeInsets.all(8),
                            itemCount: _rows.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (ctx, i) {
                              final row = _rows[i];
                              final isTop = i < 3;
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isTop
                                      ? Colors.green.shade100
                                      : Colors.grey.shade100,
                                  child: Text('${i + 1}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isTop
                                              ? Colors.green.shade800
                                              : Colors.grey.shade600)),
                                ),
                                title: Text(row.clientName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                trailing: Text(
                                  '${formatNumber(row.totalPieces)} pcs',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isTop
                                        ? Colors.green.shade700
                                        : null,
                                  ),
                                ),
                                onTap: () {
                                  final uri = Uri(
                                    path: '/client-purchases/${row.clientId}',
                                    queryParameters: {
                                      'supplierId': _selectedSupplier?.id ??
                                          kAllSuppliersId,
                                      if (_selectedProduct != null)
                                        'productId': _selectedProduct!.id,
                                      'from': _startDate.toIso8601String(),
                                      'to': _endDate.toIso8601String(),
                                    },
                                  );
                                  context.push(uri.toString());
                                },
                              );
                            },
                          ),
          ),

          // Footer
          if (!_loading && _rows.isNotEmpty)
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_rows.length} client(s)',
                      style: const TextStyle(color: Colors.grey)),
                  Text(
                    'Total: ${formatNumber(grandTotal)} pcs',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
