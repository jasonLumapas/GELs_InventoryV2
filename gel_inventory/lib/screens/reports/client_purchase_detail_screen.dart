import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/client.dart';
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
  final DateTime fromDate;
  final DateTime toDate;

  const ClientPurchaseDetailScreen({
    super.key,
    required this.clientId,
    required this.supplierId,
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
  Supplier? _supplier;
  List<_ProductPurchaseRow> _rows = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/client-purchases');
    }
  }

  bool get _isAllSuppliers => widget.supplierId == kAllSuppliersId;

  String get _supplierLabel =>
      _isAllSuppliers ? 'All Suppliers' : (_supplier?.name ?? widget.supplierId);

  String get _periodLabel {
    final dateFmt = DateFormat('MMM d, y');
    return '${dateFmt.format(widget.fromDate)} - '
        '${dateFmt.format(widget.toDate.subtract(const Duration(days: 1)))}';
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
      supplierName: _supplierLabel,
      periodLabel: _periodLabel,
      rows: _pdfRows,
    );
  }

  Future<void> _download() async {
    final path = await exportClientPurchaseDetailReport(
      clientName: _client?.name ?? widget.clientId,
      supplierName: _supplierLabel,
      periodLabel: _periodLabel,
      rows: _pdfRows,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved to $path')),
    );
  }

  Future<void> _load() async {
    final clients = await ref.read(clientRepositoryProvider).getAll();
    final client = clients.where((c) => c.id == widget.clientId).firstOrNull;
    Supplier? supplier;
    if (!_isAllSuppliers) {
      final suppliers = await ref.read(supplierRepositoryProvider).getAll();
      supplier = suppliers.where((s) => s.id == widget.supplierId).firstOrNull;
    }

    final products = await ref.read(productRepositoryProvider).getAll();
    final productsById = {for (final p in products) p.id: p};
    // null = no supplier filter, i.e. every product counts.
    final supplierProductIds = _isAllSuppliers
        ? null
        : products
            .where((p) => p.supplierId == widget.supplierId)
            .map((p) => p.id)
            .toSet();

    final invoiceRepo = ref.read(invoiceRepositoryProvider);
    final invoices = await invoiceRepo.getAll(
      startDate: widget.fromDate,
      endDate: widget.toDate,
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
      _supplier = supplier;
      _rows = rows;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Supplier: $_supplierLabel',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _periodLabel,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _rows.isEmpty
                      ? const Center(
                          child: Text('No purchases in this period.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: _rows.length,
                          separatorBuilder: (_, _) =>
                              const Divider(height: 1),
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
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            );
                          },
                        ),
                ),
                if (_rows.isNotEmpty)
                  Container(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
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
