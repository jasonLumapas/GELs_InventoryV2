import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/product.dart';
import '../../models/stocks_loading.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/stocks_loading_repository.dart';
import '../../widgets/common/app_scaffold.dart';

// ── Preview row (pre-import) ──────────────────────────────────────────────────

class _PreviewRow {
  final StocksLoadingExportItem source;
  final String? matchedProductId;

  const _PreviewRow({required this.source, this.matchedProductId});

  bool get matched => matchedProductId != null;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class StocksForSaleLoadingScreen extends ConsumerStatefulWidget {
  const StocksForSaleLoadingScreen({super.key});

  @override
  ConsumerState<StocksForSaleLoadingScreen> createState() =>
      _StocksForSaleLoadingScreenState();
}

class _StocksForSaleLoadingScreenState
    extends ConsumerState<StocksForSaleLoadingScreen> {
  // ── date ──────────────────────────────────────────────────────────────────
  DateTime _selectedDate = DateTime.now();

  // ── file selection ────────────────────────────────────────────────────────
  List<File> _desktopFiles = [];
  File? _selectedFile;
  bool _scanningFiles = true;

  // ── preview ───────────────────────────────────────────────────────────────
  List<_PreviewRow> _preview = [];
  String _previewExportedAt = '';
  bool _loadingPreview = false;

  // ── saved records for selected date ───────────────────────────────────────
  List<StocksLoadingRecord> _records = [];
  bool _loadingRecords = true;

  // ── saving ────────────────────────────────────────────────────────────────
  bool _saving = false;

  static final _dateFmt = DateFormat('yyyy-MM-dd');
  static final _timeFmt = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    _scanDesktop();
    _loadRecords();
  }

  // ── Desktop scan ────────────────────────────────────────────────────────────

  Future<void> _scanDesktop() async {
    final home = Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '';
    final desktop = Directory('$home\\Desktop');
    try {
      final files = desktop
          .listSync()
          .whereType<File>()
          .where((f) =>
              f.path.endsWith('.json') &&
              f.uri.pathSegments.last.startsWith('stocks_for_sale_'))
          .toList()
        ..sort((a, b) =>
            b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      if (mounted) {
        setState(() {
          _desktopFiles = files;
          _scanningFiles = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _scanningFiles = false);
    }
  }

  // ── Records for selected date ───────────────────────────────────────────────

  Future<void> _loadRecords() async {
    if (!mounted) return;
    setState(() => _loadingRecords = true);
    final repo = ref.read(stocksLoadingRepositoryProvider);
    final headers = await repo.getByDate(_selectedDate);
    final records = <StocksLoadingRecord>[];
    for (final h in headers) {
      records.add(await repo.getRecord(h));
    }
    if (mounted) setState(() { _records = records; _loadingRecords = false; });
  }

  // ── Date picker ─────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
      _preview = [];
      _selectedFile = null;
    });
    _loadRecords();
  }

  // ── Load file preview ───────────────────────────────────────────────────────

  Future<void> _loadPreview(File file) async {
    setState(() { _loadingPreview = true; _preview = []; _selectedFile = file; });
    try {
      final raw = await file.readAsString();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final export = StocksLoadingExport.fromJson(json);

      final allProducts = await ref.read(productRepositoryProvider).getAll();

      Product? findProduct(StocksLoadingExportItem item) {
        if (item.productCode != null && item.productCode!.isNotEmpty) {
          final byCode = allProducts
              .where((p) => p.productCode == item.productCode)
              .firstOrNull;
          if (byCode != null) return byCode;
        }
        return allProducts
            .where((p) =>
                p.name.toLowerCase() == item.productName.toLowerCase())
            .firstOrNull;
      }

      final rows = export.items.map((item) {
        final match = findProduct(item);
        return _PreviewRow(source: item, matchedProductId: match?.id);
      }).toList();

      if (mounted) {
        setState(() {
          _preview = rows;
          _previewExportedAt = export.exportedAt;
          _loadingPreview = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingPreview = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to read file: $e')));
      }
    }
  }

  // ── Import ──────────────────────────────────────────────────────────────────

  Future<void> _import() async {
    if (_preview.isEmpty) return;
    setState(() => _saving = true);
    try {
      final inventoryRepo = ref.read(inventoryRepositoryProvider);
      final loadingRepo = ref.read(stocksLoadingRepositoryProvider);

      for (final row in _preview) {
        if (row.matched) {
          await inventoryRepo.adjust(
            productId: row.matchedProductId!,
            deltaPieces: row.source.quantityPieces,
          );
        }
      }

      await loadingRepo.save(
        loadingDate: _selectedDate,
        items: _preview
            .map((r) => StocksLoadingItemInput(
                  productCode: r.source.productCode,
                  productName: r.source.productName,
                  supplierName: r.source.supplierName,
                  quantityPieces: r.source.quantityPieces,
                  piecesPerBox: r.source.piecesPerBox,
                ))
            .toList(),
      );

      if (mounted) {
        setState(() {
          _preview = [];
          _selectedFile = null;
          _saving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Import successful.')));
        ref.invalidate(inventoryListProvider);
        _loadRecords();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')));
      }
    }
  }

  // ── Delete record ───────────────────────────────────────────────────────────

  Future<void> _deleteRecord(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete record?'),
        content: const Text(
            'This will not reverse the inventory adjustment that was applied on import.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(stocksLoadingRepositoryProvider).delete(id);
    _loadRecords();
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Stocks for Sale Loading',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImportCard(),
            const SizedBox(height: 24),
            _buildLayoutSection(),
          ],
        ),
      ),
    );
  }

  // ── Import card ─────────────────────────────────────────────────────────────

  Widget _buildImportCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Import', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Loading Date:'),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(_dateFmt.format(_selectedDate)),
                ),
                const SizedBox(width: 24),
                const Text('File:'),
                const SizedBox(width: 8),
                if (_scanningFiles)
                  const SizedBox(
                      width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                else if (_desktopFiles.isEmpty)
                  const Text('No stocks_for_sale_*.json files on Desktop',
                      style: TextStyle(fontStyle: FontStyle.italic))
                else
                  DropdownButton<File>(
                    value: _selectedFile,
                    hint: const Text('Select file'),
                    items: _desktopFiles
                        .map((f) => DropdownMenuItem(
                              value: f,
                              child: Text(f.uri.pathSegments.last),
                            ))
                        .toList(),
                    onChanged: (f) { if (f != null) _loadPreview(f); },
                  ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Refresh file list',
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    setState(() => _scanningFiles = true);
                    _scanDesktop();
                  },
                ),
              ],
            ),
            if (_loadingPreview)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_preview.isNotEmpty) ...[
              const SizedBox(height: 12),
              if (_previewExportedAt.isNotEmpty)
                Text('Exported at: $_previewExportedAt',
                    style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              _buildPreviewTable(),
              const SizedBox(height: 12),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: _saving ? null : _import,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.download_done),
                    label: const Text('Import & Add to Inventory'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _saving
                        ? null
                        : () => setState(() {
                              _preview = [];
                              _selectedFile = null;
                            }),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewTable() {
    final unmatched = _preview.where((r) => !r.matched).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (unmatched > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '$unmatched product(s) not found locally — inventory will not be adjusted for those.',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 12),
            ),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 36,
            dataRowMinHeight: 32,
            dataRowMaxHeight: 40,
            columns: const [
              DataColumn(label: Text('Product')),
              DataColumn(label: Text('Supplier')),
              DataColumn(label: Text('Boxes'), numeric: true),
              DataColumn(label: Text('Pcs'), numeric: true),
              DataColumn(label: Text('Total Pcs'), numeric: true),
              DataColumn(label: Text('Status')),
            ],
            rows: _preview.map((row) {
              final ppb = row.source.piecesPerBox;
              final boxes = ppb > 0 ? row.source.quantityPieces ~/ ppb : 0;
              final pcs = ppb > 0 ? row.source.quantityPieces % ppb : row.source.quantityPieces;
              return DataRow(cells: [
                DataCell(Text(row.source.productName)),
                DataCell(Text(row.source.supplierName)),
                DataCell(Text('$boxes')),
                DataCell(Text('$pcs')),
                DataCell(Text('${row.source.quantityPieces}')),
                DataCell(row.matched
                    ? const Icon(Icons.check_circle,
                        color: Colors.green, size: 18)
                    : const Icon(Icons.warning_amber,
                        color: Colors.orange, size: 18)),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Layout section ──────────────────────────────────────────────────────────

  Widget _buildLayoutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Stocks for Sale Loading — ${_dateFmt.format(_selectedDate)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_loadingRecords)
          const Center(child: CircularProgressIndicator())
        else if (_records.isEmpty)
          const Text('No imports for this date.',
              style: TextStyle(fontStyle: FontStyle.italic))
        else
          ..._records.map((rec) => _buildRecordCard(rec)),
      ],
    );
  }

  Widget _buildRecordCard(StocksLoadingRecord rec) {
    final totalPieces = rec.items.fold<int>(0, (s, i) => s + i.quantityPieces);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          'Imported at ${_timeFmt.format(rec.importedAt)}  ·  ${rec.items.length} products  ·  $totalPieces total pcs',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deleteRecord(rec.id),
            ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 36,
              dataRowMinHeight: 32,
              dataRowMaxHeight: 40,
              columns: const [
                DataColumn(label: Text('Product')),
                DataColumn(label: Text('Supplier')),
                DataColumn(label: Text('Boxes'), numeric: true),
                DataColumn(label: Text('Pcs'), numeric: true),
                DataColumn(label: Text('Total Pcs'), numeric: true),
              ],
              rows: rec.items.map((item) => DataRow(cells: [
                    DataCell(Text(item.productName)),
                    DataCell(Text(item.supplierName)),
                    DataCell(Text('${item.boxes}')),
                    DataCell(Text('${item.remainingPieces}')),
                    DataCell(Text('${item.quantityPieces}')),
                  ])).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
