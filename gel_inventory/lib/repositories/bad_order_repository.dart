import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/database/local_db.dart'
    hide BadOrder, BadOrderItem, BadOrderDraft, StockMovement;
import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import '../models/bad_order.dart';
import '../models/bad_order_draft.dart';
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
    final rows = await (db.select(
      db.badOrders,
    )..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)])).get();
    return rows
        .map(
          (r) => BadOrder(
            id: r.id,
            clientId: r.clientId,
            date: r.date,
            type: r.type,
            notes: r.notes,
            createdAt: r.createdAt,
          ),
        )
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
    final rows = await (db.select(
      db.badOrderItems,
    )..where((t) => t.badOrderId.equals(badOrderId))).get();
    return rows
        .map(
          (r) => BadOrderItem(
            id: r.id,
            badOrderId: r.badOrderId,
            productId: r.productId,
            unitType: r.unitType,
            quantity: r.quantity,
          ),
        )
        .toList();
  }

  /// Returns all items grouped by bad-order id — used for product-name search.
  Future<Map<String, List<BadOrderItem>>> getAllItemsGrouped() async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('bad_order_items')
          .select();
      final items = (data as List)
          .map((j) => BadOrderItem.fromJson(j))
          .toList();
      final map = <String, List<BadOrderItem>>{};
      for (final item in items) {
        (map[item.badOrderId] ??= []).add(item);
      }
      return map;
    }
    final rows = await db.select(db.badOrderItems).get();
    final map = <String, List<BadOrderItem>>{};
    for (final r in rows) {
      (map[r.badOrderId] ??= []).add(
        BadOrderItem(
          id: r.id,
          badOrderId: r.badOrderId,
          productId: r.productId,
          unitType: r.unitType,
          quantity: r.quantity,
        ),
      );
    }
    return map;
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
    await trySaveLocal(
      () => db
          .into(db.badOrders)
          .insertOnConflictUpdate(
            BadOrdersCompanion(
              id: drift.Value(order.id),
              clientId: drift.Value(order.clientId),
              date: drift.Value(order.date),
              type: drift.Value(order.type),
              notes: drift.Value(order.notes),
              createdAt: drift.Value(order.createdAt),
            ),
          ),
    );

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
      await trySaveLocal(
        () => db
            .into(db.badOrderItems)
            .insertOnConflictUpdate(
              BadOrderItemsCompanion(
                id: drift.Value(item.id),
                badOrderId: drift.Value(item.badOrderId),
                productId: drift.Value(item.productId),
                unitType: drift.Value(item.unitType),
                quantity: drift.Value(item.quantity),
              ),
            ),
      );

      final ppb = piecesPerBoxByProduct[item.productId] ?? 1;
      final pieces = item.unitType == 'box'
          ? item.quantity * ppb
          : item.quantity;

      if (order.isReturn) {
        // Returns restore inventory.
        await inventoryRepo.adjust(
          productId: item.productId,
          deltaPieces: pieces,
        );
        await stockMovementRepo.save(
          StockMovement(
            id: const Uuid().v4(),
            productId: item.productId,
            movementType: 'in',
            quantityPieces: pieces,
            referenceDate: order.date,
            invoiceNumber: 'BO-${order.id}',
            comments: 'Return',
            createdAt: DateTime.now(),
          ),
        );
      } else {
        // Bad orders deduct inventory (stock out).
        await inventoryRepo.adjust(
          productId: item.productId,
          deltaPieces: -pieces,
        );
        await stockMovementRepo.save(
          StockMovement(
            id: const Uuid().v4(),
            productId: item.productId,
            movementType: 'out',
            quantityPieces: pieces,
            referenceDate: order.date,
            invoiceNumber: 'BO-${order.id}',
            comments: 'Bad order',
            createdAt: DateTime.now(),
          ),
        );
      }
    }
  }

  /// Adds a new item to an existing bad order/return and applies its
  /// inventory effect (mirrors the per-item logic in [save]).
  Future<void> addItem({
    required BadOrder order,
    required BadOrderItem item,
    required int piecesPerBox,
  }) async {
    final pieces = item.unitType == 'box'
        ? item.quantity * piecesPerBox
        : item.quantity;
    final delta = order.isReturn ? pieces : -pieces;
    await inventoryRepo.adjust(productId: item.productId, deltaPieces: delta);

    await stockMovementRepo.save(
      StockMovement(
        id: const Uuid().v4(),
        productId: item.productId,
        movementType: order.isReturn ? 'in' : 'out',
        quantityPieces: pieces,
        referenceDate: order.date,
        invoiceNumber: 'BO-${order.id}',
        comments: order.isReturn ? 'Return' : 'Bad order',
        createdAt: DateTime.now(),
      ),
    );

    final payload = item.toJson();
    if (isOnline) {
      await Supabase.instance.client.from('bad_order_items').insert(payload);
    } else {
      await syncService.enqueue(
        tableName: 'bad_order_items',
        recordId: item.id,
        operation: 'insert',
        payload: payload,
      );
    }
    await trySaveLocal(
      () => db
          .into(db.badOrderItems)
          .insertOnConflictUpdate(
            BadOrderItemsCompanion(
              id: drift.Value(item.id),
              badOrderId: drift.Value(item.badOrderId),
              productId: drift.Value(item.productId),
              unitType: drift.Value(item.unitType),
              quantity: drift.Value(item.quantity),
            ),
          ),
    );
  }

  /// Edits a single item's unit type / quantity and adjusts inventory accordingly.
  Future<void> updateItem({
    required BadOrder order,
    required BadOrderItem oldItem,
    required String newUnitType,
    required int newQuantity,
    required int piecesPerBox,
  }) async {
    final oldPieces = oldItem.unitType == 'box'
        ? oldItem.quantity * piecesPerBox
        : oldItem.quantity;
    final newPieces = newUnitType == 'box'
        ? newQuantity * piecesPerBox
        : newQuantity;

    // Reverse old effect then apply new effect.
    final reverseDelta = order.isReturn ? -oldPieces : oldPieces;
    await inventoryRepo.adjust(
      productId: oldItem.productId,
      deltaPieces: reverseDelta,
    );

    await stockMovementRepo.deleteOneByInvoiceNumberAndProduct(
      'BO-${order.id}',
      oldItem.productId,
    );

    final newDelta = order.isReturn ? newPieces : -newPieces;
    await inventoryRepo.adjust(
      productId: oldItem.productId,
      deltaPieces: newDelta,
    );

    await stockMovementRepo.save(
      StockMovement(
        id: const Uuid().v4(),
        productId: oldItem.productId,
        movementType: order.isReturn ? 'in' : 'out',
        quantityPieces: newPieces,
        referenceDate: order.date,
        invoiceNumber: 'BO-${order.id}',
        comments: order.isReturn ? 'Return' : 'Bad order',
        createdAt: DateTime.now(),
      ),
    );

    final payload = {
      'id': oldItem.id,
      'bad_order_id': oldItem.badOrderId,
      'product_id': oldItem.productId,
      'unit_type': newUnitType,
      'quantity': newQuantity,
    };
    if (isOnline) {
      await Supabase.instance.client
          .from('bad_order_items')
          .update({'unit_type': newUnitType, 'quantity': newQuantity})
          .eq('id', oldItem.id);
    } else {
      await syncService.enqueue(
        tableName: 'bad_order_items',
        recordId: oldItem.id,
        operation: 'update',
        payload: payload,
      );
    }
    await (db.update(
      db.badOrderItems,
    )..where((t) => t.id.equals(oldItem.id))).write(
      BadOrderItemsCompanion(
        unitType: drift.Value(newUnitType),
        quantity: drift.Value(newQuantity),
      ),
    );
  }

  /// Deletes a single item from a bad order/return and reverses its inventory effect.
  Future<void> deleteItem({
    required BadOrder order,
    required BadOrderItem item,
    required int piecesPerBox,
  }) async {
    final pieces = item.unitType == 'box'
        ? item.quantity * piecesPerBox
        : item.quantity;
    final reverseDelta = order.isReturn ? -pieces : pieces;
    await inventoryRepo.adjust(
      productId: item.productId,
      deltaPieces: reverseDelta,
    );
    await stockMovementRepo.deleteOneByInvoiceNumberAndProduct(
      'BO-${order.id}',
      item.productId,
    );
    if (isOnline) {
      await Supabase.instance.client
          .from('bad_order_items')
          .delete()
          .eq('id', item.id);
    } else {
      await syncService.enqueue(
        tableName: 'bad_order_items',
        recordId: item.id,
        operation: 'delete',
        payload: {'id': item.id},
      );
    }
    await (db.delete(
      db.badOrderItems,
    )..where((t) => t.id.equals(item.id))).go();
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
        final pieces = item.unitType == 'box'
            ? item.quantity * ppb
            : item.quantity;
        // Reverse the original adjustment: returns added pieces back
        // (subtract them now), bad orders removed pieces (add them back).
        final reverseDelta = (order?.isReturn ?? false) ? -pieces : pieces;
        await inventoryRepo.adjust(
          productId: item.productId,
          deltaPieces: reverseDelta,
        );
      }
      await stockMovementRepo.deleteByInvoiceNumber('BO-$id');
    }

    if (isOnline) {
      await Supabase.instance.client
          .from('bad_order_items')
          .delete()
          .eq('bad_order_id', id);
      await Supabase.instance.client.from('bad_orders').delete().eq('id', id);
    } else {
      await syncService.enqueue(
        tableName: 'bad_orders',
        recordId: id,
        operation: 'delete',
        payload: {'id': id},
      );
    }
    await (db.delete(
      db.badOrderItems,
    )..where((t) => t.badOrderId.equals(id))).go();
    await (db.delete(db.badOrders)..where((t) => t.id.equals(id))).go();
  }

  // ── Drafts (auto-saved unfinished "New Bad Order / Return" forms) ───────
  // Stored separately from bad_orders / bad_order_items so autosaving never
  // touches inventory — only the final Save does.

  Future<List<BadOrderDraft>> getDrafts() async {
    if (isOnline) {
      try {
        final data = await Supabase.instance.client
            .from('bad_order_drafts')
            .select()
            .order('created_at', ascending: false);
        return (data as List).map((j) => BadOrderDraft.fromJson(j)).toList();
      } catch (_) {}
    }
    final rows = await (db.select(
      db.badOrderDrafts,
    )..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)])).get();
    return rows
        .map(
          (r) => BadOrderDraft(
            id: r.id,
            type: r.type,
            clientId: r.clientId,
            noClient: r.noClient,
            date: r.date,
            notes: r.notes,
            items: (jsonDecode(r.itemsJson) as List)
                .map(
                  (e) => BadOrderDraftItem.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
            createdAt: r.createdAt,
          ),
        )
        .toList();
  }

  Future<void> saveDraft(BadOrderDraft draft) async {
    final payload = draft.toJson();
    if (isOnline) {
      try {
        await Supabase.instance.client.from('bad_order_drafts').upsert(payload);
      } catch (_) {}
    } else {
      await syncService.enqueue(
        tableName: 'bad_order_drafts',
        recordId: draft.id,
        operation: 'insert',
        payload: payload,
      );
    }
    await trySaveLocal(
      () => db
          .into(db.badOrderDrafts)
          .insertOnConflictUpdate(
            BadOrderDraftsCompanion(
              id: drift.Value(draft.id),
              type: drift.Value(draft.type),
              clientId: drift.Value(draft.clientId),
              noClient: drift.Value(draft.noClient),
              date: drift.Value(draft.date),
              notes: drift.Value(draft.notes),
              itemsJson: drift.Value(
                jsonEncode(draft.items.map((i) => i.toJson()).toList()),
              ),
              createdAt: drift.Value(draft.createdAt),
            ),
          ),
    );
  }

  Future<void> discardDraft(String id) async {
    if (isOnline) {
      try {
        await Supabase.instance.client
            .from('bad_order_drafts')
            .delete()
            .eq('id', id);
      } catch (_) {}
    } else {
      await syncService.enqueue(
        tableName: 'bad_order_drafts',
        recordId: id,
        operation: 'delete',
        payload: {'id': id},
      );
    }
    await (db.delete(db.badOrderDrafts)..where((t) => t.id.equals(id))).go();
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

final badOrderDraftsProvider = FutureProvider<List<BadOrderDraft>>((ref) {
  return ref.watch(badOrderRepositoryProvider).getDrafts();
});
