import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/database/local_db.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import '../models/inventory_item.dart';
import 'base_repository.dart';

class InventoryRepository extends BaseRepository {
  InventoryRepository({
    required super.db,
    required super.connectivity,
    required super.syncService,
  });

  Future<List<InventoryItem>> getAll() async {
    if (isOnline) {
      final data = await Supabase.instance.client.from('inventory').select();
      final items =
          (data as List).map((j) => InventoryItem.fromJson(j)).toList();
      for (final item in items) {
        await _saveLocal(item);
      }
      return items;
    }
    final rows = await db.select(db.inventory).get();
    return rows
        .map((r) => InventoryItem(
              id: r.id,
              productId: r.productId,
              quantityPieces: r.quantityPieces,
              lastUpdated: r.lastUpdated,
            ))
        .toList();
  }

  Future<InventoryItem?> getByProductId(String productId) async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('inventory')
          .select()
          .eq('product_id', productId)
          .limit(1);
      if ((data as List).isEmpty) return null;
      return InventoryItem.fromJson(data.first);
    }
    final rows = await (db.select(db.inventory)
          ..where((t) => t.productId.equals(productId))
          ..limit(1))
        .get();
    if (rows.isEmpty) return null;
    final r = rows.first;
    return InventoryItem(
      id: r.id,
      productId: r.productId,
      quantityPieces: r.quantityPieces,
      lastUpdated: r.lastUpdated,
    );
  }

  Future<void> adjust({
    required String productId,
    required int deltaPieces,
  }) async {
    var item = await getByProductId(productId);
    final now = DateTime.now();

    if (item == null) {
      item = InventoryItem(
        id: const Uuid().v4(),
        productId: productId,
        quantityPieces: deltaPieces.clamp(0, 999999),
        lastUpdated: now,
      );
    } else {
      final newQty = (item.quantityPieces + deltaPieces).clamp(0, 999999);
      item = InventoryItem(
        id: item.id,
        productId: productId,
        quantityPieces: newQty,
        lastUpdated: now,
      );
    }

    final payload = item.toJson();
    if (isOnline) {
      await Supabase.instance.client.from('inventory').upsert(payload);
    } else {
      await syncService.enqueue(
        tableName: 'inventory',
        recordId: item.id,
        operation: 'insert',
        payload: payload,
      );
    }
    await _saveLocal(item);
  }

  Future<void> _saveLocal(InventoryItem item) async {
    await db.into(db.inventory).insertOnConflictUpdate(InventoryCompanion(
          id: drift.Value(item.id),
          productId: drift.Value(item.productId),
          quantityPieces: drift.Value(item.quantityPieces),
          lastUpdated: drift.Value(item.lastUpdated),
        ));
  }
}

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(
    db: ref.watch(localDatabaseProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    syncService: ref.watch(syncServiceProvider),
  );
});

final inventoryListProvider = FutureProvider<List<InventoryItem>>((ref) {
  return ref.watch(inventoryRepositoryProvider).getAll();
});
