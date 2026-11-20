import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/database/local_db.dart' hide PurchaseOrder, PurchaseOrderItem;
import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import '../models/purchase_order.dart';
import '../models/purchase_order_item.dart';
import 'base_repository.dart';

class PurchaseOrderRepository extends BaseRepository {
  PurchaseOrderRepository({
    required super.db,
    required super.connectivity,
    required super.syncService,
  });

  Future<List<PurchaseOrder>> getAll({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (isOnline) {
      var q = Supabase.instance.client
          .from('purchase_orders')
          .select()
          .neq('status', 'draft');
      if (startDate != null) {
        q = q.gte('order_date', startDate.toIso8601String());
      }
      if (endDate != null) {
        q = q.lt('order_date', endDate.toIso8601String());
      }
      final data = await q.order('order_date', ascending: false);
      return (data as List).map((j) => PurchaseOrder.fromJson(j)).toList();
    }
    final rows = await (db.select(db.purchaseOrders)
          ..where((t) {
            drift.Expression<bool> expr = t.status.isNotValue('draft');
            if (startDate != null) {
              expr = expr & t.orderDate.isBiggerOrEqualValue(startDate);
            }
            if (endDate != null) {
              expr = expr & t.orderDate.isSmallerThanValue(endDate);
            }
            return expr;
          })
          ..orderBy([(t) => drift.OrderingTerm.desc(t.orderDate)]))
        .get();
    return rows.map(_orderFromRow).toList();
  }

  /// Returns all purchase orders that were left as drafts (unfinished).
  Future<List<PurchaseOrder>> getDrafts() async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('purchase_orders')
          .select()
          .eq('status', 'draft')
          .order('created_at', ascending: false);
      return (data as List).map((j) => PurchaseOrder.fromJson(j)).toList();
    }
    final rows = await (db.select(db.purchaseOrders)
          ..where((t) => t.status.equals('draft'))
          ..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_orderFromRow).toList();
  }

  Future<PurchaseOrder?> getById(String id) async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('purchase_orders')
          .select()
          .eq('id', id)
          .limit(1);
      if ((data as List).isEmpty) return null;
      return PurchaseOrder.fromJson(data.first);
    }
    final rows = await (db.select(db.purchaseOrders)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .get();
    if (rows.isEmpty) return null;
    return _orderFromRow(rows.first);
  }

  PurchaseOrder _orderFromRow(dynamic r) => PurchaseOrder(
        id: r.id,
        supplierId: r.supplierId,
        orderDate: r.orderDate,
        referenceNumber: r.referenceNumber,
        totalAmount: r.totalAmount,
        status: r.status,
        notes: r.notes,
        createdAt: r.createdAt,
        discountPercents:
            PurchaseOrder.decodeDiscountPercents(r.discountPercents),
        vatEnabled: r.vatEnabled,
        preparedBy: r.preparedBy,
      );

  Future<List<PurchaseOrderItem>> getItems(String purchaseOrderId) async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('purchase_order_items')
          .select()
          .eq('purchase_order_id', purchaseOrderId);
      return (data as List)
          .map((j) => PurchaseOrderItem.fromJson(j))
          .toList();
    }
    final rows = await (db.select(db.purchaseOrderItems)
          ..where((t) => t.purchaseOrderId.equals(purchaseOrderId)))
        .get();
    return rows
        .map((r) => PurchaseOrderItem(
              id: r.id,
              purchaseOrderId: r.purchaseOrderId,
              productId: r.productId,
              systemPrice: r.systemPrice,
              price: r.price,
              cases: r.cases,
              amount: r.amount,
              isFree: r.isFree,
              rawPrice: r.rawPrice,
            ))
        .toList();
  }

  Future<void> saveOrder({
    required PurchaseOrder order,
    required List<PurchaseOrderItem> items,
  }) async {
    final orderPayload = order.toJson();
    if (isOnline) {
      await Supabase.instance.client
          .from('purchase_orders')
          .upsert(orderPayload);
    } else {
      await syncService.enqueue(
        tableName: 'purchase_orders',
        recordId: order.id,
        operation: 'insert',
        payload: orderPayload,
      );
    }
    await trySaveLocal(() => _saveLocalOrder(order));

    for (final item in items) {
      final itemPayload = item.toJson();
      if (isOnline) {
        await Supabase.instance.client
            .from('purchase_order_items')
            .upsert(itemPayload);
      } else {
        await syncService.enqueue(
          tableName: 'purchase_order_items',
          recordId: item.id,
          operation: 'insert',
          payload: itemPayload,
        );
      }
      await trySaveLocal(() => _saveLocalItem(item));
    }
  }

  /// Deletes all item rows for a purchase order.
  Future<void> _clearItems(String purchaseOrderId) async {
    if (isOnline) {
      await Supabase.instance.client
          .from('purchase_order_items')
          .delete()
          .eq('purchase_order_id', purchaseOrderId);
    }
    await (db.delete(db.purchaseOrderItems)
          ..where((t) => t.purchaseOrderId.equals(purchaseOrderId)))
        .go();
  }

  /// Saves (upserts) an order as a draft and replaces its items.
  Future<void> saveDraftOrder({
    required PurchaseOrder order,
    required List<PurchaseOrderItem> items,
  }) async {
    final orderPayload = order.toJson();
    if (isOnline) {
      await Supabase.instance.client
          .from('purchase_orders')
          .upsert(orderPayload);
    } else {
      await syncService.enqueue(
        tableName: 'purchase_orders',
        recordId: order.id,
        operation: 'insert',
        payload: orderPayload,
      );
    }
    await trySaveLocal(() => _saveLocalOrder(order));

    await _clearItems(order.id);

    for (final item in items) {
      final itemPayload = item.toJson();
      if (isOnline) {
        await Supabase.instance.client
            .from('purchase_order_items')
            .insert(itemPayload);
      } else {
        await syncService.enqueue(
          tableName: 'purchase_order_items',
          recordId: item.id,
          operation: 'insert',
          payload: itemPayload,
        );
      }
      await trySaveLocal(() => _saveLocalItem(item));
    }
  }

  /// Converts a draft into a finalized open purchase order.
  Future<void> finalizeDraft({
    required PurchaseOrder order,
    required List<PurchaseOrderItem> items,
  }) async {
    await _clearItems(order.id);
    await saveOrder(order: order, items: items);
  }

  /// Discards a draft purchase order and its items entirely.
  Future<void> discardDraft(String orderId) async {
    await _clearItems(orderId);
    if (isOnline) {
      await Supabase.instance.client
          .from('purchase_orders')
          .delete()
          .eq('id', orderId);
    } else {
      await syncService.enqueue(
        tableName: 'purchase_orders',
        recordId: orderId,
        operation: 'delete',
        payload: {'id': orderId},
      );
    }
    await (db.delete(db.purchaseOrders)..where((t) => t.id.equals(orderId)))
        .go();
  }

  /// Replaces the items of an existing purchase order.
  Future<void> editOrder({
    required PurchaseOrder order,
    required List<PurchaseOrderItem> newItems,
  }) async {
    final orderPayload = order.toJson();
    if (isOnline) {
      await Supabase.instance.client
          .from('purchase_orders')
          .update(orderPayload)
          .eq('id', order.id);
    } else {
      await syncService.enqueue(
        tableName: 'purchase_orders',
        recordId: order.id,
        operation: 'update',
        payload: orderPayload,
      );
    }
    await trySaveLocal(() => _saveLocalOrder(order));

    if (isOnline) {
      await Supabase.instance.client
          .from('purchase_order_items')
          .delete()
          .eq('purchase_order_id', order.id);
    }
    await (db.delete(db.purchaseOrderItems)
          ..where((t) => t.purchaseOrderId.equals(order.id)))
        .go();

    for (final item in newItems) {
      final itemPayload = item.toJson();
      if (isOnline) {
        await Supabase.instance.client
            .from('purchase_order_items')
            .insert(itemPayload);
      } else {
        await syncService.enqueue(
          tableName: 'purchase_order_items',
          recordId: item.id,
          operation: 'insert',
          payload: itemPayload,
        );
      }
      await trySaveLocal(() => _saveLocalItem(item));
    }
  }

  /// Marks a purchase order as cancelled.
  Future<void> cancelOrder(String id) async {
    final updated = {'status': 'cancelled'};
    if (isOnline) {
      await Supabase.instance.client
          .from('purchase_orders')
          .update(updated)
          .eq('id', id);
    } else {
      await syncService.enqueue(
        tableName: 'purchase_orders',
        recordId: id,
        operation: 'update',
        payload: updated,
      );
    }
    await (db.update(db.purchaseOrders)..where((t) => t.id.equals(id)))
        .write(const PurchaseOrdersCompanion(status: drift.Value('cancelled')));
  }

  /// Permanently deletes a purchase order and its items.
  Future<void> deleteOrder(String id) async {
    if (isOnline) {
      await Supabase.instance.client
          .from('purchase_order_items')
          .delete()
          .eq('purchase_order_id', id);
    }
    await (db.delete(db.purchaseOrderItems)
          ..where((t) => t.purchaseOrderId.equals(id)))
        .go();

    if (isOnline) {
      await Supabase.instance.client
          .from('purchase_orders')
          .delete()
          .eq('id', id);
    } else {
      await syncService.enqueue(
        tableName: 'purchase_orders',
        recordId: id,
        operation: 'delete',
        payload: {'id': id},
      );
    }
    await (db.delete(db.purchaseOrders)..where((t) => t.id.equals(id))).go();
  }

  Future<void> _saveLocalOrder(PurchaseOrder order) async {
    await db.into(db.purchaseOrders).insertOnConflictUpdate(
          PurchaseOrdersCompanion(
            id: drift.Value(order.id),
            supplierId: drift.Value(order.supplierId),
            orderDate: drift.Value(order.orderDate),
            referenceNumber: drift.Value(order.referenceNumber),
            totalAmount: drift.Value(order.totalAmount),
            status: drift.Value(order.status),
            notes: drift.Value(order.notes),
            createdAt: drift.Value(order.createdAt),
            discountPercents: drift.Value(
                PurchaseOrder.encodeDiscountPercents(order.discountPercents)),
            vatEnabled: drift.Value(order.vatEnabled),
            preparedBy: drift.Value(order.preparedBy),
          ),
        );
  }

  Future<void> _saveLocalItem(PurchaseOrderItem item) async {
    await db.into(db.purchaseOrderItems).insertOnConflictUpdate(
          PurchaseOrderItemsCompanion(
            id: drift.Value(item.id),
            purchaseOrderId: drift.Value(item.purchaseOrderId),
            productId: drift.Value(item.productId),
            systemPrice: drift.Value(item.systemPrice),
            price: drift.Value(item.price),
            cases: drift.Value(item.cases),
            amount: drift.Value(item.amount),
            isFree: drift.Value(item.isFree),
            rawPrice: drift.Value(item.rawPrice),
          ),
        );
  }
}

final purchaseOrderRepositoryProvider = Provider<PurchaseOrderRepository>((ref) {
  return PurchaseOrderRepository(
    db: ref.watch(localDatabaseProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    syncService: ref.watch(syncServiceProvider),
  );
});

final purchaseOrdersListProvider = FutureProvider<List<PurchaseOrder>>((ref) {
  return ref.watch(purchaseOrderRepositoryProvider).getAll();
});

final draftPurchaseOrdersProvider = FutureProvider<List<PurchaseOrder>>((ref) {
  return ref.watch(purchaseOrderRepositoryProvider).getDrafts();
});

final filteredPurchaseOrdersProvider = FutureProvider.family<List<PurchaseOrder>,
    (DateTime?, DateTime?)>((ref, range) {
  final (start, end) = range;
  return ref
      .watch(purchaseOrderRepositoryProvider)
      .getAll(startDate: start, endDate: end);
});
