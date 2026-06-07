import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/product.dart';
import '../../models/product_price.dart';
import '../../models/supplier.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../widgets/common/app_scaffold.dart';

class CsvImportScreen extends ConsumerStatefulWidget {
  const CsvImportScreen({super.key});

  @override
  ConsumerState<CsvImportScreen> createState() => _CsvImportScreenState();
}

class _CsvImportScreenState extends ConsumerState<CsvImportScreen> {
  final _pathCtrl = TextEditingController();
  bool _importing = false;
  final List<_LogEntry> _log = [];
  _ImportSummary? _summary;

  @override
  void initState() {
    super.initState();
    final home = Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '';
    _pathCtrl.text = '$home\\Desktop\\supplier_products.csv';
  }

  @override
  void dispose() {
    _pathCtrl.dispose();
    super.dispose();
  }

  void _addLog(String msg, {_LogLevel level = _LogLevel.info}) =>
      setState(() => _log.add(_LogEntry(msg, level)));

  // ── CSV parser ────────────────────────────────────────────────────────────
  // Handles double-quoted fields that may contain commas.
  List<List<String>> _parseCsv(String content) {
    final rows = <List<String>>[];
    for (var line in content.split('\n')) {
      line = line.trim();
      if (line.isEmpty) continue;
      final fields = <String>[];
      bool inQuotes = false;
      final buf = StringBuffer();
      for (int i = 0; i < line.length; i++) {
        final ch = line[i];
        if (ch == '"') {
          inQuotes = !inQuotes;
        } else if (ch == ',' && !inQuotes) {
          fields.add(buf.toString().trim());
          buf.clear();
        } else {
          buf.write(ch);
        }
      }
      fields.add(buf.toString().trim());
      rows.add(fields);
    }
    return rows;
  }

  // ── CSV field helpers ─────────────────────────────────────────────────────

  String _field(List<String> row, int col) =>
      row.length > col ? row[col].trim() : '';

  double _fieldDouble(List<String> row, int col) =>
      double.tryParse(_field(row, col)) ?? 0.0;

  int _fieldInt(List<String> row, int col) {
    final s = _field(row, col);
    return int.tryParse(s) ?? (double.tryParse(s)?.round() ?? 0);
  }

  // ── Import logic ──────────────────────────────────────────────────────────

  Future<void> _import() async {
    final path = _pathCtrl.text.trim();
    final file = File(path);
    if (!file.existsSync()) {
      _addLog('File not found: $path', level: _LogLevel.error);
      return;
    }

    setState(() {
      _importing = true;
      _log.clear();
      _summary = null;
    });

    try {
      final content = await file.readAsString();
      final allRows = _parseCsv(content);

      if (allRows.isEmpty) {
        _addLog('File is empty.', level: _LogLevel.error);
        return;
      }

      // Header row
      final header = allRows.first;
      _addLog('${allRows.length - 1} data rows  |  ${header.length} columns');
      _addLog('Headers: ${header.asMap().entries.map((e) {
        final letter = String.fromCharCode(65 + e.key);
        return '$letter="${e.value}"';
      }).join("  ")}');

      // Column H (index 7) carries stock (total pcs)
      final hasTotalPcs = allRows.length > 1 && allRows[1].length > 7;
      if (hasTotalPcs) {
        _addLog('Col H present — inventory will be set from stock values.');
      } else {
        _addLog(
            'Col H not present '
            '(row width=${allRows.length > 1 ? allRows[1].length : 0}) '
            '— inventory initialised at 0.',
            level: _LogLevel.warn);
      }

      // Data rows (skip header)
      final dataRows = allRows.skip(1).toList();

      final supplierRepo  = ref.read(supplierRepositoryProvider);
      final productRepo   = ref.read(productRepositoryProvider);
      final inventoryRepo = ref.read(inventoryRepositoryProvider);

      // Pre-load existing records
      final existingSuppliers = await supplierRepo.getAll();
      final existingProducts  = await productRepo.getAll();

      final supplierByName = <String, String>{
        for (final s in existingSuppliers) s.name.toLowerCase(): s.id,
      };
      final productById = <String, String>{
        for (final p in existingProducts) p.name.toLowerCase(): p.id,
      };

      int suppliersCreated = 0;
      int productsCreated  = 0;
      int inventoryUpdated = 0;
      int skipped          = 0;
      int errors           = 0;

      for (int i = 0; i < dataRows.length; i++) {
        final row = dataRows[i];

        final supplierName = _field(row, 0);
        final productName  = _field(row, 1);
        final piecesPerBox = _fieldInt(row, 2);
        final withdrawal   = _fieldDouble(row, 3);
        final selling      = _fieldDouble(row, 4);
        final totalPcs     = hasTotalPcs ? _fieldInt(row, 7) : 0;
        final productCode  = _field(row, 8);

        // Log the first 5 rows to confirm H column is being read
        if (i < 5) {
          _addLog('  Row ${i + 2}: "$productName"  '
              'H-raw="${_field(row, 7)}"  totalPcs=$totalPcs');
        }

        if (supplierName.isEmpty || productName.isEmpty) {
          skipped++;
          continue;
        }

        // ── Supplier: find or create ──────────────────────────────────────
        final supplierKey = supplierName.toLowerCase();
        String supplierId;
        if (supplierByName.containsKey(supplierKey)) {
          supplierId = supplierByName[supplierKey]!;
        } else {
          final supplier = Supplier(
            id: const Uuid().v4(),
            name: supplierName,
            createdAt: DateTime.now(),
          );
          await supplierRepo.upsert(supplier);
          supplierByName[supplierKey] = supplier.id;
          supplierId = supplier.id;
          suppliersCreated++;
          _addLog('Created supplier: $supplierName', level: _LogLevel.success);
        }

        // ── Product: find or create ───────────────────────────────────────
        final productKey = productName.toLowerCase();
        String productId;

        if (productById.containsKey(productKey)) {
          productId = productById[productKey]!;
        } else {
          try {
            productId = const Uuid().v4();
            await productRepo.upsertProduct(Product(
              id: productId,
              name: productName,
              productCode: productCode.isEmpty ? null : productCode,
              supplierId: supplierId,
              piecesPerBox: piecesPerBox < 1 ? 1 : piecesPerBox,
              createdAt: DateTime.now(),
            ));
            await productRepo.addPrice(ProductPrice(
              id: const Uuid().v4(),
              productId: productId,
              withdrawalPrice: withdrawal,
              sellingPrice: selling,
              effectiveFrom: DateTime.now(),
            ));
            productById[productKey] = productId;
            productsCreated++;
          } catch (e) {
            _addLog('Row ${i + 2} ($productName): $e', level: _LogLevel.error);
            errors++;
            continue;
          }
        }

        // ── Inventory: set absolute qty from H column ─────────────────────
        // Applies to both new and existing products.
        try {
          final current    = await inventoryRepo.getByProductId(productId);
          final currentQty = current?.quantityPieces ?? 0;
          final delta      = totalPcs - currentQty;
          if (delta != 0 || current == null) {
            await inventoryRepo.adjust(
                productId: productId, deltaPieces: delta);
            inventoryUpdated++;
          }
        } catch (e) {
          _addLog('Inventory row ${i + 2} ($productName): $e',
              level: _LogLevel.error);
          errors++;
        }
      }

      setState(() {
        _summary = _ImportSummary(
          suppliersCreated: suppliersCreated,
          productsCreated:  productsCreated,
          inventoryUpdated: inventoryUpdated,
          skipped:          skipped,
          errors:           errors,
        );
      });
      _addLog('Import complete.', level: _LogLevel.success);
    } catch (e) {
      _addLog('Fatal error: $e', level: _LogLevel.error);
    } finally {
      setState(() => _importing = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Import CSV',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── File path ───────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _pathCtrl,
                    decoration: const InputDecoration(
                      labelText: 'CSV File Path',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.folder_open),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  icon: _importing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.upload),
                  label: const Text('Import'),
                  onPressed: _importing ? null : _import,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Expected columns: A=supplier  B=product  C=pieces_per_box  '
              'D=withdrawal_price  E=selling_price  H=stock (total pcs)  '
              'I=product_code',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),

            // ── Summary card ────────────────────────────────────────────────
            if (_summary != null) _SummaryCard(summary: _summary!),

            const Divider(height: 20),

            // ── Log output ──────────────────────────────────────────────────
            Expanded(
              child: _log.isEmpty
                  ? Center(
                      child: Text('Set the file path and press Import.',
                          style: TextStyle(color: Colors.grey.shade500)))
                  : ListView.builder(
                      itemCount: _log.length,
                      itemBuilder: (_, i) {
                        final entry = _log[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          child: Text(
                            entry.message,
                            style: TextStyle(
                              fontFamily: 'Courier New',
                              fontSize: 12,
                              color: switch (entry.level) {
                                _LogLevel.error   => Colors.red.shade700,
                                _LogLevel.warn    => Colors.orange.shade800,
                                _LogLevel.success => Colors.green.shade700,
                                _LogLevel.info    => null,
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────

class _ImportSummary {
  final int suppliersCreated;
  final int productsCreated;
  final int inventoryUpdated;
  final int skipped;
  final int errors;

  const _ImportSummary({
    required this.suppliersCreated,
    required this.productsCreated,
    required this.inventoryUpdated,
    required this.skipped,
    required this.errors,
  });
}

class _SummaryCard extends StatelessWidget {
  final _ImportSummary summary;
  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Stat('Suppliers',     summary.suppliersCreated, Colors.blue.shade700),
            _Stat('Products',      summary.productsCreated,  Colors.green.shade700),
            _Stat('Inventory set', summary.inventoryUpdated, Colors.teal.shade700),
            _Stat('Skipped',       summary.skipped,          Colors.grey),
            _Stat('Errors',        summary.errors,           Colors.red.shade700),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _Stat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value',
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

// ── Log helpers ───────────────────────────────────────────────────────────────

enum _LogLevel { info, success, warn, error }

class _LogEntry {
  final String message;
  final _LogLevel level;
  const _LogEntry(this.message, this.level);
}
