import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/database/local_db.dart' hide BadOrder, BadOrderItem, StockMovement;
import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import '../models/bad_order.dart';
import '../models/bad_order_item.dart';
import '../models/stock_movement.dart';
import 'base_repository.dart';
import 'inventory_repository.dart';
import 'product_repository.dart';
import 'stock_movement_repository.dart';

class BadOrderRepository extends BaseRepository {
  final InventoryRepository inventoryRepo;
  final StockMovementRepository stockMovementRepo;
  final ProductRepository productRepo;

  BadOrderRepository({
    required super.db,
    required super.connectivity,
    required super.syncService,
    required this.inventoryRepo,
    required this.stockMovementRepo,
    required this.productRepo,
  });

  Future<List<BadOrder>> getAll() async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('bad_orders')
          .select()
          .order('created_at', ascending: false);
      return (data as List).map((j) => BadOrder.fromJson(j)).toList();
    }
    final rows = await (db.select(db.badOrders)
          ..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows
        .map((r) => BadOrder(
              id: r.id,
              clientId: r.clientId,
              date: r.date,
              type: r.type,
              notes: r.notes,
              createdAt: r.createdAt,
            ))
        .toList();
  }

  Future<List<BadOrderItem>> getItems(String badOrderId) async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('bad_order_items')
          .select()
          .eq('bad_order_id', badOrderId);
      return (data as List).map((j) => BadOrderItem.fromJson(j)).toList();
    }
    final rows = await (db.select(db.badOrderItems)
          ..where((t) => t.badOrderId.equals(badOrderId)))
        .get();
    return rows
        .map((r) => BadOrderItem(
              id: r.id,
              badOrderId: r.badOrderId,
              productId: r.productId,
              unitType: r.unitType,
              quantity: r.quantity,
            ))
        .toList();
  }

  /// Saves the bad order and its items.
  /// Returns: if type == 'return', restores inventory; 'bad_order' does not.
  Future<void> save({
    required BadOrder order,
    required List<BadOrderItem> items,
    required Map<String, int> piecesPerBoxByProduct,
  }) async {
    final orderPayload = order.toJson();
    if (isOnline) {
      await Supabase.instance.client.from('bad_orders').upsert(orderPayload);
    } else {
      await syncService.enqueue(
        tableName: 'bad_orders',
        recordId: order.id,
        operation: 'insert',
        payload: orderPayload,
      );
    }
    await trySaveLocal(() => db
        .into(db.badOrders)
        .insertOnConflictUpdate(BadOrdersCompanion(
          id: drift.Value(order.id),
          clientId: drift.Value(order.clientId),
          date: drift.Value(order.date),
          type: drift.Value(order.type),
          notes: drift.Value(order.notes),
          createdAt: drift.Value(order.createdAt),
        )));

    for (final item in items) {
      final itemPayload = item.toJson();
      if (isOnline) {
        await Supabase.instance.client
            .from('bad_order_items')
            .upsert(itemPayload);
      } else {
        await syncService.enqueue(
          tableName: 'bad_order_items',
          recordId: item.id,
          operation: 'insert',
          payload: itemPayload,
        );
      }
      await trySaveLocal(() => db
          .into(db.badOrderItems)
          .insertOnConflictUpdate(BadOrderItemsCompanion(
            id: drift.Value(item.id),
            badOrderId: drift.Value(item.badOrderId),
            productId: drift.Value(item.productId),
            unitType: drift.Value(item.unitType),
            quantity: drift.Value(item.quantity),
          )));

      final ppb = piecesPerBoxByProduct[item.productId] ?? 1;
      final pieces =
          item.unitType == 'box' ? item.quantity * ppb : item.quantity;

      if (order.isReturn) {
        // Returns restore inventory.
        await inventoryRepo.adjust(
            productId: item.productId, deltaPieces: pieces);
        await stockMovementRepo.save(StockMovement(
          id: const Uuid().v4(),
          productId: item.productId,
          movementType: 'in',
          quantityPieces: pieces,
          referenceDate: order.date,
          invoiceNumber: 'BO-${order.id}',
          comments: 'Return',
          createdAt: DateTime.now(),
        ));
      } else {
        // Bad orders deduct inventory (stock out).
        await inventoryRepo.adjust(
            productId: item.productId, deltaPieces: -pieces);
        await stockMovementRepo.save(StockMovement(
          id: const Uuid().v4(),
          productId: item.productId,
          movementType: 'out',
          quantityPieces: pieces,
          referenceDate: order.date,
          invoiceNumber: 'BO-${order.id}',
          comments: 'Bad order',
          createdAt: DateTime.now(),
        ));
      }
    }
  }

  /// Deletes the bad order/return and reverses its inventory effect.
  Future<void> delete(String id) async {
    final items = await getItems(id);
    if (items.isNotEmpty) {
      final order = (await getAll()).where((o) => o.id == id).firstOrNull;
      final products = await productRepo.getAll();
      final ppbMap = {for (final p in products) p.id: p.piecesPerBox};
      for (final item in items) {
        final ppb = ppbMap[item.productId] ?? 1;
        final pieces =
            item.unitType == 'box' ? item.quantity * ppb : item.quantity;
        // Reverse the original adjustment: returns added pieces back
        // (subtract them now), bad orders removed pieces (add them back).
        final reverseDelta = (order?.isReturn ?? false) ? -pieces : pieces;
        await inventoryRepo.adjust(
            productId: item.productId, deltaPieces: reverseDelta);
      }
      await stockMovementRepo.deleteByInvoiceNumber('BO-$id');
    }

    if (isOnline) {
      await Supabase.instance.client
          .from('bad_order_items')
          .delete()
          .eq('bad_order_id', id);
      await Supabase.instance.client
          .from('bad_orders')
          .delete()
          .eq('id', id);
    } else {
      await syncService.enqueue(
          tableName: 'bad_orders',
          recordId: id,
          operation: 'delete',
          payload: {'id': id});
    }
    await (db.delete(db.badOrderItems)
          ..where((t) => t.badOrderId.equals(id)))
        .go();
    await (db.delete(db.badOrders)..where((t) => t.id.equals(id))).go();
  }
}

final badOrderRepositoryProvider = Provider<BadOrderRepository>((ref) {
  return BadOrderRepository(
    db: ref.watch(localDatabaseProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    syncService: ref.watch(syncServiceProvider),
    inventoryRepo: ref.watch(inventoryRepositoryProvider),
    stockMovementRepo: ref.watch(stockMovementRepositoryProvider),
    productRepo: ref.watch(productRepositoryProvider),
  );
});

final badOrdersListProvider = FutureProvider<List<BadOrder>>((ref) {
  return ref.watch(badOrderRepositoryProvider).getAll();
});
