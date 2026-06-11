import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/database/local_db.dart'
    hide SupplierReceivedInvoice, SupplierReceivedInvoiceItem, StockMovement, Supplier;
import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import '../models/stock_movement.dart';
import '../models/supplier.dart';
import '../models/supplier_received_invoice.dart';
import '../models/supplier_received_invoice_item.dart';
import 'base_repository.dart';
import 'inventory_repository.dart';
import 'stock_movement_repository.dart';

class SupplierReceivedInvoiceRepository extends BaseRepository {
  final InventoryRepository inventoryRepo;
  final StockMovementRepository stockMovementRepo;

  SupplierReceivedInvoiceRepository({
    required super.db,
    required super.connectivity,
    required super.syncService,
    required this.inventoryRepo,
    required this.stockMovementRepo,
  });

  Future<List<SupplierReceivedInvoice>> getAll({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (isOnline) {
      var q = Supabase.instance.client.from('supplier_received_invoices').select();
      if (startDate != null) {
        q = q.gte('received_date', startDate.toIso8601String());
      }
      if (endDate != null) {
        q = q.lt('received_date', endDate.toIso8601String());
      }
      final data = await q.order('received_date', ascending: false);
      return (data as List)
          .map((j) => SupplierReceivedInvoice.fromJson(j))
          .toList();
    }
    final rows = await (db.select(db.supplierReceivedInvoices)
          ..where((t) {
            drift.Expression<bool> expr = const drift.Constant(true);
            if (startDate != null) {
              expr = expr & t.receivedDate.isBiggerOrEqualValue(startDate);
            }
            if (endDate != null) {
              expr = expr & t.receivedDate.isSmallerThanValue(endDate);
            }
            return expr;
          })
          ..orderBy([(t) => drift.OrderingTerm.desc(t.receivedDate)]))
        .get();
    return rows.map(_invoiceFromRow).toList();
  }

  Future<SupplierReceivedInvoice?> getById(String id) async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('supplier_received_invoices')
          .select()
          .eq('id', id)
          .limit(1);
      if ((data as List).isEmpty) return null;
      return SupplierReceivedInvoice.fromJson(data.first);
    }
    final rows = await (db.select(db.supplierReceivedInvoices)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .get();
    if (rows.isEmpty) return null;
    return _invoiceFromRow(rows.first);
  }

  SupplierReceivedInvoice _invoiceFromRow(dynamic r) => SupplierReceivedInvoice(
        id: r.id,
        supplierId: r.supplierId,
        receivedDate: r.receivedDate,
        referenceNumber: r.referenceNumber,
        totalAmountSystem: r.totalAmountSystem,
        totalAmountSupplier: r.totalAmountSupplier,
        status: r.status,
        notes: r.notes,
        createdAt: r.createdAt,
      );

  Future<List<SupplierReceivedInvoiceItem>> getItems(
      String receivedInvoiceId) async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('supplier_received_invoice_items')
          .select()
          .eq('received_invoice_id', receivedInvoiceId);
      return (data as List)
          .map((j) => SupplierReceivedInvoiceItem.fromJson(j))
          .toList();
    }
    final rows = await (db.select(db.supplierReceivedInvoiceItems)
          ..where((t) => t.receivedInvoiceId.equals(receivedInvoiceId)))
        .get();
    return rows
        .map((r) => SupplierReceivedInvoiceItem(
              id: r.id,
              receivedInvoiceId: r.receivedInvoiceId,
              productId: r.productId,
              unitType: r.unitType,
              quantity: r.quantity,
              systemPrice: r.systemPrice,
              supplierPrice: r.supplierPrice,
              subtotalSystem: r.subtotalSystem,
              subtotalSupplier: r.subtotalSupplier,
            ))
        .toList();
  }

  Future<void> saveInvoice({
    required SupplierReceivedInvoice invoice,
    required List<SupplierReceivedInvoiceItem> items,
    required Supplier supplier,
  }) async {
    final invPayload = invoice.toJson();
    if (isOnline) {
      await Supabase.instance.client
          .from('supplier_received_invoices')
          .upsert(invPayload);
    } else {
      await syncService.enqueue(
        tableName: 'supplier_received_invoices',
        recordId: invoice.id,
        operation: 'insert',
        payload: invPayload,
      );
    }
    await trySaveLocal(() => _saveLocalInvoice(invoice));

    for (final item in items) {
      final itemPayload = item.toJson();
      if (isOnline) {
        await Supabase.instance.client
            .from('supplier_received_invoice_items')
            .upsert(itemPayload);
      } else {
        await syncService.enqueue(
          tableName: 'supplier_received_invoice_items',
          recordId: item.id,
          operation: 'insert',
          payload: itemPayload,
        );
      }
      await trySaveLocal(() => _saveLocalItem(item));

      await inventoryRepo.adjust(
        productId: item.productId,
        deltaPieces: item.quantity,
      );

      await stockMovementRepo.save(StockMovement(
        id: _newId(),
        productId: item.productId,
        movementType: 'in',
        quantityPieces: item.quantity,
        referenceDate: invoice.receivedDate,
        invoiceNumber: 'SRI-${invoice.id}',
        comments: 'Received from ${supplier.name}',
        createdAt: DateTime.now(),
      ));
    }
  }

  /// Replaces the items of an existing invoice and adjusts inventory for the
  /// difference between old and new quantities (per product, in pieces).
  Future<void> editInvoice({
    required SupplierReceivedInvoice invoice,
    required List<SupplierReceivedInvoiceItem> newItems,
    required List<SupplierReceivedInvoiceItem> oldItems,
    required Supplier supplier,
  }) async {
    final oldQty = <String, int>{};
    for (final item in oldItems) {
      oldQty[item.productId] = (oldQty[item.productId] ?? 0) + item.quantity;
    }
    final newQty = <String, int>{};
    for (final item in newItems) {
      newQty[item.productId] = (newQty[item.productId] ?? 0) + item.quantity;
    }
    for (final pid in {...oldQty.keys, ...newQty.keys}) {
      final delta = (newQty[pid] ?? 0) - (oldQty[pid] ?? 0);
      if (delta != 0) {
        await inventoryRepo.adjust(productId: pid, deltaPieces: delta);
      }
    }

    final invPayload = invoice.toJson();
    if (isOnline) {
      await Supabase.instance.client
          .from('supplier_received_invoices')
          .update(invPayload)
          .eq('id', invoice.id);
    } else {
      await syncService.enqueue(
        tableName: 'supplier_received_invoices',
        recordId: invoice.id,
        operation: 'update',
        payload: invPayload,
      );
    }
    await trySaveLocal(() => _saveLocalInvoice(invoice));

    // Delete all old items and re-insert new ones
    if (isOnline) {
      await Supabase.instance.client
          .from('supplier_received_invoice_items')
          .delete()
          .eq('received_invoice_id', invoice.id);
    }
    await (db.delete(db.supplierReceivedInvoiceItems)
          ..where((t) => t.receivedInvoiceId.equals(invoice.id)))
        .go();

    for (final item in newItems) {
      final itemPayload = item.toJson();
      if (isOnline) {
        await Supabase.instance.client
            .from('supplier_received_invoice_items')
            .insert(itemPayload);
      } else {
        await syncService.enqueue(
          tableName: 'supplier_received_invoice_items',
          recordId: item.id,
          operation: 'insert',
          payload: itemPayload,
        );
      }
      await trySaveLocal(() => _saveLocalItem(item));
    }

    // Replace stock movement audit trail with fresh entries.
    await stockMovementRepo.deleteByInvoiceNumber('SRI-${invoice.id}');
    for (final item in newItems) {
      await stockMovementRepo.save(StockMovement(
        id: _newId(),
        productId: item.productId,
        movementType: 'in',
        quantityPieces: item.quantity,
        referenceDate: invoice.receivedDate,
        invoiceNumber: 'SRI-${invoice.id}',
        comments: 'Received from ${supplier.name}',
        createdAt: DateTime.now(),
      ));
    }
  }

  /// Cancels a received invoice, reversing the inventory it added.
  Future<void> cancelInvoice(String id) async {
    final invoice = await getById(id);
    if (invoice == null || invoice.status == 'cancelled') return;

    final items = await getItems(id);
    for (final item in items) {
      await inventoryRepo.adjust(
        productId: item.productId,
        deltaPieces: -item.quantity,
      );
    }
    await stockMovementRepo.deleteByInvoiceNumber('SRI-$id');

    final updated = {'status': 'cancelled'};
    if (isOnline) {
      await Supabase.instance.client
          .from('supplier_received_invoices')
          .update(updated)
          .eq('id', id);
    } else {
      await syncService.enqueue(
        tableName: 'supplier_received_invoices',
        recordId: id,
        operation: 'update',
        payload: updated,
      );
    }
    await (db.update(db.supplierReceivedInvoices)
          ..where((t) => t.id.equals(id)))
        .write(const SupplierReceivedInvoicesCompanion(
            status: drift.Value('cancelled')));
  }

  /// Permanently deletes a received invoice and its items.
  /// If it was not already cancelled, inventory is reversed first.
  Future<void> deleteInvoice(SupplierReceivedInvoice invoice) async {
    if (invoice.status == 'received') {
      final items = await getItems(invoice.id);
      for (final item in items) {
        await inventoryRepo.adjust(
          productId: item.productId,
          deltaPieces: -item.quantity,
        );
      }
      await stockMovementRepo.deleteByInvoiceNumber('SRI-${invoice.id}');
    }

    if (isOnline) {
      await Supabase.instance.client
          .from('supplier_received_invoice_items')
          .delete()
          .eq('received_invoice_id', invoice.id);
    }
    await (db.delete(db.supplierReceivedInvoiceItems)
          ..where((t) => t.receivedInvoiceId.equals(invoice.id)))
        .go();

    if (isOnline) {
      await Supabase.instance.client
          .from('supplier_received_invoices')
          .delete()
          .eq('id', invoice.id);
    } else {
      await syncService.enqueue(
        tableName: 'supplier_received_invoices',
        recordId: invoice.id,
        operation: 'delete',
        payload: {'id': invoice.id},
      );
    }
    await (db.delete(db.supplierReceivedInvoices)
          ..where((t) => t.id.equals(invoice.id)))
        .go();
  }

  Future<void> _saveLocalInvoice(SupplierReceivedInvoice inv) async {
    await db.into(db.supplierReceivedInvoices).insertOnConflictUpdate(
          SupplierReceivedInvoicesCompanion(
            id: drift.Value(inv.id),
            supplierId: drift.Value(inv.supplierId),
            receivedDate: drift.Value(inv.receivedDate),
            referenceNumber: drift.Value(inv.referenceNumber),
            totalAmountSystem: drift.Value(inv.totalAmountSystem),
            totalAmountSupplier: drift.Value(inv.totalAmountSupplier),
            status: drift.Value(inv.status),
            notes: drift.Value(inv.notes),
            createdAt: drift.Value(inv.createdAt),
          ),
        );
  }

  Future<void> _saveLocalItem(SupplierReceivedInvoiceItem item) async {
    await db.into(db.supplierReceivedInvoiceItems).insertOnConflictUpdate(
          SupplierReceivedInvoiceItemsCompanion(
            id: drift.Value(item.id),
            receivedInvoiceId: drift.Value(item.receivedInvoiceId),
            productId: drift.Value(item.productId),
            unitType: drift.Value(item.unitType),
            quantity: drift.Value(item.quantity),
            systemPrice: drift.Value(item.systemPrice),
            supplierPrice: drift.Value(item.supplierPrice),
            subtotalSystem: drift.Value(item.subtotalSystem),
            subtotalSupplier: drift.Value(item.subtotalSupplier),
          ),
        );
  }
}

String _newId() => const Uuid().v4();

final supplierReceivedInvoiceRepositoryProvider =
    Provider<SupplierReceivedInvoiceRepository>((ref) {
  return SupplierReceivedInvoiceRepository(
    db: ref.watch(localDatabaseProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    syncService: ref.watch(syncServiceProvider),
    inventoryRepo: ref.watch(inventoryRepositoryProvider),
    stockMovementRepo: ref.watch(stockMovementRepositoryProvider),
  );
});

final supplierReceivedInvoicesListProvider =
    FutureProvider<List<SupplierReceivedInvoice>>((ref) {
  return ref.watch(supplierReceivedInvoiceRepositoryProvider).getAll();
});

final filteredSupplierReceivedInvoicesProvider = FutureProvider.family<
    List<SupplierReceivedInvoice>, (DateTime?, DateTime?)>((ref, range) {
  final (start, end) = range;
  return ref
      .watch(supplierReceivedInvoiceRepositoryProvider)
      .getAll(startDate: start, endDate: end);
});
