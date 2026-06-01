import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../repositories/client_repository.dart';
import '../../repositories/invoice_repository.dart';
import '../../utils/currency_format.dart';
import '../../widgets/common/app_scaffold.dart';

class InvoiceListScreen extends ConsumerWidget {
  const InvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesListProvider);
    final clientsAsync = ref.watch(clientsListProvider);
    final dateFmt = DateFormat('MMM dd, yyyy');

    return AppScaffold(
      title: 'Invoices',
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
        onPressed: () => context.go('/invoices/new'),
      ),
      body: invoicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (invoices) {
          final clientsMap = {
            for (final c in clientsAsync.valueOrNull ?? []) c.id: c
          };
          if (invoices.isEmpty) {
            return const Center(child: Text('No invoices yet.'));
          }
          return ListView.separated(
            itemCount: invoices.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final inv = invoices[i];
              final client = clientsMap[inv.clientId];
              return ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text(client?.name ?? inv.clientId),
                subtitle: Text(
                    '${dateFmt.format(inv.invoiceDate)} • ${inv.status.toUpperCase()}'),
                trailing: Text(formatCurrency(inv.totalAmount),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () => context.go('/invoices/${inv.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
