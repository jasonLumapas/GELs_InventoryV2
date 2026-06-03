import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/invoice.dart';
import '../../repositories/client_repository.dart';
import '../../repositories/invoice_payment_repository.dart';
import '../../repositories/invoice_repository.dart';
import '../../utils/currency_format.dart';
import '../../widgets/common/app_scaffold.dart';

class _CollectibleItem {
  final Invoice invoice;
  final String clientName;
  final double outstanding;

  const _CollectibleItem({
    required this.invoice,
    required this.clientName,
    required this.outstanding,
  });
}

class CollectiblesScreen extends ConsumerStatefulWidget {
  const CollectiblesScreen({super.key});

  @override
  ConsumerState<CollectiblesScreen> createState() =>
      _CollectiblesScreenState();
}

class _CollectiblesScreenState extends ConsumerState<CollectiblesScreen> {
  bool _loading = true;
  List<_CollectibleItem> _items = [];
  String? _filterType; // null = all

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final invoices = await ref.read(invoiceRepositoryProvider).getAll();
    final clients  = await ref.read(clientRepositoryProvider).getAll();
    final clientMap = {for (final c in clients) c.id: c};

    // Only non-cancelled, non-cash invoices
    final nonCash = invoices.where(
        (i) => i.status != 'cancelled' && i.paymentType != 'cash').toList();

    // Compute outstanding for each
    final List<_CollectibleItem> items = [];
    for (final inv in nonCash) {
      double outstanding;
      if (inv.paymentType == 'partial') {
        final payments = await ref
            .read(invoicePaymentRepositoryProvider)
            .getForInvoice(inv.id);
        final paid = payments.fold(0.0, (s, p) => s + p.amount);
        outstanding = inv.totalAmount - paid;
      } else {
        // check / credit: check_amount as paid, otherwise full amount
        final paid = inv.checkAmount ?? 0.0;
        outstanding = inv.totalAmount - paid;
      }

      if (outstanding > 0.01) {
        items.add(_CollectibleItem(
          invoice: inv,
          clientName:
              clientMap[inv.clientId]?.name ?? inv.clientId,
          outstanding: outstanding,
        ));
      }
    }

    // Sort: most recent first
    items.sort((a, b) =>
        b.invoice.invoiceDate.compareTo(a.invoice.invoiceDate));

    setState(() {
      _items   = items;
      _loading = false;
    });
  }

  List<_CollectibleItem> get _filtered => _filterType == null
      ? _items
      : _items.where((i) => i.invoice.paymentType == _filterType).toList();

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM dd, yyyy');
    final filtered  = _filtered;
    final totalOutstanding = filtered.fold(0.0, (s, i) => s + i.outstanding);

    return AppScaffold(
      title: 'Collectibles',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _load,
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 4),
      ],
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                const Text('Filter:',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(width: 8),
                _chip('All',     null),
                const SizedBox(width: 6),
                _chip('Check',   'check'),
                const SizedBox(width: 6),
                _chip('Credit',  'credit'),
                const SizedBox(width: 6),
                _chip('Partial', 'partial'),
              ],
            ),
          ),
          const Divider(height: 1),

          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(
                        child: Text('No outstanding collectibles.'))
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final item = filtered[i];
                          final inv  = item.invoice;
                          return ListTile(
                            leading: _paymentIcon(inv.paymentType),
                            title: Row(
                              children: [
                                Expanded(
                                    child: Text(item.clientName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600))),
                                Text(
                                  formatCurrency(item.outstanding),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              '${inv.displayNumber}  •  '
                              '${dateFmt.format(inv.invoiceDate)}  •  '
                              '${inv.paymentLabel}',
                            ),
                            onTap: () => context.go('/invoices/${inv.id}'),
                          );
                        },
                      ),
          ),

          // Footer
          if (!_loading && filtered.isNotEmpty)
            Container(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${filtered.length} invoice(s)',
                      style: const TextStyle(color: Colors.grey)),
                  Text(
                    'Total Outstanding: ${formatCurrency(totalOutstanding)}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.red.shade700),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _chip(String label, String? type) => ChoiceChip(
        label: Text(label),
        selected: _filterType == type,
        onSelected: (_) => setState(() => _filterType = type),
        visualDensity: VisualDensity.compact,
      );

  Widget _paymentIcon(String type) {
    switch (type) {
      case 'check':
        return const CircleAvatar(
            backgroundColor: Color(0xFFE3F2FD),
            child: Icon(Icons.check_box_outlined,
                color: Colors.blue, size: 20));
      case 'credit':
        return const CircleAvatar(
            backgroundColor: Color(0xFFF3E5F5),
            child:
                Icon(Icons.credit_card, color: Colors.purple, size: 20));
      default: // partial
        return const CircleAvatar(
            backgroundColor: Color(0xFFFFF3E0),
            child: Icon(Icons.pending, color: Colors.orange, size: 20));
    }
  }
}
