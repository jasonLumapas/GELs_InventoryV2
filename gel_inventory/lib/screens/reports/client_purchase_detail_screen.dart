import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/client.dart';
import '../../models/product.dart';
import '../../models/supplier.dart';
import '../../repositories/client_repository.dart';
import '../../repositories/invoice_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../utils/currency_format.dart';
import '../../utils/pdf_generator.dart';
import '../../widgets/common/app_scaffold.dart';
import 'client_purchases_screen.dart' show kAllSuppliersId;

class _ProductPurchaseRow {
  final String productName;
  final int piecesPerBox;
  final int totalPieces;

  const _ProductPurchaseRow({
    required this.productName,
    required this.piecesPerBox,
    required this.totalPieces,
  });

  int get boxes => piecesPerBox > 0 ? totalPieces ~/ piecesPerBox : 0;
  int get remainPieces => piecesPerBox > 0 ? totalPieces % piecesPerBox : totalPieces;
}

class ClientPurchaseDetailScreen extends ConsumerStatefulWidget {
  final String clientId;
  final String supplierId;
  final String? productId;
  final DateTime fromDate;
  final DateTime toDate;

  const ClientPurchaseDetailScreen({
    super.key,
    required this.clientId,
    required this.supplierId,
    this.productId,
    required this.fromDate,
    required this.toDate,
  });

  @override
  ConsumerState<ClientPurchaseDetailScreen> createState() =>
      _ClientPurchaseDetailScreenState();
}

class _ClientPurchaseDetailScreenState
    extends ConsumerState<ClientPurchaseDetailScreen> {
  bool _loading = true;
  Client? _client;
  String? _selectedSupplierId;
  String? _selectedProductId;
  Supplier? _selectedSupplier;
  Product? _selectedProduct;
  late DateTimeRange _range;
  List<_ProductPurchaseRow> _rows = [];

  @override
  void initState() {
    super.initState();
    _selectedSupplierId =
        widget.supplierId == kAllSuppliersId ? null : widget.supplierId;
    _selectedProductId = widget.productId;
    _range = DateTimeRange(
      start: DateTime(
          widget.fromDate.year, widget.fromDate.month, widget.fromDate.day),
      end: DateTime(widget.toDate.year, widget.toDate.month, widget.toDate.day)
          .subtract(const Duration(days: 1)),
    );
    _load();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/client-purchases');
    }
  }

  String get _supplierLabel => _selectedSupplier?.name ?? 'All Suppliers';

  String get _filterLabel => _selectedProduct == null
      ? _supplierLabel
      : '$_supplierLabel • Product: ${_selectedProduct!.name}';

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
            start: DateTime(
                picked.start.year, picked.start.month, picked.start.day),
            end:
                DateTime(picked.end.year, picked.end.month, picked.end.day),
          ));
      _load();
    }
  }

  List<ClientPurchaseProductRow> get _pdfRows => _rows
      .map((r) => ClientPurchaseProductRow(
            productName: r.productName,
            piecesPerBox: r.piecesPerBox,
            totalPieces: r.totalPieces,
          ))
      .toList();

  Future<void> _print() async {
    await printClientPurchaseDetail(
      clientName: _client?.name ?? widget.clientId,
      supplierName: _filterLabel,
      periodLabel: _periodLabel,
      rows: _pdfRows,
    );
  }

  Future<void> _download() async {
    final path = await exportClientPurchaseDetailReport(
      clientName: _client?.name ?? widget.clientId,
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

    final clients = await ref.read(clientRepositoryProvider).getAll();
    final client = clients.where((c) => c.id == widget.clientId).firstOrNull;

    final selectedSupplier = _selectedSupplierId == null
        ? null
        : (await ref.read(supplierRepositoryProvider).getAll())
            .where((s) => s.id == _selectedSupplierId)
            .firstOrNull;

    final products = await ref.read(productRepositoryProvider).getAll();
    final productsById = {for (final p in products) p.id: p};
    final selectedProduct =
        _selectedProductId == null ? null : productsById[_selectedProductId];
    // null = no supplier filter, i.e. every product counts.
    final supplierProductIds = _selectedSupplierId == null
        ? null
        : products
            .where((p) => p.supplierId == _selectedSupplierId)
            .map((p) => p.id)
            .toSet();

    final invoiceRepo = ref.read(invoiceRepositoryProvider);
    final invoices = await invoiceRepo.getAll(
      startDate: _startDate,
      endDate: _endDate,
    );
    final clientInvoices =
        invoices.where((inv) => inv.clientId == widget.clientId);

    final Map<String, int> totalsByProduct = {};
    for (final inv in clientInvoices) {
      final items = await invoiceRepo.getItems(inv.id);
      for (final item in items) {
        if (supplierProductIds != null &&
            !supplierProductIds.contains(item.productId)) {
          continue;
        }
        if (_selectedProductId != null &&
            item.productId != _selectedProductId) {
          continue;
        }
        totalsByProduct[item.productId] =
            (totalsByProduct[item.productId] ?? 0) + item.quantity;
      }
    }

    final rows = totalsByProduct.entries
        .map((e) {
          final product = productsById[e.key];
          return _ProductPurchaseRow(
            productName: product?.name ?? e.key,
            piecesPerBox: product?.piecesPerBox ?? 1,
            totalPieces: e.value,
          );
        })
        .toList()
      ..sort((a, b) => b.totalPieces.compareTo(a.totalPieces));

    if (!mounted) return;
    setState(() {
      _client = client;
      _selectedSupplier = selectedSupplier;
      _selectedProduct = selectedProduct;
      _rows = rows;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(suppliersListProvider);
    final productsAsync = ref.watch(productsListProvider);
    final grandTotal = _rows.fold<int>(0, (s, r) => s + r.totalPieces);
    final canExport = !_loading && _rows.isNotEmpty;

    return AppScaffold(
      title: _client?.name ?? 'Client Purchases',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Back',
        onPressed: _goBack,
      ),
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
                      value: _selectedSupplierId,
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
                          _selectedSupplierId = id;
                          // Clear the product filter if it no longer belongs
                          // to the newly selected supplier.
                          final products = productsAsync.asData?.value;
                          if (id != null &&
                              products != null &&
                              _selectedProductId != null) {
                            final prod = products
                                .where((p) => p.id == _selectedProductId)
                                .firstOrNull;
                            if (prod == null || prod.supplierId != id) {
                              _selectedProductId = null;
                            }
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
                final visibleProducts = _selectedSupplierId == null
                    ? products
                    : products
                        .where((p) => p.supplierId == _selectedSupplierId)
                        .toList();
                return Row(
                  children: [
                    const Text('Product:',
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String?>(
                        value: _selectedProductId,
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
                          setState(() => _selectedProductId = id);
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

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _rows.isEmpty
                    ? const Center(
                        child: Text('No purchases in this period.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: _rows.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final row = _rows[i];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey.shade100,
                              child: Text('${i + 1}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade600)),
                            ),
                            title: Text(row.productName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            trailing: Text(
                              [
                                if (row.boxes > 0) '${row.boxes} box(es)',
                                if (row.remainPieces > 0)
                                  '${row.remainPieces} pcs',
                              ].join(' + '),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          );
                        },
                      ),
          ),
          if (!_loading && _rows.isNotEmpty)
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_rows.length} product(s)',
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
