import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/database/local_db.dart' hide VanStock;
import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import '../models/van_stock.dart';
import 'base_repository.dart';
import 'inventory_repository.dart';

class VanStockRepository extends BaseRepository {
  final InventoryRepository inventoryRepo;

  VanStockRepository({
    required super.db,
    required super.connectivity,
    required super.syncService,
    required this.inventoryRepo,
  });

  Future<List<VanStock>> getAll({DateTime? date}) async {
    if (isOnline) {
      var q = Supabase.instance.client
          .from('van_stocks')
          .select()
          .order('date', ascending: false);
      if (date != null) {
        final start = DateTime(date.year, date.month, date.day);
        final end = start.add(const Duration(days: 1));
        q = Supabase.instance.client
            .from('van_stocks')
            .select()
            .gte('date', start.toIso8601String())
            .lt('date', end.toIso8601String())
            .order('date', ascending: false);
      }
      return ((await q) as List).map((j) => VanStock.fromJson(j)).toList();
    }
    final rows = await (db.select(db.vanStocks)
          ..orderBy([(t) => drift.OrderingTerm.desc(t.date)]))
        .get();
    return rows
        .map((r) => VanStock(
              id: r.id,
              productId: r.productId,
              type: r.type,
              quantityPieces: r.quantityPieces,
              date: r.date,
              notes: r.notes,
            ))
        .toList();
  }

  /// Returns current van stock per product: sum(out) - sum(in) in pieces.
  Future<Map<String, int>> getCurrentVanStock() async {
    final all = await getAll();
    final balance = <String, int>{};
    for (final tx in all) {
      final current = balance[tx.productId] ?? 0;
      balance[tx.productId] =
          tx.isOut ? current + tx.quantityPieces : current - tx.quantityPieces;
    }
    return balance;
  }

  Future<void> record({
    required String productId,
    required String type, // 'out' | 'in'
    required int quantityPieces,
    String? notes,
  }) async {
    final tx = VanStock(
      id: const Uuid().v4(),
      productId: productId,
      type: type,
      quantityPieces: quantityPieces,
      date: DateTime.now(),
      notes: notes,
    );
    final payload = tx.toJson();
    if (isOnline) {
      await Supabase.instance.client.from('van_stocks').insert(payload);
    } else {
      await syncService.enqueue(
        tableName: 'van_stocks',
        recordId: tx.id,
        operation: 'insert',
        payload: payload,
      );
    }
    await trySaveLocal(() => db
        .into(db.vanStocks)
        .insertOnConflictUpdate(VanStocksCompanion(
          id: drift.Value(tx.id),
          productId: drift.Value(tx.productId),
          type: drift.Value(tx.type),
          quantityPieces: drift.Value(tx.quantityPieces),
          date: drift.Value(tx.date),
          notes: drift.Value(tx.notes),
        )));

    // Adjust main inventory: out = deduct, in = restore
    await inventoryRepo.adjust(
      productId: productId,
      deltaPieces: type == 'out' ? -quantityPieces : quantityPieces,
    );
  }
}

final vanStockRepositoryProvider = Provider<VanStockRepository>((ref) {
  return VanStockRepository(
    db: ref.watch(localDatabaseProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    syncService: ref.watch(syncServiceProvider),
    inventoryRepo: ref.watch(inventoryRepositoryProvider),
  );
});
