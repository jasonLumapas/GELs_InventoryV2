import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import 'base_repository.dart';

/// Stores each product's opening quantity for a report date. Quantities are
/// kept in pieces so a later pack-size change does not rewrite balances.
class InventoryOpeningBalanceRepository extends BaseRepository {
  InventoryOpeningBalanceRepository({
    required super.db,
    required super.connectivity,
    required super.syncService,
  });

  Future<Map<String, int>> getOrCreateForDate({
    required DateTime reportDate,
    required Map<String, int> calculatedOpening,
  }) async {
    final day = DateTime(reportDate.year, reportDate.month, reportDate.day);
    final dateKey = _dateKey(day);

    // A future report date is a projection. Keep it live until the day starts,
    // unless the previous day's ending has already been carried into it.
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final isFutureDate = day.isAfter(todayStart);

    final localRows = await db
        .customSelect(
          'SELECT product_id, quantity_pieces '
          'FROM inventory_opening_balances WHERE report_date = ?',
          variables: [drift.Variable.withString(dateKey)],
        )
        .get();
    final local = <String, int>{};
    for (final row in localRows) {
      local[row.read<String>('product_id')] = row.read<int>('quantity_pieces');
    }

    if (isOnline) {
      try {
        final remoteRows = await Supabase.instance.client
            .from('inventory_opening_balances')
            .select('id, product_id, report_date, quantity_pieces, created_at')
            .eq('report_date', dateKey);
        var remote = _toQuantities(remoteRows as List);

        final candidates = <String, int>{};
        for (final entry in calculatedOpening.entries) {
          if (!remote.containsKey(entry.key)) {
            final localSnapshot = local[entry.key];
            if (localSnapshot != null) {
              candidates[entry.key] = localSnapshot;
            } else if (!isFutureDate) {
              candidates[entry.key] = entry.value;
            }
          }
        }

        if (candidates.isNotEmpty) {
          final now = DateTime.now().toIso8601String();
          final payloads = candidates.entries
              .map(
                (entry) => _payload(
                  productId: entry.key,
                  dateKey: dateKey,
                  quantityPieces: entry.value,
                  createdAt: now,
                ),
              )
              .toList();

          // Ignore conflicts so a second device cannot replace an opening
          // value that another device already persisted for this date.
          await Supabase.instance.client
              .from('inventory_opening_balances')
              .upsert(payloads, onConflict: 'id', ignoreDuplicates: true);

          final refreshed = await Supabase.instance.client
              .from('inventory_opening_balances')
              .select(
                'id, product_id, report_date, quantity_pieces, created_at',
              )
              .eq('report_date', dateKey);
          remote = _toQuantities(refreshed as List);
        }

        final result = <String, int>{};
        for (final entry in calculatedOpening.entries) {
          final savedQuantity = remote[entry.key] ?? candidates[entry.key];
          result[entry.key] = savedQuantity ?? entry.value;
          if (savedQuantity != null) {
            await _saveLocal(
              productId: entry.key,
              dateKey: dateKey,
              quantityPieces: savedQuantity,
              createdAt: DateTime.now(),
            );
          }
        }
        return result;
      } catch (e) {
        debugPrint(
          'Opening balance Supabase request failed; using local cache: $e',
        );
      }
    }

    final result = <String, int>{};
    for (final entry in calculatedOpening.entries) {
      final existing = local[entry.key];
      final quantity = existing ?? entry.value;
      result[entry.key] = quantity;
      if (existing == null && !isFutureDate) {
        final persistedQuantity = await _saveLocalIfAbsent(
          productId: entry.key,
          dateKey: dateKey,
          quantityPieces: quantity,
          createdAt: DateTime.now(),
        );
        result[entry.key] = persistedQuantity;
        await syncService.enqueue(
          tableName: 'inventory_opening_balances',
          recordId: _id(entry.key, dateKey),
          operation: 'insert_if_absent',
          payload: _payload(
            productId: entry.key,
            dateKey: dateKey,
            quantityPieces: persistedQuantity,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
      }
    }
    return result;
  }

  /// Carries a day's calculated closing quantity into the following day's
  /// opening snapshot. This deliberately replaces any earlier projection for
  /// that next-day opening.
  Future<void> saveNextDayOpeningFromEnding({
    required DateTime reportDate,
    required Map<String, int> endingByProductId,
  }) async {
    final day = DateTime(reportDate.year, reportDate.month, reportDate.day);
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    if (day.isAfter(todayStart) || endingByProductId.isEmpty) return;

    final nextDay = day.add(const Duration(days: 1));
    final nextDateKey = _dateKey(nextDay);
    final createdAt = DateTime.now();
    final payloads = endingByProductId.entries
        .map(
          (entry) => _payload(
            productId: entry.key,
            dateKey: nextDateKey,
            quantityPieces: entry.value,
            createdAt: createdAt.toIso8601String(),
          ),
        )
        .toList();

    var savedRemotely = false;
    if (isOnline) {
      try {
        await Supabase.instance.client
            .from('inventory_opening_balances')
            .upsert(payloads, onConflict: 'id');
        savedRemotely = true;
      } catch (e) {
        debugPrint('Saving next-day opening to Supabase failed: $e');
      }
    }

    for (final entry in endingByProductId.entries) {
      await _saveLocal(
        productId: entry.key,
        dateKey: nextDateKey,
        quantityPieces: entry.value,
        createdAt: createdAt,
      );
      if (!savedRemotely) {
        await syncService.enqueue(
          tableName: 'inventory_opening_balances',
          recordId: _id(entry.key, nextDateKey),
          operation: 'insert',
          payload: _payload(
            productId: entry.key,
            dateKey: nextDateKey,
            quantityPieces: entry.value,
            createdAt: createdAt.toIso8601String(),
          ),
        );
      }
    }
  }

  Map<String, int> _toQuantities(List<dynamic> rows) {
    final result = <String, int>{};
    for (final row in rows) {
      final data = Map<String, dynamic>.from(row as Map);
      result[data['product_id'] as String] = (data['quantity_pieces'] as num)
          .toInt();
    }
    return result;
  }

  Future<void> _saveLocal({
    required String productId,
    required String dateKey,
    required int quantityPieces,
    required DateTime createdAt,
  }) async {
    await db.customInsert(
      '''
      INSERT INTO inventory_opening_balances
        (id, product_id, report_date, quantity_pieces, created_at)
      VALUES (?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
        quantity_pieces = excluded.quantity_pieces
      ''',
      variables: [
        drift.Variable.withString(_id(productId, dateKey)),
        drift.Variable.withString(productId),
        drift.Variable.withString(dateKey),
        drift.Variable.withInt(quantityPieces),
        drift.Variable.withString(createdAt.toIso8601String()),
      ],
    );
  }

  Future<int> _saveLocalIfAbsent({
    required String productId,
    required String dateKey,
    required int quantityPieces,
    required DateTime createdAt,
  }) async {
    await db.customInsert(
      '''
      INSERT OR IGNORE INTO inventory_opening_balances
        (id, product_id, report_date, quantity_pieces, created_at)
      VALUES (?, ?, ?, ?, ?)
      ''',
      variables: [
        drift.Variable.withString(_id(productId, dateKey)),
        drift.Variable.withString(productId),
        drift.Variable.withString(dateKey),
        drift.Variable.withInt(quantityPieces),
        drift.Variable.withString(createdAt.toIso8601String()),
      ],
    );
    final rows = await db
        .customSelect(
          'SELECT quantity_pieces FROM inventory_opening_balances WHERE id = ?',
          variables: [drift.Variable.withString(_id(productId, dateKey))],
        )
        .get();
    return rows.single.read<int>('quantity_pieces');
  }

  Map<String, dynamic> _payload({
    required String productId,
    required String dateKey,
    required int quantityPieces,
    required String createdAt,
  }) => {
    'id': _id(productId, dateKey),
    'product_id': productId,
    'report_date': dateKey,
    'quantity_pieces': quantityPieces,
    'created_at': createdAt,
  };

  String _id(String productId, String dateKey) =>
      'opening_${productId}_$dateKey';

  String _dateKey(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';
}

final inventoryOpeningBalanceRepositoryProvider =
    Provider<InventoryOpeningBalanceRepository>((ref) {
      return InventoryOpeningBalanceRepository(
        db: ref.watch(localDatabaseProvider),
        connectivity: ref.watch(connectivityServiceProvider),
        syncService: ref.watch(syncServiceProvider),
      );
    });
