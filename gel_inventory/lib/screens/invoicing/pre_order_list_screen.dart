import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/invoice.dart';
import '../../models/invoice_item.dart';
import '../../models/product.dart';
import '../../repositories/client_repository.dart';
import '../../repositories/inventory_repository.dart';
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

enum _DraftSortOrder { newestFirst, oldestFirst, clientAZ }

class _PreOrderListScreenState
    extends ConsumerState<PreOrderListScreen> {
  bool _exporting = false;
  bool _importingConfirmed = false;
  String _productSearch = '';
  final TextEditingController _searchCtrl = TextEditingController();
  // draft id → set of lower-cased product names
  Map<String, Set<String>> _draftProductNames = {};
  // draft id → whether the draft can be fulfilled given available inventory
  // (null = not yet computed)
  Map<String, bool> _draftValidity = {};
  bool _loadingProductNames = false;
  _DraftSortOrder _sortOrder = _DraftSortOrder.oldestFirst;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProductNames(List<Invoice> drafts) async {
    if (_loadingProductNames) return;
    setState(() => _loadingProductNames = true);
    try {
      final invoiceRepo = ref.read(invoiceRepositoryProvider);
      final inventoryRepo = ref.read(inventoryRepositoryProvider);
      final products = await ref.read(productRepositoryProvider).getAll();
      final productsById = {for (final p in products) p.id: p.name};

      // Load all items in one pass so we can reuse them for validity.
      final allItems = <String, List<InvoiceItem>>{};
      for (final draft in drafts) {
        allItems[draft.id] = await invoiceRepo.getItems(draft.id);
      }

      // Build search-filter map.
      final nameMap = <String, Set<String>>{};
      final productIdSet = <String>{};
      for (final draft in drafts) {
        final items = allItems[draft.id]!;
        nameMap[draft.id] = {
          for (final item in items)
            if (productsById.containsKey(item.productId))
              productsById[item.productId]!.toLowerCase()
        };
        for (final item in items) {
          productIdSet.add(item.productId);
        }
      }

      // Fetch current inventory for every product referenced in any draft.
      final remaining = <String, int>{};
      for (final productId in productIdSet) {
        final inv = await inventoryRepo.getByProductId(productId);
        remaining[productId] = inv?.quantityPieces ?? 0;
      }

      // Compute validity: process drafts oldest-first (highest priority).
      // A draft is valid iff every item can be satisfied by the remaining stock
      // after all earlier-priority valid drafts have consumed their share.
      final sortedDrafts = [...drafts]
        ..sort((a, b) {
          final d = a.invoiceDate.compareTo(b.invoiceDate);
          return d != 0 ? d : a.createdAt.compareTo(b.createdAt);
        });
      final validityMap = <String, bool>{};
      for (final draft in sortedDrafts) {
        final items = allItems[draft.id]!;
        final valid = items.every(
          (item) => (remaining[item.productId] ?? 0) >= item.quantity,
        );
        validityMap[draft.id] = valid;
        if (valid) {
          for (final item in items) {
            remaining[item.productId] = (remaining[item.productId] ?? 0) - item.quantity;
          }
        }
      }

      if (mounted) {
        setState(() {
          _draftProductNames = nameMap;
          _draftValidity = validityMap;
        });
      }
    } finally {
      if (mounted) setState(() => _loadingProductNames = false);
    }
  }

  /// Scans Desktop for pre_order_confirmed_*.json and lets the user pick one.
  /// The confirmed_pieces for each matched item are added to local inventory
  /// (representing incoming stock that was approved by the warehouse).
  Future<void> _importConfirmedJson() async {
    final home = Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '';
    final desktop = Directory('$home\\Desktop');
    List<File> files = [];
    try {
      files = desktop
          .listSync()
          .whereType<File>()
          .where((f) =>
              f.path.endsWith('.json') &&
              f.uri.pathSegments.last.startsWith('pre_order_confirmed_'))
          .toList()
        ..sort((a, b) =>
            b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    } catch (_) {}

    if (!mounted) return;
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'No pre_order_confirmed_*.json files found on Desktop.')),
      );
      return;
    }

    // Show file picker.
    final picked = await showDialog<File>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Confirmed Order File'),
        content: SizedBox(
          width: 420,
          child: ListView(
            shrinkWrap: true,
            children: files
                .map((f) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.file_present_outlined),
                      title: Text(f.uri.pathSegments.last,
                          style: const TextStyle(fontSize: 13)),
                      onTap: () => Navigator.pop(ctx, f),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
        ],
      ),
    );
    if (picked == null || !mounted) return;

    // Parse file.
    final Map<String, dynamic> json;
    try {
      final raw = await picked.readAsString();
      json = jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to read file: $e')),
        );
      }
      return;
    }

    final itemsJson = (json['items'] as List<dynamic>?) ?? [];
    final products = await ref.read(productRepositoryProvider).getAll();
    final inventoryRepo = ref.read(inventoryRepositoryProvider);

    // Match each entry to a local product.
    final entries = <_ConfirmedEntry>[];
    for (final item in itemsJson) {
      final productId   = item['product_id']    as String?;
      final productName = item['product_name']  as String? ?? '';
      final productCode = item['product_code']  as String?;
      final confirmedPieces = (item['confirmed_pieces'] as num?)?.toInt() ?? 0;
      final piecesPerBox    = (item['pieces_per_box']   as num?)?.toInt() ?? 1;
      if (confirmedPieces <= 0) continue;

      Product? matched;
      if (productId != null) {
        matched = products.where((p) => p.id == productId).firstOrNull;
      }
      matched ??= products.where((p) => p.name == productName).firstOrNull;
      matched ??= products
          .where((p) => p.name.toLowerCase() == productName.toLowerCase())
          .firstOrNull;
      if (matched == null && productCode != null && productCode.isNotEmpty) {
        matched = products
            .where((p) =>
                p.productCode?.toLowerCase() == productCode.toLowerCase())
            .firstOrNull;
      }

      entries.add(_ConfirmedEntry(
        productName: productName,
        confirmedPieces: confirmedPieces,
        piecesPerBox: piecesPerBox,
        matched: matched,
      ));
    }

    if (!mounted) return;
    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid items found in the file.')),
      );
      return;
    }

    // Show preview & confirm.
    final dateFmt = DateFormat('MMM dd, yyyy HH:mm');
    final confirmedAt =
        (json['confirmed_at'] as String?) ?? '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Confirmed Stock'),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (confirmedAt.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Confirmed at: ${dateFmt.format(DateTime.tryParse(confirmedAt) ?? DateTime.now())}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              const Text(
                'The following stock will be added to your inventory:',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: SingleChildScrollView(
                  child: Column(
                    children: entries.map((e) {
                      final boxes = e.piecesPerBox > 0
                          ? e.confirmedPieces ~/ e.piecesPerBox
                          : 0;
                      final pcs = e.piecesPerBox > 0
                          ? e.confirmedPieces % e.piecesPerBox
                          : e.confirmedPieces;
                      final qtyStr = boxes > 0 && pcs > 0
                          ? '$boxes box(es) + $pcs pcs'
                          : boxes > 0
                              ? '$boxes box(es)'
                              : '$pcs pcs';
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          e.matched != null
                              ? Icons.check_circle_outline
                              : Icons.help_outline,
                          color: e.matched != null
                              ? Colors.green
                              : Colors.grey,
                          size: 18,
                        ),
                        title: Text(e.productName,
                            style: const TextStyle(fontSize: 13)),
                        subtitle: e.matched == null
                            ? const Text('Not found in products',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11))
                            : null,
                        trailing: Text('+$qtyStr',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${entries.where((e) => e.matched == null).length} item(s) could not be matched and will be skipped.',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Import')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _importingConfirmed = true);
    try {
      int updatedCount = 0;
      for (final entry in entries) {
        if (entry.matched == null) continue;
        await inventoryRepo.adjust(
          productId: entry.matched!.id,
          deltaPieces: entry.confirmedPieces,
        );
        updatedCount++;
      }
      ref.invalidate(inventoryListProvider);
      // Re-evaluate draft validity against the updated inventory.
      final currentDrafts =
          ref.read(preOrderDraftsProvider).valueOrNull ?? [];
      setState(() {
        _draftProductNames = {};
        _draftValidity = {};
      });
      if (currentDrafts.isNotEmpty) _loadProductNames(currentDrafts);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$updatedCount product(s) added to inventory.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _importingConfirmed = false);
    }
  }

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

  /// Aggregates all pre-order draft items into per-product tallies,
  /// sorted by supplier then product name.
  Future<List<_ProductTally>> _aggregateTallies() async {
    final drafts =
        await ref.read(invoiceRepositoryProvider).getPreOrderDrafts();
    final products = await ref.read(productRepositoryProvider).getAll();
    final suppliers = await ref.read(supplierRepositoryProvider).getAll();
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
            productId: product.id,
            productName: product.name,
            productCode: product.productCode,
            supplierName: suppliersById[product.supplierId] ?? 'Unknown',
            piecesPerBox: product.piecesPerBox,
            pieces: item.quantity,
            amount: item.subtotal,
          ),
        );
      }
    }

    return tally.values.toList()
      ..sort((a, b) {
        final s = a.supplierName.compareTo(b.supplierName);
        return s != 0 ? s : a.productName.compareTo(b.productName);
      });
  }

  Future<List<OrderSummaryRow>> _buildLayoutRows() async {
    final tallies = await _aggregateTallies();
    return tallies
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

  /// Exports a machine-readable JSON file that the main system can import
  /// to review quantities against its own inventory.
  Future<void> _exportJson() async {
    setState(() => _exporting = true);
    try {
      final tallies = await _aggregateTallies();
      if (tallies.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No items to export.')),
        );
        return;
      }
      final payload = {
        'version': '1',
        'exported_at': DateTime.now().toIso8601String(),
        'items': tallies
            .map((t) => {
                  'product_id': t.productId,
                  'product_name': t.productName,
                  'product_code': t.productCode,
                  'supplier_name': t.supplierName,
                  'pieces_per_box': t.piecesPerBox,
                  'total_pieces': t.pieces,
                })
            .toList(),
      };
      final home = Platform.environment['USERPROFILE'] ??
          Platform.environment['HOME'] ??
          '.';
      final tag = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('$home\\Desktop\\pre_order_$tag.json');
      await file.writeAsString(jsonEncode(payload));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to ${file.path}')),
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

    ref.listen(preOrderDraftsProvider, (_, next) {
      // Skip while reloading: whenData fires with stale data during reload,
      // which would run validity against drafts that no longer exist.
      if (next.isLoading) return;
      next.whenData((drafts) {
        if (!_loadingProductNames) {
          _loadProductNames(drafts);
        }
      });
    });

    return AppScaffold(
      title: 'Pre-Order Drafts',
      actions: [
        _importingConfirmed
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : IconButton(
                icon: const Icon(Icons.file_download),
                tooltip: 'Import confirmed order file',
                onPressed: _importConfirmedJson,
              ),
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
                icon: const Icon(Icons.file_upload_outlined),
                tooltip: 'Export for main system (JSON)',
                onPressed: _exportJson,
              ),
        PopupMenuButton<_DraftSortOrder>(
          icon: const Icon(Icons.sort),
          tooltip: 'Sort',
          initialValue: _sortOrder,
          onSelected: (v) => setState(() => _sortOrder = v),
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: _DraftSortOrder.newestFirst,
              child: Text('Newest first'),
            ),
            PopupMenuItem(
              value: _DraftSortOrder.oldestFirst,
              child: Text('Oldest first'),
            ),
            PopupMenuItem(
              value: _DraftSortOrder.clientAZ,
              child: Text('Client A→Z'),
            ),
          ],
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
          if (drafts.isNotEmpty &&
              _draftProductNames.isEmpty &&
              !_loadingProductNames) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted &&
                  _draftProductNames.isEmpty &&
                  !_loadingProductNames) {
                _loadProductNames(drafts);
              }
            });
          }
          if (drafts.isEmpty) {
            return const Center(
              child: Text('No pre-order drafts yet.\nTap "New" to create one.',
                  textAlign: TextAlign.center),
            );
          }
          final clientsById = {
            for (final c in clientsAsync.valueOrNull ?? []) c.id: c
          };
          final q = _productSearch.toLowerCase();
          final filtered = (q.isEmpty
              ? List<Invoice>.from(drafts)
              : drafts.where((d) {
                  final names = _draftProductNames[d.id] ?? {};
                  return names.any((n) => n.contains(q));
                }).toList())
            ..sort((a, b) {
              switch (_sortOrder) {
                case _DraftSortOrder.newestFirst:
                  return b.invoiceDate.compareTo(a.invoiceDate);
                case _DraftSortOrder.oldestFirst:
                  return a.invoiceDate.compareTo(b.invoiceDate);
                case _DraftSortOrder.clientAZ:
                  final ca = clientsById[a.clientId]?.name ?? a.clientId;
                  final cb = clientsById[b.clientId]?.name ?? b.clientId;
                  return ca.toLowerCase().compareTo(cb.toLowerCase());
              }
            });
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search by product...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    suffixIcon: _productSearch.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _productSearch = '');
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                  ),
                  onChanged: (v) => setState(() => _productSearch = v.trim()),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text('No drafts contain that product.',
                            style: TextStyle(color: Colors.grey)))
                    : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final d = filtered[i];
                    final client = clientsById[d.clientId];
                    final validity = _draftValidity[d.id];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: validity == false
                            ? Colors.orange.shade100
                            : const Color(0xFFE8F5E9),
                        child: Icon(
                          validity == false
                              ? Icons.warning_amber
                              : Icons.receipt_long,
                          color: validity == false
                              ? Colors.orange.shade700
                              : Colors.green,
                          size: 20,
                        ),
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

class _ConfirmedEntry {
  final String productName;
  final int confirmedPieces;
  final int piecesPerBox;
  final Product? matched;

  _ConfirmedEntry({
    required this.productName,
    required this.confirmedPieces,
    required this.piecesPerBox,
    required this.matched,
  });
}

class _ProductTally {
  final String productId;
  final String productName;
  final String? productCode;
  final String supplierName;
  final int piecesPerBox;
  int pieces;
  double amount;

  _ProductTally({
    required this.productId,
    required this.productName,
    this.productCode,
    required this.supplierName,
    required this.piecesPerBox,
    required this.pieces,
    required this.amount,
  });
}
