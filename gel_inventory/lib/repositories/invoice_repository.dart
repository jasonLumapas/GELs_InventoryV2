import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/database/local_db.dart' hide Invoice, InvoiceItem;
import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import 'base_repository.dart';
import 'inventory_repository.dart';

class InvoiceRepository extends BaseRepository {
  final InventoryRepository inventoryRepo;

  InvoiceRepository({
    required super.db,
    required super.connectivity,
    required super.syncService,
    required this.inventoryRepo,
  });

  /// Generates a unique invoice number in YYYYMMDD-NNN format for the given date.
  Future<String> generateInvoiceNumber(DateTime date) async {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final dateStr = '$y$m$d';
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    int count;
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('invoices')
          .select('id')
          .gte('created_at', start.toIso8601String())
          .lt('created_at', end.toIso8601String());
      count = (data as List).length + 1;
    } else {
      final rows = await (db.select(db.invoices)
            ..where((t) =>
                t.createdAt.isBiggerOrEqualValue(start) &
                t.createdAt.isSmallerThanValue(end)))
          .get();
      count = rows.length + 1;
    }
    return '$dateStr-${count.toString().padLeft(3, '0')}';
  }

  Future<List<Invoice>> getAll({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (isOnline) {
      var q = Supabase.instance.client
          .from('invoices')
          .select()
          .neq('status', 'cancelled');
      if (startDate != null) {
        q = q.gte('invoice_date', startDate.toIso8601String());
      }
      if (endDate != null) {
        q = q.lt('invoice_date', endDate.toIso8601String());
      }
      final data = await q.order('invoice_date', ascending: false);
      return (data as List).map((j) => Invoice.fromJson(j)).toList();
    }
    final rows = await (db.select(db.invoices)
          ..where((t) {
            drift.Expression<bool> expr = t.status.isNotValue('cancelled');
            if (startDate != null) {
              expr = expr & t.invoiceDate.isBiggerOrEqualValue(startDate);
            }
            if (endDate != null) {
              expr = expr & t.invoiceDate.isSmallerThanValue(endDate);
            }
            return expr;
          })
          ..orderBy([(t) => drift.OrderingTerm.desc(t.invoiceDate)]))
        .get();
    return rows
        .map((r) => Invoice(
              id: r.id,
              clientId: r.clientId,
              invoiceDate: r.invoiceDate,
              totalAmount: r.totalAmount,
              status: r.status,
              createdAt: r.createdAt,
              invoiceNumber: r.invoiceNumber,
            ))
        .toList();
  }

  Future<List<InvoiceItem>> getItems(String invoiceId) async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('invoice_items')
          .select()
          .eq('invoice_id', invoiceId);
      return (data as List).map((j) => InvoiceItem.fromJson(j)).toList();
    }
    final rows = await (db.select(db.invoiceItems)
          ..where((t) => t.invoiceId.equals(invoiceId)))
        .get();
    return rows
        .map((r) => InvoiceItem(
              id: r.id,
              invoiceId: r.invoiceId,
              productId: r.productId,
              unitType: r.unitType,
              quantity: r.quantity,
              pricePerPiece: r.pricePerPiece,
              subtotal: r.subtotal,
            ))
        .toList();
  }

  Future<void> saveInvoice({
    required Invoice invoice,
    required List<InvoiceItem> items,
  }) async {
    final invPayload = invoice.toJson();
    if (isOnline) {
      await Supabase.instance.client.from('invoices').upsert(invPayload);
    } else {
      await syncService.enqueue(
        tableName: 'invoices',
        recordId: invoice.id,
        operation: 'insert',
        payload: invPayload,
      );
    }
    await _saveLocalInvoice(invoice);

    for (final item in items) {
      final itemPayload = item.toJson();
      if (isOnline) {
        await Supabase.instance.client
            .from('invoice_items')
            .upsert(itemPayload);
      } else {
        await syncService.enqueue(
          tableName: 'invoice_items',
          recordId: item.id,
          operation: 'insert',
          payload: itemPayload,
        );
      }
      await _saveLocalItem(item);

      await inventoryRepo.adjust(
        productId: item.productId,
        deltaPieces: -item.quantity,
      );
    }
  }

  /// Replaces the items of an existing invoice and adjusts inventory for the
  /// difference between old and new quantities (per product, in pieces).
  Future<void> editInvoice({
    required Invoice invoice,
    required List<InvoiceItem> newItems,
    required List<InvoiceItem> oldItems,
  }) async {
    // Compute per-product piece delta (positive = ordered more, negative = ordered less)
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
        await inventoryRepo.adjust(productId: pid, deltaPieces: -delta);
      }
    }

    // Update invoice record
    final invPayload = invoice.toJson();
    if (isOnline) {
      await Supabase.instance.client
          .from('invoices')
          .update(invPayload)
          .eq('id', invoice.id);
    } else {
      await syncService.enqueue(
        tableName: 'invoices',
        recordId: invoice.id,
        operation: 'update',
        payload: invPayload,
      );
    }
    await _saveLocalInvoice(invoice);

    // Delete all old items and re-insert new ones
    if (isOnline) {
      await Supabase.instance.client
          .from('invoice_items')
          .delete()
          .eq('invoice_id', invoice.id);
    }
    await (db.delete(db.invoiceItems)
          ..where((t) => t.invoiceId.equals(invoice.id)))
        .go();

    for (final item in newItems) {
      final itemPayload = item.toJson();
      if (isOnline) {
        await Supabase.instance.client.from('invoice_items').insert(itemPayload);
      } else {
        await syncService.enqueue(
          tableName: 'invoice_items',
          recordId: item.id,
          operation: 'insert',
          payload: itemPayload,
        );
      }
      await _saveLocalItem(item);
    }
  }

  /// Permanently deletes an invoice and its items.
  /// If the invoice was printed, inventory is restored first.
  Future<void> deleteInvoice(Invoice invoice) async {
    if (invoice.status == 'printed') {
      final items = await getItems(invoice.id);
      for (final item in items) {
        await inventoryRepo.adjust(
          productId: item.productId,
          deltaPieces: item.quantity, // restore deducted stock
        );
      }
    }

    // Delete items
    if (isOnline) {
      await Supabase.instance.client
          .from('invoice_items')
          .delete()
          .eq('invoice_id', invoice.id);
    }
    await (db.delete(db.invoiceItems)
          ..where((t) => t.invoiceId.equals(invoice.id)))
        .go();

    // Delete invoice
    if (isOnline) {
      await Supabase.instance.client
          .from('invoices')
          .delete()
          .eq('id', invoice.id);
    } else {
      await syncService.enqueue(
        tableName: 'invoices',
        recordId: invoice.id,
        operation: 'delete',
        payload: {'id': invoice.id},
      );
    }
    await (db.delete(db.invoices)..where((t) => t.id.equals(invoice.id))).go();
  }

  Future<void> cancelInvoice(String invoiceId) async {
    final updated = {'status': 'cancelled'};
    if (isOnline) {
      await Supabase.instance.client
          .from('invoices')
          .update(updated)
          .eq('id', invoiceId);
    } else {
      await syncService.enqueue(
        tableName: 'invoices',
        recordId: invoiceId,
        operation: 'update',
        payload: updated,
      );
    }
    await (db.update(db.invoices)..where((t) => t.id.equals(invoiceId)))
        .write(const InvoicesCompanion(status: drift.Value('cancelled')));
  }

  Future<void> _saveLocalInvoice(Invoice inv) async {
    await db.into(db.invoices).insertOnConflictUpdate(InvoicesCompanion(
          id: drift.Value(inv.id),
          clientId: drift.Value(inv.clientId),
          invoiceDate: drift.Value(inv.invoiceDate),
          totalAmount: drift.Value(inv.totalAmount),
          status: drift.Value(inv.status),
          createdAt: drift.Value(inv.createdAt),
          invoiceNumber: drift.Value(inv.invoiceNumber),
        ));
  }

  Future<void> _saveLocalItem(InvoiceItem item) async {
    await db
        .into(db.invoiceItems)
        .insertOnConflictUpdate(InvoiceItemsCompanion(
          id: drift.Value(item.id),
          invoiceId: drift.Value(item.invoiceId),
          productId: drift.Value(item.productId),
          unitType: drift.Value(item.unitType),
          quantity: drift.Value(item.quantity),
          pricePerPiece: drift.Value(item.pricePerPiece),
          subtotal: drift.Value(item.subtotal),
        ));
  }
}

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepository(
    db: ref.watch(localDatabaseProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    syncService: ref.watch(syncServiceProvider),
    inventoryRepo: ref.watch(inventoryRepositoryProvider),
  );
});

/// Unfiltered list — used for invalidation and the detail screen lookup.
final invoicesListProvider = FutureProvider<List<Invoice>>((ref) {
  return ref.watch(invoiceRepositoryProvider).getAll();
});

/// Date-range filtered list — keyed on (startDate, endDate); null = no bound.
final filteredInvoicesProvider =
    FutureProvider.family<List<Invoice>, (DateTime?, DateTime?)>((ref, range) {
  final (start, end) = range;
  return ref
      .watch(invoiceRepositoryProvider)
      .getAll(startDate: start, endDate: end);
});
