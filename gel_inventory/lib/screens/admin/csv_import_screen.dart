import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../models/client.dart';
import '../../models/product.dart';
import '../../models/product_price.dart';
import '../../models/stock_movement.dart';
import '../../models/supplier.dart';
import '../../repositories/client_repository.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/stock_movement_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../widgets/common/app_scaffold.dart';

// Reads a CSV file's contents, tolerating files that aren't valid UTF-8
// (e.g. exported from Excel as "CSV (Comma delimited)", which is typically
// Windows-1252 / Latin-1). Falls back to Latin-1 and strips a UTF-8 BOM.
Future<String> _readCsvFile(File file) async {
  final bytes = await file.readAsBytes();
  try {
    final text = utf8.decode(bytes);
    return text.startsWith('﻿') ? text.substring(1) : text;
  } catch (_) {
    return latin1.decode(bytes);
  }
}

class CsvImportScreen extends StatelessWidget {
  const CsvImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Import CSV',
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Supplier Products'),
                Tab(text: 'Clients'),
                Tab(text: 'Bulk Clear Restock'),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _SupplierProductImportTab(),
                  _ClientImportTab(),
                  _BulkClearImportTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Supplier Products tab
// ════════════════════════════════════════════════════════════════════════════

class _SupplierProductImportTab extends ConsumerStatefulWidget {
  const _SupplierProductImportTab();

  @override
  ConsumerState<_SupplierProductImportTab> createState() =>
      _SupplierProductImportTabState();
}

class _SupplierProductImportTabState
    extends ConsumerState<_SupplierProductImportTab> {
  final _pathCtrl = TextEditingController();
  bool _importing = false;
  final List<_LogEntry> _log = [];
  _ProductImportSummary? _summary;
  DateTime _selectedDate = DateTime.now();

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
      final content = await _readCsvFile(file);
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

      final supplierRepo       = ref.read(supplierRepositoryProvider);
      final productRepo        = ref.read(productRepositoryProvider);
      final inventoryRepo      = ref.read(inventoryRepositoryProvider);
      final stockMovementRepo  = ref.read(stockMovementRepositoryProvider);
      final importDate         = _selectedDate;

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
            if (delta != 0) {
              await stockMovementRepo.save(StockMovement(
                id: const Uuid().v4(),
                productId: productId,
                movementType: delta > 0 ? 'in' : 'out',
                quantityPieces: delta.abs(),
                referenceDate: importDate,
                comments: 'CSV import',
                createdAt: DateTime.now(),
              ));
            }
            inventoryUpdated++;
          }
        } catch (e) {
          _addLog('Inventory row ${i + 2} ($productName): $e',
              level: _LogLevel.error);
          errors++;
        }
      }

      setState(() {
        _summary = _ProductImportSummary(
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Reference date ──────────────────────────────────────────────
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Reference Date',
                suffixIcon: Icon(Icons.calendar_today, size: 18),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              child: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
            ),
          ),
          const SizedBox(height: 10),

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
          if (_summary != null) _ProductSummaryCard(summary: _summary!),

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
    );
  }
}

// ── Summary card (Supplier Products) ──────────────────────────────────────────

class _ProductImportSummary {
  final int suppliersCreated;
  final int productsCreated;
  final int inventoryUpdated;
  final int skipped;
  final int errors;

  const _ProductImportSummary({
    required this.suppliersCreated,
    required this.productsCreated,
    required this.inventoryUpdated,
    required this.skipped,
    required this.errors,
  });
}

class _ProductSummaryCard extends StatelessWidget {
  final _ProductImportSummary summary;
  const _ProductSummaryCard({required this.summary});

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

// ════════════════════════════════════════════════════════════════════════════
// Clients tab
// ════════════════════════════════════════════════════════════════════════════

class _ClientImportTab extends ConsumerStatefulWidget {
  const _ClientImportTab();

  @override
  ConsumerState<_ClientImportTab> createState() => _ClientImportTabState();
}

class _ClientImportTabState extends ConsumerState<_ClientImportTab> {
  final _pathCtrl = TextEditingController();
  bool _importing = false;
  final List<_LogEntry> _log = [];
  _ClientImportSummary? _summary;

  @override
  void initState() {
    super.initState();
    final home = Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '';
    _pathCtrl.text = '$home\\Desktop\\VSM_Daily_Route_Plan_Master.csv';
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

  String _field(List<String> row, int col) =>
      col >= 0 && row.length > col ? row[col].trim() : '';

  // Finds the column index whose header matches any of [names]
  // (case-insensitive, ignoring extra whitespace).
  int _findColumn(List<String> header, List<String> names) {
    final normalized = header
        .map((h) => h.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim())
        .toList();
    for (final name in names) {
      final target =
          name.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
      final idx = normalized.indexOf(target);
      if (idx != -1) return idx;
    }
    return -1;
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
      final content = await _readCsvFile(file);
      final allRows = _parseCsv(content);

      if (allRows.isEmpty) {
        _addLog('File is empty.', level: _LogLevel.error);
        return;
      }

      final header = allRows.first;
      _addLog('${allRows.length - 1} data rows  |  ${header.length} columns');

      final nameCol = _findColumn(header, ['CUSTOMER NAME']);
      final barangayCol = _findColumn(header, ['Barangay']);
      final cityCol =
          _findColumn(header, ['Municipality/City', 'Municipality / City']);
      final provinceCol = _findColumn(header, ['Province']);
      final contactCol = _findColumn(header, [
        'TELEPHONE / CONTACT NUMBER',
        'TELEPHONE/CONTACT NUMBER',
        'CONTACT NUMBER',
        'TELEPHONE',
      ]);

      if (nameCol == -1) {
        _addLog('Could not find "CUSTOMER NAME" column.',
            level: _LogLevel.error);
        return;
      }
      _addLog('Mapped columns — Name: ${nameCol + 1}, '
          'Barangay: ${barangayCol + 1}, City: ${cityCol + 1}, '
          'Province: ${provinceCol + 1}, Contact: ${contactCol + 1}');

      final dataRows = allRows.skip(1).toList();
      final clientRepo = ref.read(clientRepositoryProvider);
      final existing = await clientRepo.getAll();
      final byName = <String, Client>{
        for (final c in existing) c.name.toLowerCase(): c,
      };

      int created = 0;
      int updated = 0;
      int skipped = 0;
      int errors = 0;

      for (int i = 0; i < dataRows.length; i++) {
        final row = dataRows[i];
        final name = _field(row, nameCol);
        if (name.isEmpty) {
          skipped++;
          continue;
        }

        final addressParts = [
          _field(row, barangayCol),
          _field(row, cityCol),
          _field(row, provinceCol),
        ].where((s) => s.isNotEmpty).toList();
        final address = addressParts.isEmpty ? null : addressParts.join(', ');
        final contactRaw = _field(row, contactCol);
        final contact = contactRaw.isEmpty ? null : contactRaw;

        try {
          final key = name.toLowerCase();
          final existingClient = byName[key];
          if (existingClient != null) {
            final updatedClient = existingClient.copyWith(
              contact: contact,
              address: address,
            );
            await clientRepo.upsert(updatedClient);
            byName[key] = updatedClient;
            updated++;
          } else {
            final newClient = Client(
              id: const Uuid().v4(),
              name: name,
              contact: contact,
              address: address,
              createdAt: DateTime.now(),
            );
            await clientRepo.upsert(newClient);
            byName[key] = newClient;
            created++;
          }
        } catch (e) {
          _addLog('Row ${i + 2} ($name): $e', level: _LogLevel.error);
          errors++;
        }
      }

      ref.invalidate(clientsListProvider);

      setState(() {
        _summary = _ClientImportSummary(
          created: created,
          updated: updated,
          skipped: skipped,
          errors: errors,
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            'Maps CUSTOMER NAME -> name; Barangay, Municipality/City, '
            'Province -> address (comma-separated); '
            'TELEPHONE / CONTACT NUMBER -> contact number. '
            'Existing clients are matched by name and updated.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),

          if (_summary != null) _ClientSummaryCard(summary: _summary!),

          const Divider(height: 20),

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
                              _LogLevel.error => Colors.red.shade700,
                              _LogLevel.warn => Colors.orange.shade800,
                              _LogLevel.success => Colors.green.shade700,
                              _LogLevel.info => null,
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Summary card (Clients) ─────────────────────────────────────────────────────

class _ClientImportSummary {
  final int created;
  final int updated;
  final int skipped;
  final int errors;

  const _ClientImportSummary({
    required this.created,
    required this.updated,
    required this.skipped,
    required this.errors,
  });
}

class _ClientSummaryCard extends StatelessWidget {
  final _ClientImportSummary summary;
  const _ClientSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Stat('Created', summary.created, Colors.green.shade700),
            _Stat('Updated', summary.updated, Colors.blue.shade700),
            _Stat('Skipped', summary.skipped, Colors.grey),
            _Stat('Errors', summary.errors, Colors.red.shade700),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Bulk Clear Restock tab
// ════════════════════════════════════════════════════════════════════════════

class _BulkClearImportTab extends ConsumerStatefulWidget {
  const _BulkClearImportTab();

  @override
  ConsumerState<_BulkClearImportTab> createState() =>
      _BulkClearImportTabState();
}

class _BulkClearImportTabState extends ConsumerState<_BulkClearImportTab> {
  final _pathCtrl = TextEditingController();
  bool _importing = false;
  final List<_LogEntry> _log = [];
  _BulkClearImportSummary? _summary;

  @override
  void initState() {
    super.initState();
    final home = Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '';
    final dateStr = DateTime.now().toIso8601String().substring(0, 10);
    _pathCtrl.text = '$home\\Desktop\\bulk_clear_$dateStr.csv';
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

  String _field(List<String> row, int col) =>
      row.length > col ? row[col].trim() : '';

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
      final content = await _readCsvFile(file);
      final allRows = _parseCsv(content);

      if (allRows.isEmpty) {
        _addLog('File is empty.', level: _LogLevel.error);
        return;
      }

      final header = allRows.first;
      _addLog('${allRows.length - 1} data rows  |  ${header.length} columns');

      final dataRows = allRows.skip(1).toList();

      final productRepo   = ref.read(productRepositoryProvider);
      final inventoryRepo = ref.read(inventoryRepositoryProvider);
      final stockMovementRepo = ref.read(stockMovementRepositoryProvider);

      final existingProducts = await productRepo.getAll();
      final productByName = <String, Product>{
        for (final p in existingProducts) p.name.toLowerCase(): p,
      };

      final now = DateTime.now();
      int restocked = 0;
      int skipped   = 0;
      int errors    = 0;

      for (int i = 0; i < dataRows.length; i++) {
        final row = dataRows[i];
        final productName = _field(row, 0);
        if (productName.isEmpty) {
          skipped++;
          continue;
        }

        final product = productByName[productName.toLowerCase()];
        if (product == null) {
          _addLog('Row ${i + 2}: product not found: "$productName"',
              level: _LogLevel.warn);
          skipped++;
          continue;
        }

        final boxes = _fieldInt(row, 1);
        final pcs   = _fieldInt(row, 2);
        final quantity = boxes * product.piecesPerBox + pcs;
        if (quantity <= 0) {
          skipped++;
          continue;
        }

        try {
          await inventoryRepo.adjust(
              productId: product.id, deltaPieces: quantity);
          await stockMovementRepo.save(StockMovement(
            id: const Uuid().v4(),
            productId: product.id,
            movementType: 'in',
            quantityPieces: quantity,
            referenceDate: now,
            comments: 'Bulk clear restock import',
            createdAt: now,
          ));
          restocked++;
        } catch (e) {
          _addLog('Row ${i + 2} ($productName): $e', level: _LogLevel.error);
          errors++;
        }
      }

      ref.invalidate(inventoryListProvider);

      setState(() {
        _summary = _BulkClearImportSummary(
          restocked: restocked,
          skipped: skipped,
          errors: errors,
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            'Expected columns: A=Product Name  B=Boxes  C=Pcs. '
            'Adds (Boxes × pieces-per-box + Pcs) back into inventory for the '
            'matching product and records a "Bulk clear restock import" '
            'stock-in movement. Products not found by name are skipped.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),

          if (_summary != null) _BulkClearSummaryCard(summary: _summary!),

          const Divider(height: 20),

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
                              _LogLevel.error => Colors.red.shade700,
                              _LogLevel.warn => Colors.orange.shade800,
                              _LogLevel.success => Colors.green.shade700,
                              _LogLevel.info => null,
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Summary card (Bulk Clear Restock) ──────────────────────────────────────────

class _BulkClearImportSummary {
  final int restocked;
  final int skipped;
  final int errors;

  const _BulkClearImportSummary({
    required this.restocked,
    required this.skipped,
    required this.errors,
  });
}

class _BulkClearSummaryCard extends StatelessWidget {
  final _BulkClearImportSummary summary;
  const _BulkClearSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Stat('Restocked', summary.restocked, Colors.teal.shade700),
            _Stat('Skipped',   summary.skipped,    Colors.grey),
            _Stat('Errors',    summary.errors,     Colors.red.shade700),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets/helpers ─────────────────────────────────────────────────────

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

enum _LogLevel { info, success, warn, error }

class _LogEntry {
  final String message;
  final _LogLevel level;
  const _LogEntry(this.message, this.level);
}
