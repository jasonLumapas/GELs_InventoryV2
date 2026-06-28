import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/supplier.dart';
import '../../repositories/client_repository.dart';
import '../../repositories/invoice_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../utils/currency_format.dart';
import '../../utils/pdf_generator.dart';
import '../../widgets/common/app_scaffold.dart';

enum _DateFilter { day, week, month, year }

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
  _DateFilter _dateFilter = _DateFilter.month;
  DateTime _anchor = DateTime.now();
  bool _loading = false;
  List<_ClientPurchaseRow> _rows = [];

  String get _supplierLabel => _selectedSupplier?.name ?? 'All Suppliers';

  @override
  void initState() {
    super.initState();
    _load();
  }

  DateTime get _startDate {
    switch (_dateFilter) {
      case _DateFilter.day:
        return DateTime(_anchor.year, _anchor.month, _anchor.day);
      case _DateFilter.week:
        final mon = _anchor.subtract(Duration(days: _anchor.weekday - 1));
        return DateTime(mon.year, mon.month, mon.day);
      case _DateFilter.month:
        return DateTime(_anchor.year, _anchor.month);
      case _DateFilter.year:
        return DateTime(_anchor.year);
    }
  }

  DateTime get _endDate {
    switch (_dateFilter) {
      case _DateFilter.day:  return _startDate.add(const Duration(days: 1));
      case _DateFilter.week: return _startDate.add(const Duration(days: 7));
      case _DateFilter.month:
        return DateTime(_anchor.year, _anchor.month + 1);
      case _DateFilter.year:
        return DateTime(_anchor.year + 1);
    }
  }

  String get _periodLabel {
    switch (_dateFilter) {
      case _DateFilter.day:
        return DateFormat('EEE, MMM d, y').format(_startDate);
      case _DateFilter.week:
        final e = _endDate.subtract(const Duration(days: 1));
        final sameMonth =
            _startDate.month == e.month && _startDate.year == e.year;
        return sameMonth
            ? '${DateFormat('MMM d').format(_startDate)} - ${DateFormat('d, y').format(e)}'
            : '${DateFormat('MMM d').format(_startDate)} - ${DateFormat('MMM d, y').format(e)}';
      case _DateFilter.month:
        return DateFormat('MMMM y').format(_startDate);
      case _DateFilter.year:
        return _anchor.year.toString();
    }
  }

  void _prev() => setState(() {
        switch (_dateFilter) {
          case _DateFilter.day:
            _anchor = _anchor.subtract(const Duration(days: 1));
          case _DateFilter.week:
            _anchor = _anchor.subtract(const Duration(days: 7));
          case _DateFilter.month:
            _anchor = DateTime(_anchor.year, _anchor.month - 1, _anchor.day);
          case _DateFilter.year:
            _anchor = DateTime(_anchor.year - 1, _anchor.month, _anchor.day);
        }
        _load();
      });

  void _next() => setState(() {
        switch (_dateFilter) {
          case _DateFilter.day:
            _anchor = _anchor.add(const Duration(days: 1));
          case _DateFilter.week:
            _anchor = _anchor.add(const Duration(days: 7));
          case _DateFilter.month:
            _anchor = DateTime(_anchor.year, _anchor.month + 1, _anchor.day);
          case _DateFilter.year:
            _anchor = DateTime(_anchor.year + 1, _anchor.month, _anchor.day);
        }
        _load();
      });

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _anchor,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _anchor = picked);
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
      supplierName: _supplierLabel,
      periodLabel: _periodLabel,
      rows: _pdfRows,
    );
  }

  Future<void> _download() async {
    final path = await exportClientPurchasesReport(
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

    final invoiceRepo = ref.read(invoiceRepositoryProvider);
    final Map<String, int> totalsByClient = {};
    for (final inv in invoices) {
      final items = await invoiceRepo.getItems(inv.id);
      for (final item in items) {
        if (supplierProductIds != null &&
            !supplierProductIds.contains(item.productId)) {
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
                        setState(() => _selectedSupplier =
                            suppliers.where((s) => s.id == id).firstOrNull);
                        _load();
                      },
                    ),
                  ),
                ],
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ),

          // Date filter bar
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: Row(
              children: [
                SegmentedButton<_DateFilter>(
                  segments: const [
                    ButtonSegment(value: _DateFilter.day,   label: Text('Day')),
                    ButtonSegment(value: _DateFilter.week,  label: Text('Week')),
                    ButtonSegment(value: _DateFilter.month, label: Text('Month')),
                    ButtonSegment(value: _DateFilter.year,  label: Text('Year')),
                  ],
                  selected: {_dateFilter},
                  onSelectionChanged: (s) {
                    setState(() => _dateFilter = s.first);
                    _load();
                  },
                  style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _prev,
                  visualDensity: VisualDensity.compact,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Text(
                      _periodLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _next,
                  visualDensity: VisualDensity.compact,
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _anchor = DateTime.now());
                    _load();
                  },
                  style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact),
                  child: const Text('Today'),
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
                            'No purchases of $_supplierLabel\'s '
                            'products for $_periodLabel.'))
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
