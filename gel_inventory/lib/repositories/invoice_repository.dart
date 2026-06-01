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

  Future<List<Invoice>> getAll({DateTime? date}) async {
    if (isOnline) {
      // Apply filters before .order() to stay on PostgrestFilterBuilder
      var q = Supabase.instance.client
          .from('invoices')
          .select()
          .neq('status', 'cancelled');

      if (date != null) {
        final start = DateTime(date.year, date.month, date.day);
        final end = start.add(const Duration(days: 1));
        q = q
            .gte('invoice_date', start.toIso8601String())
            .lt('invoice_date', end.toIso8601String());
      }

      final data = await q.order('created_at', ascending: false);
      return (data as List).map((j) => Invoice.fromJson(j)).toList();
    }
    final rows = await (db.select(db.invoices)
          ..where((t) => t.status.isNotValue('cancelled'))
          ..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows
        .map((r) => Invoice(
              id: r.id,
              clientId: r.clientId,
              invoiceDate: r.invoiceDate,
              totalAmount: r.totalAmount,
              status: r.status,
              createdAt: r.createdAt,
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

final invoicesListProvider = FutureProvider<List<Invoice>>((ref) {
  return ref.watch(invoiceRepositoryProvider).getAll();
});
