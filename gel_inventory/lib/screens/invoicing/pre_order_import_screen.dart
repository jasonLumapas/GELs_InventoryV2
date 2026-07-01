import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/pre_order_review_repository.dart';
import '../../repositories/product_repository.dart';
import '../../utils/currency_format.dart';
import '../../utils/pdf_generator.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/confirm_dialog.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class _ReviewRow {
  final String? productId;         // id from the source file
  final String? matchedProductId;  // local DB product UUID (null = not found)
  final String productName;
  final String? productCode;
  final String supplierName;
  final int piecesPerBox;
  final int requestedPieces;
  final int availablePieces;
  final bool productFound;
  final TextEditingController adjustedBoxCtrl;
  final TextEditingController adjustedPcsCtrl;
  // pieces already committed to inventory; used to compute delta on re-save
  int savedPieces = 0;
  // snapshot of available qty at the time of the last save (for display only)
  int snapshotAvailablePieces;

  _ReviewRow({
    this.productId,
    this.matchedProductId,
    required this.productName,
    this.productCode,
    required this.supplierName,
    required this.piecesPerBox,
    required this.requestedPieces,
    required this.availablePieces,
    required this.productFound,
    int? initialAdjustedPieces,
    int? savedAvailablePieces,
  })  : snapshotAvailablePieces = savedAvailablePieces ?? availablePieces,
        adjustedBoxCtrl = TextEditingController(
            text: piecesPerBox > 0
                ? ((initialAdjustedPieces ?? requestedPieces) ~/ piecesPerBox)
                    .toString()
                : '0'),
        adjustedPcsCtrl = TextEditingController(
            text: piecesPerBox > 0
                ? ((initialAdjustedPieces ?? requestedPieces) % piecesPerBox)
                    .toString()
                : (initialAdjustedPieces ?? requestedPieces).toString());

  void dispose() {
    adjustedBoxCtrl.dispose();
    adjustedPcsCtrl.dispose();
  }

  int get adjustedPieces {
    final boxes = int.tryParse(adjustedBoxCtrl.text) ?? 0;
    final pcs   = int.tryParse(adjustedPcsCtrl.text) ?? 0;
    return boxes * piecesPerBox + pcs;
  }

  bool get isSufficient => !productFound || (adjustedPieces - savedPieces) <= availablePieces;

  int get reqBoxes => piecesPerBox > 0 ? requestedPieces ~/ piecesPerBox : 0;
  int get reqPcs   => piecesPerBox > 0 ? requestedPieces % piecesPerBox : requestedPieces;
  int get avlBoxes => piecesPerBox > 0 ? snapshotAvailablePieces ~/ piecesPerBox : 0;
  int get avlPcs   => piecesPerBox > 0 ? snapshotAvailablePieces % piecesPerBox : snapshotAvailablePieces;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class PreOrderImportScreen extends ConsumerStatefulWidget {
  const PreOrderImportScreen({super.key});

  @override
  ConsumerState<PreOrderImportScreen> createState() =>
      _PreOrderImportScreenState();
}

class _PreOrderImportScreenState
    extends ConsumerState<PreOrderImportScreen> {
  List<File> _jsonFiles = [];
  File? _selectedFile;
  bool _loadingFiles = true;
  bool _loadingReview = false;
  bool _saving = false;
  List<_ReviewRow> _rows = [];
  String _exportedAt = '';

  // ── Review history ──────────────────────────────────────────────────────────
  List<PreOrderReview> _savedReviews = [];
  bool _loadingSavedReviews = true;
  // The source file name currently being edited (set by both _loadFile and
  // _loadReview) — used as the upsert key and in the export payload.
  String _currentSourceFile = '';

  @override
  void initState() {
    super.initState();
    _scanDesktop();
    _loadSavedReviews();
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
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
              f.uri.pathSegments.last.startsWith('pre_order_') &&
              !f.uri.pathSegments.last.startsWith('pre_order_confirmed_'))
          .toList()
        ..sort((a, b) =>
            b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      setState(() {
        _jsonFiles = files;
        _loadingFiles = false;
      });
    } catch (_) {
      setState(() => _loadingFiles = false);
    }
  }

  // ── Saved reviews ───────────────────────────────────────────────────────────

  Future<void> _loadSavedReviews() async {
    final reviews =
        await ref.read(preOrderReviewRepositoryProvider).getAll();
    if (!mounted) return;
    setState(() {
      _savedReviews = reviews;
      _loadingSavedReviews = false;
    });
  }

  Future<void> _loadReview(PreOrderReview review) async {
    setState(() {
      _loadingReview = true;
      _selectedFile = null;
      _currentSourceFile = review.sourceFile;
      _exportedAt = review.originalExportedAt;
      for (final r in _rows) { r.dispose(); }
      _rows = [];
    });

    try {
      final items = await ref
          .read(preOrderReviewRepositoryProvider)
          .getItems(review.id);

      final allProducts =
          await ref.read(productRepositoryProvider).getAll();
      final inventoryRepo = ref.read(inventoryRepositoryProvider);

      final rows = <_ReviewRow>[];
      for (final item in items) {
        // Prefer the saved matchedProductId (local UUID) for re-matching.
        final matched = _findProduct(
            allProducts, item.matchedProductId, item.productName, item.productCode);

        int available = 0;
        if (matched != null) {
          final inv = await inventoryRepo.getByProductId(matched.id);
          available = inv?.quantityPieces ?? 0;
        }

        rows.add(_ReviewRow(
          productId: item.productId,
          matchedProductId: matched?.id ?? item.matchedProductId,
          productName: item.productName,
          productCode: item.productCode,
          supplierName: item.supplierName,
          piecesPerBox: item.piecesPerBox,
          requestedPieces: item.requestedPieces,
          availablePieces: available,
          productFound: matched != null,
          initialAdjustedPieces: item.confirmedPieces,
          // Use the stored snapshot so the Available column shows what was
          // on hand when this review was originally saved.
          savedAvailablePieces: item.availablePieces,
        ));
        // Delta tracking starts from what was already committed to inventory.
        rows.last.savedPieces = item.confirmedPieces;
      }

      if (!mounted) return;
      setState(() {
        _rows = rows;
        _loadingReview = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingReview = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load review: $e')),
      );
    }
  }

  Future<void> _deleteReview(PreOrderReview review) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Saved Review?',
      message: 'This removes the saved record only. '
          'Inventory quantities already applied are NOT reversed.',
      confirmLabel: 'Delete',
    );
    if (!confirmed) return;
    await ref.read(preOrderReviewRepositoryProvider).delete(review.id);
    // Clear the editor if the active review was just deleted.
    if (_currentSourceFile == review.sourceFile && _selectedFile == null) {
      setState(() {
        for (final r in _rows) { r.dispose(); }
        _rows = [];
        _currentSourceFile = '';
        _exportedAt = '';
      });
    }
    await _loadSavedReviews();
  }

  // ── File load ───────────────────────────────────────────────────────────────

  Future<void> _loadFile(File file) async {
    setState(() {
      _loadingReview = true;
      _selectedFile = file;
      _currentSourceFile = file.uri.pathSegments.last;
      for (final r in _rows) { r.dispose(); }
      _rows = [];
    });

    try {
      final raw = await file.readAsString();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _exportedAt = (json['exported_at'] as String?) ?? '';
      final itemsJson = (json['items'] as List<dynamic>?) ?? [];

      final allProducts = await ref.read(productRepositoryProvider).getAll();
      final inventoryRepo = ref.read(inventoryRepositoryProvider);

      final rows = <_ReviewRow>[];
      for (final item in itemsJson) {
        final productId    = item['product_id']    as String?;
        final productName  = item['product_name']  as String? ?? '';
        final productCode  = item['product_code']  as String?;
        final supplierName = item['supplier_name'] as String? ?? 'Unknown';
        final piecesPerBox = (item['pieces_per_box'] as num?)?.toInt() ?? 1;
        final totalPieces  = (item['total_pieces']   as num?)?.toInt() ?? 0;

        final matched =
            _findProduct(allProducts, productId, productName, productCode);

        int available = 0;
        if (matched != null) {
          final inv = await inventoryRepo.getByProductId(matched.id);
          available = inv?.quantityPieces ?? 0;
        }

        rows.add(_ReviewRow(
          productId: productId,
          matchedProductId: matched?.id,
          productName: productName,
          productCode: productCode,
          supplierName: supplierName,
          piecesPerBox: piecesPerBox,
          requestedPieces: totalPieces,
          availablePieces: available,
          productFound: matched != null,
        ));
      }

      if (!mounted) return;
      setState(() {
        _rows = rows;
        _loadingReview = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingReview = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to read file: $e')),
      );
    }
  }

  dynamic _findProduct(
      List<dynamic> products, String? id, String name, String? code) {
    if (id != null) {
      final m = products.where((p) => p.id == id).firstOrNull;
      if (m != null) return m;
    }
    final m2 = products.where((p) => p.name == name).firstOrNull;
    if (m2 != null) return m2;
    final lower = name.toLowerCase();
    final m3 =
        products.where((p) => p.name.toLowerCase() == lower).firstOrNull;
    if (m3 != null) return m3;
    if (code != null && code.isNotEmpty) {
      final m4 = products
          .where((p) => p.productCode?.toLowerCase() == code.toLowerCase())
          .firstOrNull;
      if (m4 != null) return m4;
    }
    return null;
  }

  // ── Save / export ───────────────────────────────────────────────────────────

  Future<void> _saveToInventory() async {
    if (_rows.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final inventoryRepo = ref.read(inventoryRepositoryProvider);
      final reviewRepo = ref.read(preOrderReviewRepositoryProvider);
      int updatedCount = 0;

      for (final row in _rows) {
        if (row.matchedProductId == null) continue;
        final delta = row.adjustedPieces - row.savedPieces;
        if (delta == 0) continue;
        await inventoryRepo.adjust(
          productId: row.matchedProductId!,
          deltaPieces: -delta,
        );
        row.savedPieces = row.adjustedPieces;
        updatedCount++;
      }

      // Persist the review so it can be retrieved and re-edited later.
      if (_currentSourceFile.isNotEmpty) {
        await reviewRepo.upsert(
          sourceFile: _currentSourceFile,
          originalExportedAt: _exportedAt,
          items: _rows
              .map((r) => PreOrderReviewItemInput(
                    productId: r.productId,
                    matchedProductId: r.matchedProductId,
                    productName: r.productName,
                    productCode: r.productCode,
                    supplierName: r.supplierName,
                    piecesPerBox: r.piecesPerBox,
                    requestedPieces: r.requestedPieces,
                    availablePieces: r.snapshotAvailablePieces,
                    confirmedPieces: r.savedPieces,
                  ))
              .toList(),
        );
        await _loadSavedReviews();
      }

      if (updatedCount > 0) ref.invalidate(inventoryListProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(updatedCount == 0
              ? 'No changes — review saved.'
              : 'Inventory updated for $updatedCount product(s). Review saved.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _exportConfirmed() async {
    if (_rows.isEmpty || _currentSourceFile.isEmpty) return;
    final payload = {
      'version': '1',
      'type': 'pre_order_confirmed',
      'source_file': _currentSourceFile,
      'original_exported_at': _exportedAt,
      'confirmed_at': DateTime.now().toIso8601String(),
      'items': _rows
          .map((r) => {
                'product_id': r.productId,
                'product_name': r.productName,
                'product_code': r.productCode,
                'supplier_name': r.supplierName,
                'pieces_per_box': r.piecesPerBox,
                'requested_pieces': r.requestedPieces,
                'confirmed_pieces': r.adjustedPieces,
                'available_pieces': r.availablePieces,
              })
          .toList(),
    };
    final home = Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '.';
    final tag = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file =
        File('$home\\Desktop\\pre_order_confirmed_$tag.json');
    await file.writeAsString(jsonEncode(payload));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported to ${file.path}')),
    );
  }

  Future<void> _printAdjusted() async {
    final rows = _rows
        .where((r) => r.adjustedPieces > 0)
        .map((r) => OrderSummaryRow(
              productName: r.productName,
              totalPieces: r.adjustedPieces,
              piecesPerBox: r.piecesPerBox,
              totalAmount: 0,
            ))
        .toList();
    if (rows.isEmpty) return;
    await printPreOrderLayout(rows: rows);
  }

  String _fmtQty(int boxes, int pcs) {
    if (boxes > 0 && pcs > 0) return '$boxes box(es) + $pcs pcs';
    if (boxes > 0) return '$boxes box(es)';
    if (pcs > 0) return '$pcs pcs';
    return '—';
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM dd, yyyy HH:mm');

    return AppScaffold(
      title: 'Import Pre-Order File',
      actions: [
        if (_rows.isNotEmpty) ...[
          _saving
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: _rows.any((r) => r.productFound && !r.isSufficient)
                      ? 'Cannot save — insufficient stock'
                      : 'Save & deduct inventory',
                  onPressed: _rows.any((r) => r.productFound && !r.isSufficient)
                      ? null
                      : _saveToInventory,
                ),
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export confirmed file',
            onPressed: _exportConfirmed,
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print adjusted layout',
            onPressed: _printAdjusted,
          ),
        ],
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Rescan Desktop',
          onPressed: () {
            setState(() => _loadingFiles = true);
            _scanDesktop();
          },
        ),
      ],
      body: Column(
        children: [
          // ── Top panel: file picker + saved reviews ───────────────────────
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.all(12),
            child: _loadingFiles
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── File picker ──────────────────────────────────────
                      const Text('Import from Desktop:',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      if (_jsonFiles.isEmpty)
                        const Text(
                          'No pre_order_*.json files found on Desktop.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: _jsonFiles.map((f) {
                            final name = f.uri.pathSegments.last;
                            final selected = _selectedFile?.path == f.path;
                            return ChoiceChip(
                              label: Text(name,
                                  style: const TextStyle(fontSize: 12)),
                              selected: selected,
                              onSelected: (_) => _loadFile(f),
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),

                      // ── Saved reviews ────────────────────────────────────
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      const Text('Saved Reviews:',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      if (_loadingSavedReviews)
                        const SizedBox(
                          height: 20,
                          child: LinearProgressIndicator(),
                        )
                      else if (_savedReviews.isEmpty)
                        const Text('No saved reviews yet.',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 12))
                      else
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 180),
                          child: SingleChildScrollView(
                            child: Column(
                              children: _savedReviews
                                  .map((r) => _buildReviewTile(r, dateFmt))
                                  .toList(),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          const Divider(height: 1),

          // ── Review table ─────────────────────────────────────────────────
          if (_loadingReview)
            const Expanded(
                child: Center(child: CircularProgressIndicator()))
          else if (_rows.isEmpty && _currentSourceFile.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                    'Select a file or load a saved review to get started.',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else if (_rows.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No items found.',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  // Source label
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Row(
                      children: [
                        const Icon(Icons.folder_open,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _currentSourceFile,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_exportedAt.isNotEmpty)
                          Text(
                            'Exported: ${dateFmt.format(DateTime.tryParse(_exportedAt) ?? DateTime.now())}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),

                  // Legend
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        const Text('Sufficient',
                            style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 16),
                        Icon(Icons.warning,
                            size: 14, color: Colors.orange.shade700),
                        const SizedBox(width: 4),
                        const Text('Insufficient',
                            style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 16),
                        const Icon(Icons.help_outline,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        const Text('Not found',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Column headers
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: Row(
                      children: const [
                        Expanded(
                            flex: 4,
                            child: Text('Product',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12))),
                        Expanded(
                            flex: 3,
                            child: Text('Requested',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12))),
                        Expanded(
                            flex: 3,
                            child: Text('Available',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12))),
                        SizedBox(
                            width: 160,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text('Box',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text('Pcs',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Rows
                  Expanded(
                    child: ListView.separated(
                      itemCount: _rows.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final row = _rows[i];
                        final insufficient = !row.isSufficient;
                        return Container(
                          color: insufficient
                              ? Colors.orange.shade50
                              : null,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              // Status icon + product name
                              Expanded(
                                flex: 4,
                                child: Row(
                                  children: [
                                    !row.productFound
                                        ? const Icon(Icons.help_outline,
                                            size: 16, color: Colors.grey)
                                        : insufficient
                                            ? Icon(Icons.warning,
                                                size: 16,
                                                color: Colors.orange.shade700)
                                            : const Icon(Icons.check_circle,
                                                size: 16,
                                                color: Colors.green),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(row.productName,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: !row.productFound
                                                      ? Colors.grey
                                                      : null)),
                                          Text(row.supplierName,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Requested
                              Expanded(
                                flex: 3,
                                child: Text(
                                  _fmtQty(row.reqBoxes, row.reqPcs),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              // Available
                              Expanded(
                                flex: 3,
                                child: Text(
                                  row.productFound
                                      ? _fmtQty(row.avlBoxes, row.avlPcs)
                                      : 'Unknown',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: !row.productFound
                                        ? Colors.grey
                                        : insufficient
                                            ? Colors.orange.shade700
                                            : Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              // Adjusted — Box and Pcs fields
                              SizedBox(
                                width: 160,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: row.adjustedBoxCtrl,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        textAlign: TextAlign.center,
                                        style:
                                            const TextStyle(fontSize: 13),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          hintText: '0',
                                          suffixText: 'box',
                                          border: OutlineInputBorder(),
                                          contentPadding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 6),
                                        ),
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: TextField(
                                        controller: row.adjustedPcsCtrl,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        textAlign: TextAlign.center,
                                        style:
                                            const TextStyle(fontSize: 13),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          hintText: '0',
                                          suffixText: 'pcs',
                                          border: OutlineInputBorder(),
                                          contentPadding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 6),
                                        ),
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Footer summary
                  Container(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Text(
                          '${_rows.length} product(s)  •  '
                          '${_rows.where((r) => !r.isSufficient).length} insufficient',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13),
                        ),
                        const Spacer(),
                        Text(
                          'Total adjusted: ${formatNumber(_rows.fold<int>(0, (s, r) => s + r.adjustedPieces))} pcs',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewTile(PreOrderReview review, DateFormat dateFmt) {
    final isActive = _currentSourceFile == review.sourceFile &&
        _selectedFile == null &&
        _rows.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () => _loadReview(review),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.sourceFile,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                    Text(
                      'Saved: ${dateFmt.format(review.reviewedAt)}',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            tooltip: 'Delete review',
            color: Colors.red.shade400,
            visualDensity: VisualDensity.compact,
            onPressed: () => _deleteReview(review),
          ),
        ],
      ),
    );
  }
}
