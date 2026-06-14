import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/database/local_db.dart' hide StockMovement;
import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import '../models/stock_movement.dart';
import 'base_repository.dart';

class StockMovementRepository extends BaseRepository {
  StockMovementRepository({
    required super.db,
    required super.connectivity,
    required super.syncService,
  });

  Future<void> save(StockMovement movement) async {
    final payload = movement.toJson();
    if (isOnline) {
      try {
        await Supabase.instance.client
            .from('stock_movements')
            .insert(payload);
      } catch (e) {
        debugPrint('stock_movements Supabase insert failed: $e. Falling back to local save.');
      }
    } else {
      await syncService.enqueue(
        tableName: 'stock_movements',
        recordId: movement.id,
        operation: 'insert',
        payload: payload,
      );
    }
    await trySaveLocal(() => db.into(db.stockMovements).insert(
          StockMovementsCompanion(
            id: drift.Value(movement.id),
            productId: drift.Value(movement.productId),
            movementType: drift.Value(movement.movementType),
            quantityPieces: drift.Value(movement.quantityPieces),
            referenceDate: drift.Value(movement.referenceDate),
            invoiceNumber: drift.Value(movement.invoiceNumber),
            comments: drift.Value(movement.comments),
            createdAt: drift.Value(movement.createdAt),
          ),
        ));
  }

  Future<void> deleteById(String id) async {
    if (isOnline) {
      try {
        await Supabase.instance.client
            .from('stock_movements')
            .delete()
            .eq('id', id);
      } catch (e) {
        debugPrint('stock_movements Supabase delete failed: $e. Falling back to local.');
      }
    } else {
      await syncService.enqueue(
        tableName: 'stock_movements',
        recordId: id,
        operation: 'delete',
        payload: {'id': id},
      );
    }
    await trySaveLocal(() => (db.delete(db.stockMovements)
          ..where((t) => t.id.equals(id)))
        .go());
  }

  Future<void> deleteByInvoiceNumber(String invoiceNumber) async {
    if (isOnline) {
      try {
        await Supabase.instance.client
            .from('stock_movements')
            .delete()
            .eq('invoice_number', invoiceNumber);
      } catch (e) {
        debugPrint('stock_movements Supabase delete by invoice_number failed: $e. Falling back to local.');
      }
    } else {
      final rows = await (db.select(db.stockMovements)
            ..where((t) => t.invoiceNumber.equals(invoiceNumber)))
          .get();
      for (final r in rows) {
        await syncService.enqueue(
          tableName: 'stock_movements',
          recordId: r.id,
          operation: 'delete',
          payload: {'id': r.id},
        );
      }
    }
    await trySaveLocal(() => (db.delete(db.stockMovements)
          ..where((t) => t.invoiceNumber.equals(invoiceNumber)))
        .go());
  }

  Future<void> update(StockMovement movement) async {
    final payload = movement.toJson();
    if (isOnline) {
      try {
        await Supabase.instance.client
            .from('stock_movements')
            .update(payload)
            .eq('id', movement.id);
      } catch (e) {
        debugPrint('stock_movements Supabase update failed: $e. Falling back to local save.');
      }
    } else {
      await syncService.enqueue(
        tableName: 'stock_movements',
        recordId: movement.id,
        operation: 'update',
        payload: payload,
      );
    }
    await trySaveLocal(() => (db.update(db.stockMovements)
          ..where((t) => t.id.equals(movement.id)))
        .write(StockMovementsCompanion(
          movementType: drift.Value(movement.movementType),
          quantityPieces: drift.Value(movement.quantityPieces),
          referenceDate: drift.Value(movement.referenceDate),
          invoiceNumber: drift.Value(movement.invoiceNumber),
          comments: drift.Value(movement.comments),
        )));
  }

  Future<Map<String, int>> _sumForTypeAndDate(
      String movementType, DateTime date) async {
    final dayStr = '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}'; // 'YYYY-MM-DD'
    final totals = <String, int>{};

    debugPrint('sumForTypeAndDate($movementType): filtering for date=$dayStr isOnline=$isOnline');

    if (isOnline) {
      try {
        final data = await Supabase.instance.client
            .from('stock_movements')
            .select('product_id, quantity_pieces, reference_date')
            .eq('movement_type', movementType);
        debugPrint('sumForTypeAndDate($movementType): Supabase returned ${(data as List).length} rows');
        for (final m in data) {
          final refStr = m['reference_date'] as String?;
          if (refStr == null) continue;
          // Compare only the YYYY-MM-DD portion to avoid timezone shift issues.
          // Dart's toIso8601String() stores without tz; Supabase treats it as UTC,
          // which can shift the date by ±1 day when converted back to local time.
          final storedDay = refStr.length >= 10 ? refStr.substring(0, 10) : refStr;
          if (storedDay == dayStr) {
            final pid = m['product_id'] as String;
            final qty = (m['quantity_pieces'] as num).toInt();
            totals[pid] = (totals[pid] ?? 0) + qty;
          }
        }
        return totals;
      } catch (e) {
        debugPrint('sumForTypeAndDate($movementType) Supabase query failed: $e. Falling back to local.');
      }
    }

    // Offline or Supabase unavailable — read from local SQLite
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd   = dayStart.add(const Duration(days: 1));
    final rows = await (db.select(db.stockMovements)
          ..where((t) => t.movementType.equals(movementType)))
        .get();
    debugPrint('sumForTypeAndDate($movementType): local SQLite returned ${rows.length} rows');
    for (final r in rows) {
      final rd = r.referenceDate;
      if (rd != null && !rd.isBefore(dayStart) && rd.isBefore(dayEnd)) {
        totals[r.productId] = (totals[r.productId] ?? 0) + r.quantityPieces;
      }
    }
    return totals;
  }

  Future<Map<String, int>> _sumForTypeAndRange(
      String movementType, DateTime from, DateTime to) async {
    final fromStr = '${from.year}-'
        '${from.month.toString().padLeft(2, '0')}-'
        '${from.day.toString().padLeft(2, '0')}';
    final toStr = '${to.year}-'
        '${to.month.toString().padLeft(2, '0')}-'
        '${to.day.toString().padLeft(2, '0')}';
    final totals = <String, int>{};

    if (isOnline) {
      try {
        final data = await Supabase.instance.client
            .from('stock_movements')
            .select('product_id, quantity_pieces, reference_date')
            .eq('movement_type', movementType);
        for (final m in data as List) {
          final refStr = m['reference_date'] as String?;
          if (refStr == null) continue;
          final storedDay = refStr.length >= 10 ? refStr.substring(0, 10) : refStr;
          if (storedDay.compareTo(fromStr) >= 0 && storedDay.compareTo(toStr) < 0) {
            final pid = m['product_id'] as String;
            final qty = (m['quantity_pieces'] as num).toInt();
            totals[pid] = (totals[pid] ?? 0) + qty;
          }
        }
        return totals;
      } catch (e) {
        debugPrint('sumForTypeAndRange($movementType) Supabase failed: $e');
      }
    }

    final rows = await (db.select(db.stockMovements)
          ..where((t) => t.movementType.equals(movementType)))
        .get();
    for (final r in rows) {
      final rd = r.referenceDate;
      if (rd != null && !rd.isBefore(from) && rd.isBefore(to)) {
        totals[r.productId] = (totals[r.productId] ?? 0) + r.quantityPieces;
      }
    }
    return totals;
  }

  Future<Map<String, int>> sumInForDate(DateTime date) =>
      _sumForTypeAndDate('in', date);

  Future<Map<String, int>> sumInForRange(DateTime from, DateTime to) =>
      _sumForTypeAndRange('in', from, to);

  Future<Map<String, int>> sumOutForDate(DateTime date) =>
      _sumForTypeAndDate('out', date);

  Future<Map<String, int>> sumOutForRange(DateTime from, DateTime to) =>
      _sumForTypeAndRange('out', from, to);

  static bool _isBadOrder(String? invoiceNumber) =>
      invoiceNumber != null && invoiceNumber.startsWith('BO-');

  static bool _isBulkClear(String? comments) =>
      comments == 'Bulk clear all stock';

  /// Splits 'out' movements for [date] into (non-bad-order, bad-order,
  /// bulk-clear) totals per product, based on whether `invoice_number`
  /// starts with `BO-` or `comments` marks a bulk clear.
  Future<(Map<String, int>, Map<String, int>, Map<String, int>)> sumOutSplitForDate(
      DateTime date) async {
    final dayStr = '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final nonBO = <String, int>{};
    final bo = <String, int>{};
    final bulkClear = <String, int>{};

    if (isOnline) {
      try {
        final data = await Supabase.instance.client
            .from('stock_movements')
            .select('product_id, quantity_pieces, reference_date, invoice_number, comments')
            .eq('movement_type', 'out');
        for (final m in data as List) {
          final refStr = m['reference_date'] as String?;
          if (refStr == null) continue;
          final storedDay = refStr.length >= 10 ? refStr.substring(0, 10) : refStr;
          if (storedDay == dayStr) {
            final pid = m['product_id'] as String;
            final qty = (m['quantity_pieces'] as num).toInt();
            final target = _isBulkClear(m['comments'] as String?)
                ? bulkClear
                : (_isBadOrder(m['invoice_number'] as String?) ? bo : nonBO);
            target[pid] = (target[pid] ?? 0) + qty;
          }
        }
        return (nonBO, bo, bulkClear);
      } catch (e) {
        debugPrint('sumOutSplitForDate Supabase query failed: $e. Falling back to local.');
      }
    }

    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final rows = await (db.select(db.stockMovements)
          ..where((t) => t.movementType.equals('out')))
        .get();
    for (final r in rows) {
      final rd = r.referenceDate;
      if (rd != null && !rd.isBefore(dayStart) && rd.isBefore(dayEnd)) {
        final target = _isBulkClear(r.comments)
            ? bulkClear
            : (_isBadOrder(r.invoiceNumber) ? bo : nonBO);
        target[r.productId] = (target[r.productId] ?? 0) + r.quantityPieces;
      }
    }
    return (nonBO, bo, bulkClear);
  }

  /// Splits 'out' movements in [from, to) into (non-bad-order, bad-order,
  /// bulk-clear) totals per product, based on whether `invoice_number`
  /// starts with `BO-` or `comments` marks a bulk clear.
  Future<(Map<String, int>, Map<String, int>, Map<String, int>)> sumOutSplitForRange(
      DateTime from, DateTime to) async {
    final fromStr = '${from.year}-'
        '${from.month.toString().padLeft(2, '0')}-'
        '${from.day.toString().padLeft(2, '0')}';
    final toStr = '${to.year}-'
        '${to.month.toString().padLeft(2, '0')}-'
        '${to.day.toString().padLeft(2, '0')}';
    final nonBO = <String, int>{};
    final bo = <String, int>{};
    final bulkClear = <String, int>{};

    if (isOnline) {
      try {
        final data = await Supabase.instance.client
            .from('stock_movements')
            .select('product_id, quantity_pieces, reference_date, invoice_number, comments')
            .eq('movement_type', 'out');
        for (final m in data as List) {
          final refStr = m['reference_date'] as String?;
          if (refStr == null) continue;
          final storedDay = refStr.length >= 10 ? refStr.substring(0, 10) : refStr;
          if (storedDay.compareTo(fromStr) >= 0 && storedDay.compareTo(toStr) < 0) {
            final pid = m['product_id'] as String;
            final qty = (m['quantity_pieces'] as num).toInt();
            final target = _isBulkClear(m['comments'] as String?)
                ? bulkClear
                : (_isBadOrder(m['invoice_number'] as String?) ? bo : nonBO);
            target[pid] = (target[pid] ?? 0) + qty;
          }
        }
        return (nonBO, bo, bulkClear);
      } catch (e) {
        debugPrint('sumOutSplitForRange Supabase query failed: $e. Falling back to local.');
      }
    }

    final rows = await (db.select(db.stockMovements)
          ..where((t) => t.movementType.equals('out')))
        .get();
    for (final r in rows) {
      final rd = r.referenceDate;
      if (rd != null && !rd.isBefore(from) && rd.isBefore(to)) {
        final target = _isBulkClear(r.comments)
            ? bulkClear
            : (_isBadOrder(r.invoiceNumber) ? bo : nonBO);
        target[r.productId] = (target[r.productId] ?? 0) + r.quantityPieces;
      }
    }
    return (nonBO, bo, bulkClear);
  }

  Future<List<StockMovement>> getForProduct(String productId) async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('stock_movements')
          .select()
          .eq('product_id', productId)
          .order('created_at', ascending: false);
      return (data as List).map((e) => StockMovement.fromJson(e)).toList();
    }
    final rows = await (db.select(db.stockMovements)
          ..where((t) => t.productId.equals(productId))
          ..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows
        .map((r) => StockMovement(
              id: r.id,
              productId: r.productId,
              movementType: r.movementType,
              quantityPieces: r.quantityPieces,
              referenceDate: r.referenceDate,
              invoiceNumber: r.invoiceNumber,
              comments: r.comments,
              createdAt: r.createdAt,
            ))
        .toList();
  }
}

final stockMovementRepositoryProvider =
    Provider<StockMovementRepository>((ref) => StockMovementRepository(
          db: ref.watch(localDatabaseProvider),
          connectivity: ref.watch(connectivityServiceProvider),
          syncService: ref.watch(syncServiceProvider),
        ));
