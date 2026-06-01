import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/client.dart';
import '../../models/invoice.dart';
import '../../models/invoice_item.dart';
import '../../models/product.dart';
import '../../repositories/client_repository.dart';
import '../../repositories/invoice_repository.dart';
import '../../repositories/product_repository.dart';
import '../../utils/currency_format.dart';
import '../../utils/pdf_generator.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/confirm_dialog.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final String invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailScreen> createState() =>
      _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  Invoice? _invoice;
  List<InvoiceItem> _items = [];
  Client? _client;
  Map<String, Product> _productsById = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final invoices =
        await ref.read(invoiceRepositoryProvider).getAll();
    _invoice =
        invoices.where((i) => i.id == widget.invoiceId).firstOrNull;
    if (_invoice == null) {
      if (mounted) context.go('/invoices');
      return;
    }
    _items = await ref
        .read(invoiceRepositoryProvider)
        .getItems(widget.invoiceId);
    final clients = await ref.read(clientRepositoryProvider).getAll();
    _client =
        clients.where((c) => c.id == _invoice!.clientId).firstOrNull;
    final products = await ref.read(productRepositoryProvider).getAll();
    _productsById = {for (final p in products) p.id: p};
    setState(() => _loading = false);
  }

  Future<void> _reprint() async {
    if (_invoice == null || _client == null) return;
    await printInvoice(
      invoice: _invoice!,
      client: _client!,
      items: _items,
      productsById: _productsById,
    );
  }

  Future<void> _cancel() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Cancel Invoice',
      message: 'Mark this invoice as cancelled?',
      confirmLabel: 'Cancel Invoice',
    );
    if (ok) {
      await ref
          .read(invoiceRepositoryProvider)
          .cancelInvoice(widget.invoiceId);
      if (mounted) context.go('/invoices');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM dd, yyyy HH:mm');

    return AppScaffold(
      title: 'Invoice Detail',
      actions: [
        if (_invoice?.status != 'cancelled') ...[
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Reprint',
            onPressed: _loading ? null : _reprint,
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            tooltip: 'Cancel Invoice',
            onPressed: _loading ? null : _cancel,
          ),
        ],
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Invoice #${_invoice!.id.substring(0, 8).toUpperCase()}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Client: ${_client?.name ?? _invoice!.clientId}'),
                          if (_client?.address != null)
                            Text('Address: ${_client!.address}'),
                          Text(
                              'Date: ${dateFmt.format(_invoice!.invoiceDate)}'),
                          Text(
                              'Status: ${_invoice!.status.toUpperCase()}',
                              style: TextStyle(
                                  color: _invoice!.status == 'cancelled'
                                      ? Colors.red
                                      : Colors.green)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Items table
                  const Text('Items',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Table(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columnWidths: const {
                      0: FlexColumnWidth(4),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(1.5),
                      3: FlexColumnWidth(2),
                    },
                    children: [
                      _headerRow(
                          ['Product', 'Unit', 'Qty', 'Subtotal']),
                      ..._items.map((item) {
                        final product = _productsById[item.productId];
                        return _dataRow([
                          product?.name ?? item.productId,
                          item.unitType,
                          '${item.quantity}',
                          formatCurrency(item.subtotal),
                        ]);
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Total
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total: ${formatCurrency(_invoice!.totalAmount)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
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
