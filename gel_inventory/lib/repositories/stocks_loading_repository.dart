import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/database/local_db.dart' hide StocksLoadingItem;
import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import '../models/stocks_loading.dart';
import 'base_repository.dart';

export '../core/database/local_db.dart' show StocksLoading;

class StocksLoadingItemInput {
  final String? productCode;
  final String productName;
  final String supplierName;
  final int quantityPieces;
  final int piecesPerBox;

  const StocksLoadingItemInput({
    this.productCode,
    required this.productName,
    required this.supplierName,
    required this.quantityPieces,
    required this.piecesPerBox,
  });
}

class StocksLoadingRepository extends BaseRepository {
  StocksLoadingRepository({
    required super.db,
    required super.connectivity,
    required super.syncService,
  });

  // ── Queries ────────────────────────────────────────────────────────────────

  /// All headers, newest first.
  Future<List<StocksLoading>> getAll() async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('stocks_loadings')
          .select()
          .order('imported_at', ascending: false);
      for (final row in (data as List)) {
        await trySaveLocal(() => _saveLocalHeader(row as Map<String, dynamic>));
      }
    }
    return (db.select(db.stocksLoadings)
          ..orderBy([(t) => drift.OrderingTerm.desc(t.importedAt)]))
        .get();
  }

  /// Headers for a given calendar [date], newest first.
  Future<List<StocksLoading>> getByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    if (isOnline) {
      final data = await Supabase.instance.client
          .from('stocks_loadings')
          .select()
          .gte('loading_date', start.toIso8601String())
          .lt('loading_date', end.toIso8601String())
          .order('imported_at', ascending: false);
      for (final row in (data as List)) {
        await trySaveLocal(() => _saveLocalHeader(row as Map<String, dynamic>));
      }
    }

    return (db.select(db.stocksLoadings)
          ..where((t) =>
              t.loadingDate.isBiggerOrEqualValue(start) &
              t.loadingDate.isSmallerThanValue(end))
          ..orderBy([(t) => drift.OrderingTerm.desc(t.importedAt)]))
        .get();
  }

  /// Builds a [StocksLoadingRecord] (header + items) for display.
  Future<StocksLoadingRecord> getRecord(StocksLoading header) async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('stocks_loading_items')
          .select()
          .eq('stocks_loading_id', header.id);
      for (final row in (data as List)) {
        await trySaveLocal(() => _saveLocalItem(row as Map<String, dynamic>));
      }
    }

    final rawItems = await (db.select(db.stocksLoadingItems)
          ..where((t) => t.stocksLoadingId.equals(header.id)))
        .get();

    return StocksLoadingRecord(
      id: header.id,
      loadingDate: header.loadingDate,
      importedAt: header.importedAt,
      items: rawItems
          .map((i) => StocksLoadingEntry(
                id: i.id,
                stocksLoadingId: i.stocksLoadingId,
                productCode: i.productCode,
                productName: i.productName,
                supplierName: i.supplierName,
                quantityPieces: i.quantityPieces,
                piecesPerBox: i.piecesPerBox,
              ))
          .toList(),
    );
  }

  // ── Mutations ──────────────────────────────────────────────────────────────

  /// Saves a new loading record (header + items). Returns the new id.
  ///
  /// Local DB is written first so the layout view is always populated,
  /// regardless of Supabase availability. Supabase sync falls back to the
  /// sync_queue if the remote insert fails (e.g. tables not yet created).
  Future<String> save({
    required DateTime loadingDate,
    required List<StocksLoadingItemInput> items,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();

    // ── 1. Write locally first — layout depends on this ──────────────────────
    await db.into(db.stocksLoadings).insertOnConflictUpdate(
          StocksLoadingsCompanion(
            id: drift.Value(id),
            loadingDate: drift.Value(loadingDate),
            importedAt: drift.Value(now),
          ),
        );

    final itemIds = <String>[];
    for (final item in items) {
      final itemId = const Uuid().v4();
      itemIds.add(itemId);
      await db.into(db.stocksLoadingItems).insertOnConflictUpdate(
            StocksLoadingItemsCompanion(
              id: drift.Value(itemId),
              stocksLoadingId: drift.Value(id),
              productCode: drift.Value(item.productCode),
              productName: drift.Value(item.productName),
              supplierName: drift.Value(item.supplierName),
              quantityPieces: drift.Value(item.quantityPieces),
              piecesPerBox: drift.Value(item.piecesPerBox),
            ),
          );
    }

    // ── 2. Sync to Supabase; fall back to sync_queue on any failure ──────────
    final headerPayload = {
      'id': id,
      'loading_date': loadingDate.toIso8601String(),
      'imported_at': now.toIso8601String(),
    };

    if (isOnline) {
      try {
        await Supabase.instance.client
            .from('stocks_loadings')
            .insert(headerPayload);
        for (var i = 0; i < items.length; i++) {
          await Supabase.instance.client
              .from('stocks_loading_items')
              .insert({
            'id': itemIds[i],
            'stocks_loading_id': id,
            'product_code': items[i].productCode,
            'product_name': items[i].productName,
            'supplier_name': items[i].supplierName,
            'quantity_pieces': items[i].quantityPieces,
            'pieces_per_box': items[i].piecesPerBox,
          });
        }
      } catch (_) {
        // Remote insert failed — enqueue for next sync cycle.
        await syncService.enqueue(
          tableName: 'stocks_loadings',
          recordId: id,
          operation: 'insert',
          payload: headerPayload,
        );
        for (var i = 0; i < items.length; i++) {
          await syncService.enqueue(
            tableName: 'stocks_loading_items',
            recordId: itemIds[i],
            operation: 'insert',
            payload: {
              'id': itemIds[i],
              'stocks_loading_id': id,
              'product_code': items[i].productCode,
              'product_name': items[i].productName,
              'supplier_name': items[i].supplierName,
              'quantity_pieces': items[i].quantityPieces,
              'pieces_per_box': items[i].piecesPerBox,
            },
          );
        }
      }
    } else {
      await syncService.enqueue(
        tableName: 'stocks_loadings',
        recordId: id,
        operation: 'insert',
        payload: headerPayload,
      );
      for (var i = 0; i < items.length; i++) {
        await syncService.enqueue(
          tableName: 'stocks_loading_items',
          recordId: itemIds[i],
          operation: 'insert',
          payload: {
            'id': itemIds[i],
            'stocks_loading_id': id,
            'product_code': items[i].productCode,
            'product_name': items[i].productName,
            'supplier_name': items[i].supplierName,
            'quantity_pieces': items[i].quantityPieces,
            'pieces_per_box': items[i].piecesPerBox,
          },
        );
      }
    }

    return id;
  }

  /// Deletes a loading record and all its items.
  Future<void> delete(String id) async {
    if (isOnline) {
      // ON DELETE CASCADE in Supabase handles items automatically.
      await Supabase.instance.client
          .from('stocks_loadings')
          .delete()
          .eq('id', id);
    } else {
      await syncService.enqueue(
        tableName: 'stocks_loadings',
        recordId: id,
        operation: 'delete',
        payload: {'id': id},
      );
    }
    // Always clean local regardless of connectivity.
    await (db.delete(db.stocksLoadingItems)
          ..where((t) => t.stocksLoadingId.equals(id)))
        .go();
    await (db.delete(db.stocksLoadings)..where((t) => t.id.equals(id))).go();
  }

  // ── Local cache helpers ────────────────────────────────────────────────────

  Future<void> _saveLocalHeader(Map<String, dynamic> row) async {
    await db.into(db.stocksLoadings).insertOnConflictUpdate(
          StocksLoadingsCompanion(
            id: drift.Value(row['id'] as String),
            loadingDate: drift.Value(
                DateTime.parse(row['loading_date'] as String).toLocal()),
            importedAt: drift.Value(
                DateTime.parse(row['imported_at'] as String).toLocal()),
          ),
        );
  }

  Future<void> _saveLocalItem(Map<String, dynamic> row) async {
    await db.into(db.stocksLoadingItems).insertOnConflictUpdate(
          StocksLoadingItemsCompanion(
            id: drift.Value(row['id'] as String),
            stocksLoadingId: drift.Value(row['stocks_loading_id'] as String),
            productCode: drift.Value(row['product_code'] as String?),
            productName: drift.Value(row['product_name'] as String),
            supplierName: drift.Value(row['supplier_name'] as String),
            quantityPieces: drift.Value(row['quantity_pieces'] as int),
            piecesPerBox: drift.Value(row['pieces_per_box'] as int),
          ),
        );
  }
}

final stocksLoadingRepositoryProvider =
    Provider<StocksLoadingRepository>((ref) {
  return StocksLoadingRepository(
    db: ref.watch(localDatabaseProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    syncService: ref.watch(syncServiceProvider),
  );
});
