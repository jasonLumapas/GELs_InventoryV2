import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/product.dart';
import '../../repositories/client_repository.dart';
import '../../repositories/invoice_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../utils/currency_format.dart';
import '../../utils/pdf_generator.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/confirm_dialog.dart';

class PreOrderListScreen extends ConsumerStatefulWidget {
  const PreOrderListScreen({super.key});

  @override
  ConsumerState<PreOrderListScreen> createState() =>
      _PreOrderListScreenState();
}

class _PreOrderListScreenState
    extends ConsumerState<PreOrderListScreen> {
  bool _exporting = false;

  Future<void> _delete(String id) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete Pre-Order',
      message:
          'Delete this pre-order draft? This cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (!ok) return;
    await ref
        .read(invoiceRepositoryProvider)
        .discardDraft(id);
    ref.invalidate(preOrderDraftsProvider);
  }

  Future<List<OrderSummaryRow>> _buildLayoutRows() async {
    final drafts =
        await ref.read(invoiceRepositoryProvider).getPreOrderDrafts();
    final products =
        await ref.read(productRepositoryProvider).getAll();
    final suppliers =
        await ref.read(supplierRepositoryProvider).getAll();
    final productsById = <String, Product>{
      for (final p in products) p.id: p
    };
    final suppliersById = <String, String>{
      for (final s in suppliers) s.id: s.name
    };

    final Map<String, _ProductTally> tally = {};
    for (final draft in drafts) {
      final items =
          await ref.read(invoiceRepositoryProvider).getItems(draft.id);
      for (final item in items) {
        final product = productsById[item.productId];
        if (product == null) continue;
        tally.update(
          item.productId,
          (t) {
            t.pieces += item.quantity;
            t.amount += item.subtotal;
            return t;
          },
          ifAbsent: () => _ProductTally(
            productName: product.name,
            supplierName:
                suppliersById[product.supplierId] ?? 'Unknown',
            piecesPerBox: product.piecesPerBox,
            pieces: item.quantity,
            amount: item.subtotal,
          ),
        );
      }
    }

    return (tally.values.toList()
          ..sort((a, b) {
            final s = a.supplierName.compareTo(b.supplierName);
            return s != 0 ? s : a.productName.compareTo(b.productName);
          }))
        .map((t) => OrderSummaryRow(
              productName: t.productName,
              totalPieces: t.pieces,
              piecesPerBox: t.piecesPerBox,
              totalAmount: t.amount,
            ))
        .toList();
  }

  Future<void> _print() async {
    final rows = await _buildLayoutRows();
    if (rows.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items to print.')),
      );
      return;
    }
    await printPreOrderLayout(rows: rows);
  }

  Future<void> _download() async {
    setState(() => _exporting = true);
    try {
      final rows = await _buildLayoutRows();
      if (rows.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No items to export.')),
        );
        return;
      }
      final path = await exportPreOrderLayout(rows: rows);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to $path')),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draftsAsync = ref.watch(preOrderDraftsProvider);
    final clientsAsync = ref.watch(clientsListProvider);
    final dateFmt = DateFormat('MMM dd, yyyy');

    return AppScaffold(
      title: 'Pre-Order Drafts',
      actions: [
        IconButton(
          icon: const Icon(Icons.print),
          tooltip: 'Print layout',
          onPressed: _print,
        ),
        _exporting
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : IconButton(
                icon: const Icon(Icons.file_download),
                tooltip: 'Download layout as PDF',
                onPressed: _download,
              ),
        FilledButton.icon(
          icon: const Icon(Icons.add, size: 18),
          label: const Text('New'),
          onPressed: () => context.push('/pre-orders/new'),
          style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact),
        ),
        const SizedBox(width: 8),
      ],
      body: draftsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (drafts) {
          if (drafts.isEmpty) {
            return const Center(
              child: Text('No pre-order drafts yet.\nTap "New" to create one.',
                  textAlign: TextAlign.center),
            );
          }
          final clientsById = {
            for (final c in clientsAsync.valueOrNull ?? []) c.id: c
          };
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: drafts.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final d = drafts[i];
                    final client = clientsById[d.clientId];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE8F5E9),
                        child: Icon(Icons.receipt_long,
                            color: Colors.green, size: 20),
                      ),
                      title: Text(
                        client?.name ?? d.clientId,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${dateFmt.format(d.invoiceDate)}'
                        '  •  ${formatCurrency(d.totalAmount)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red, size: 20),
                        tooltip: 'Delete',
                        onPressed: () => _delete(d.id),
                      ),
                      onTap: () =>
                          context.push('/pre-orders/${d.id}'),
                    );
                  },
                ),
              ),
              // Footer: count + grand total
              Container(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${drafts.length} draft(s)',
                        style: const TextStyle(color: Colors.grey)),
                    Text(
                      'Total: ${formatCurrency(
                          drafts.fold(0.0, (s, d) => s + d.totalAmount))}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductTally {
  final String productName;
  final String supplierName;
  final int piecesPerBox;
  int pieces;
  double amount;

  _ProductTally({
    required this.productName,
    required this.supplierName,
    required this.piecesPerBox,
    required this.pieces,
    required this.amount,
  });
}
