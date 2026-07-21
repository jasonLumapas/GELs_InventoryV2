import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/invoice.dart';
import '../../core/services/app_settings_service.dart';
import '../../repositories/client_repository.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/invoice_repository.dart';
import '../../utils/currency_format.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/confirm_dialog.dart';

class CancelledInvoicesListScreen extends ConsumerStatefulWidget {
  const CancelledInvoicesListScreen({super.key});

  @override
  ConsumerState<CancelledInvoicesListScreen> createState() =>
      _CancelledInvoicesListScreenState();
}

class _CancelledInvoicesListScreenState
    extends ConsumerState<CancelledInvoicesListScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  void _clearDateFilter() =>
      setState(() {
        _startDate = null;
        _endDate = null;
      });

  Future<void> _restore(Invoice inv) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Restore Invoice',
      message: 'Restore invoice ${inv.displayNumber}? It will be marked as '
          'printed again and its ordered stock will be re-deducted from '
          'inventory.',
      confirmLabel: 'Restore',
    );
    if (ok) {
      await ref.read(invoiceRepositoryProvider).restoreInvoice(inv);
      ref.invalidate(cancelledInvoicesProvider);
      ref.invalidate(invoicesListProvider);
      ref.invalidate(filteredInvoicesProvider);
      ref.invalidate(inventoryListProvider);
    }
  }

  Future<void> _deletePermanently(Invoice inv) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete Permanently',
      message:
          'Permanently delete invoice ${inv.displayNumber}? This cannot be undone.',
      confirmLabel: 'Delete Permanently',
    );
    if (ok) {
      await ref.read(invoiceRepositoryProvider).deleteInvoice(inv);
      ref.invalidate(cancelledInvoicesProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cancelledAsync = ref.watch(cancelledInvoicesProvider);
    final clientsAsync = ref.watch(clientsListProvider);
    final allowDeleteCancelled =
        ref.watch(allowDeleteCancelledInvoicesProvider).valueOrNull ?? true;
    final dateFmt = DateFormat('MMM dd, yyyy');

    return AppScaffold(
      title: 'Cancelled Invoices',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Back',
        onPressed: () =>
            context.canPop() ? context.pop() : context.go('/invoices'),
      ),
      body: cancelledAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (cancelled) {
          final clientsMap = {
            for (final c in clientsAsync.valueOrNull ?? []) c.id: c
          };
          final dateFiltered = cancelled.where((inv) {
            if (_startDate != null) {
              final start =
                  DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
              if (inv.invoiceDate.isBefore(start)) return false;
            }
            if (_endDate != null) {
              final end = DateTime(_endDate!.year, _endDate!.month,
                      _endDate!.day)
                  .add(const Duration(days: 1));
              if (!inv.invoiceDate.isBefore(end)) return false;
            }
            return true;
          }).toList();
          final filtered = _searchQuery.isEmpty
              ? dateFiltered
              : dateFiltered.where((inv) {
                  final client = clientsMap[inv.clientId];
                  final q = _searchQuery.toLowerCase();
                  return inv.displayNumber.toLowerCase().contains(q) ||
                      (client?.name.toLowerCase().contains(q) ?? false);
                }).toList();

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search by invoice # or client…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v.trim()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickStartDate,
                        borderRadius: BorderRadius.circular(4),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'From',
                            border: OutlineInputBorder(),
                            isDense: true,
                            suffixIcon: Icon(Icons.calendar_today, size: 16),
                          ),
                          child: Text(
                            _startDate == null
                                ? 'Any'
                                : dateFmt.format(_startDate!),
                            style: TextStyle(
                              color: _startDate == null
                                  ? Theme.of(context).hintColor
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: _pickEndDate,
                        borderRadius: BorderRadius.circular(4),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'To',
                            border: OutlineInputBorder(),
                            isDense: true,
                            suffixIcon: Icon(Icons.calendar_today, size: 16),
                          ),
                          child: Text(
                            _endDate == null ? 'Any' : dateFmt.format(_endDate!),
                            style: TextStyle(
                              color: _endDate == null
                                  ? Theme.of(context).hintColor
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_startDate != null || _endDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Clear date filter',
                        onPressed: _clearDateFilter,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(cancelled.isEmpty
                            ? 'No cancelled invoices.'
                            : _searchQuery.isNotEmpty
                                ? 'No results for "$_searchQuery".'
                                : 'No cancelled invoices in this date range.'),
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final inv = filtered[i];
                          final client = clientsMap[inv.clientId];
                          return ListTile(
                            leading: const Icon(Icons.receipt_long,
                                color: Colors.grey),
                            title: Text(inv.displayNumber),
                            subtitle: Text(
                              '${client?.name ?? inv.clientId}'
                              '  •  ${dateFmt.format(inv.invoiceDate)}',
                            ),
                            onTap: () async {
                              await context.push('/invoices/${inv.id}');
                              ref.invalidate(cancelledInvoicesProvider);
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  formatCurrency(inv.totalAmount),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.restore),
                                  tooltip: 'Restore',
                                  onPressed: () => _restore(inv),
                                ),
                                if (allowDeleteCancelled)
                                  IconButton(
                                    icon: const Icon(Icons.delete_forever,
                                        color: Colors.red),
                                    tooltip: 'Delete Permanently',
                                    onPressed: () => _deletePermanently(inv),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  '${filtered.length} cancelled invoice(s)',
                  style:
                      const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
