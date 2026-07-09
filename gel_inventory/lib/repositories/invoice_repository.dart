import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/database/local_db.dart'
    hide Invoice, InvoiceItem, DeletedInvoiceItem;
import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import '../models/deleted_invoice_item.dart';
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
          .gte('invoice_date', start.toIso8601String())
          .lt('invoice_date', end.toIso8601String());
      count = (data as List).length + 1;
    } else {
      final rows = await (db.select(db.invoices)
            ..where((t) =>
                t.invoiceDate.isBiggerOrEqualValue(start) &
                t.invoiceDate.isSmallerThanValue(end)))
          .get();
      count = rows.length + 1;
    }
    return '$dateStr-${count.toString().padLeft(3, '0')}';
  }

  /// Returns the next available sequential display number (max existing
  /// `sequence_number` + 1, or 1 if none are assigned yet).
  Future<int> getNextSequenceNumber() async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('invoices')
          .select('sequence_number')
          .not('sequence_number', 'is', null)
          .order('sequence_number', ascending: false)
          .limit(1);
      final list = data as List;
      final maxSeq =
          list.isEmpty ? 0 : (list.first['sequence_number'] as num).toInt();
      return maxSeq + 1;
    }
    final rows = await (db.select(db.invoices)
          ..where((t) => t.sequenceNumber.isNotNull())
          ..orderBy([(t) => drift.OrderingTerm.desc(t.sequenceNumber)])
          ..limit(1))
        .get();
    final maxSeq = rows.isEmpty ? 0 : (rows.first.sequenceNumber ?? 0);
    return maxSeq + 1;
  }

  /// Assigns sequence numbers to non-draft invoices that don't have one yet,
  /// in `createdAt` ascending order, continuing after any existing max.
  /// Returns true if any invoices were updated.
  Future<bool> backfillSequenceNumbers() async {
    List<MapEntry<String, int?>> entries;
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('invoices')
          .select('id, sequence_number')
          .neq('status', 'draft')
          .order('created_at', ascending: true);
      entries = (data as List)
          .map((j) => MapEntry(
              j['id'] as String, (j['sequence_number'] as num?)?.toInt()))
          .toList();
    } else {
      final rows = await (db.select(db.invoices)
            ..where((t) => t.status.isNotValue('draft'))
            ..orderBy([(t) => drift.OrderingTerm.asc(t.createdAt)]))
          .get();
      entries = rows.map((r) => MapEntry(r.id, r.sequenceNumber)).toList();
    }

    var next = 1;
    for (final e in entries) {
      if (e.value != null && e.value! >= next) next = e.value! + 1;
    }

    var changed = false;
    for (final e in entries) {
      if (e.value == null) {
        await _setSequenceNumber(e.key, next);
        next++;
        changed = true;
      }
    }
    return changed;
  }

  Future<void> _setSequenceNumber(String invoiceId, int seq) async {
    final updated = {'sequence_number': seq};
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
        .write(InvoicesCompanion(sequenceNumber: drift.Value(seq)));
  }

  Future<List<Invoice>> getAll({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (isOnline) {
      var q = Supabase.instance.client
          .from('invoices')
          .select()
          .neq('status', 'cancelled')
          .neq('status', 'draft');
      if (startDate != null) {
        q = q.gte('invoice_date', startDate.toIso8601String());
      }
      if (endDate != null) {
        q = q.lt('invoice_date', endDate.toIso8601String());
      }
      final data = await q.order('invoice_number', ascending: true);
      return (data as List).map((j) => Invoice.fromJson(j)).toList();
    }
    final rows = await (db.select(db.invoices)
          ..where((t) {
            drift.Expression<bool> expr = t.status.isNotValue('cancelled') &
                t.status.isNotValue('draft');
            if (startDate != null) {
              expr = expr & t.invoiceDate.isBiggerOrEqualValue(startDate);
            }
            if (endDate != null) {
              expr = expr & t.invoiceDate.isSmallerThanValue(endDate);
            }
            return expr;
          })
          ..orderBy([(t) => drift.OrderingTerm.asc(t.invoiceNumber)]))
        .get();
    return rows
        .map((r) => Invoice(
              id: r.id,
              clientId: r.clientId,
              invoiceDate: r.invoiceDate,
              totalAmount: r.totalAmount,
              status: r.status,
              createdAt: r.createdAt,
              invoiceNumber:  r.invoiceNumber,
              sequenceNumber: r.sequenceNumber,
              invoiceType:    r.invoiceType,
              paymentType:    r.paymentType,
              partialAmount:  r.partialAmount,
              partialDate:    r.partialDate,
              checkReference: r.checkReference,
              checkAmount:    r.checkAmount,
              checkIssuedDate: r.checkIssuedDate,
              checkDueDate:   r.checkDueDate,
              notes: r.notes,
              actualAmount: r.actualAmount,
              includeInLayout: r.includeInLayout,
            ))
        .toList();
  }

  /// Returns all draft invoices (status == 'draft'), most recently created first.
  Future<List<Invoice>> getDrafts() async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('invoices')
          .select()
          .eq('status', 'draft')
          .order('created_at', ascending: false);
      return (data as List).map((j) => Invoice.fromJson(j)).toList();
    }
    final rows = await (db.select(db.invoices)
          ..where((t) => t.status.equals('draft'))
          ..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_invoiceFromRow).toList();
  }

  /// Fetches a single invoice by id, regardless of status (including drafts).
  Future<Invoice?> getById(String id) async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('invoices')
          .select()
          .eq('id', id)
          .limit(1);
      if ((data as List).isEmpty) return null;
      return Invoice.fromJson(data.first);
    }
    final rows = await (db.select(db.invoices)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .get();
    if (rows.isEmpty) return null;
    return _invoiceFromRow(rows.first);
  }

  Invoice _invoiceFromRow(dynamic r) {
    return Invoice(
      id: r.id,
      clientId: r.clientId,
      invoiceDate: r.invoiceDate,
      totalAmount: r.totalAmount,
      status: r.status,
      createdAt: r.createdAt,
      invoiceNumber:  r.invoiceNumber,
      sequenceNumber: r.sequenceNumber,
      invoiceType:    r.invoiceType,
      paymentType:    r.paymentType,
      partialAmount:  r.partialAmount,
      partialDate:    r.partialDate,
      checkReference: r.checkReference,
      checkAmount:    r.checkAmount,
      checkIssuedDate: r.checkIssuedDate,
      checkDueDate:   r.checkDueDate,
      notes: r.notes,
      actualAmount: r.actualAmount,
      includeInLayout: r.includeInLayout,
    );
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
              isFree: r.isFree,
              discountPercent: r.discountPercent,
            ))
        .toList();
  }

  Future<Invoice> saveInvoice({
    required Invoice invoice,
    required List<InvoiceItem> items,
  }) async {
    var inv = invoice;
    if (inv.status != 'draft' && inv.sequenceNumber == null) {
      inv = inv.copyWith(sequenceNumber: await getNextSequenceNumber());
    }
    final invPayload = inv.toJson();
    if (isOnline) {
      await Supabase.instance.client.from('invoices').upsert(invPayload);
    } else {
      await syncService.enqueue(
        tableName: 'invoices',
        recordId: inv.id,
        operation: 'insert',
        payload: invPayload,
      );
    }
    await trySaveLocal(() => _saveLocalInvoice(inv));

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
      await trySaveLocal(() => _saveLocalItem(item));

      await inventoryRepo.adjust(
        productId: item.productId,
        deltaPieces: -item.quantity,
      );
    }

    return inv;
  }

  /// Deletes all items belonging to [invoiceId] without adjusting inventory.
  /// Used for draft saves/finalization where the previous draft items never
  /// affected inventory.
  Future<void> _clearItems(String invoiceId) async {
    if (isOnline) {
      await Supabase.instance.client
          .from('invoice_items')
          .delete()
          .eq('invoice_id', invoiceId);
    }
    await (db.delete(db.invoiceItems)
          ..where((t) => t.invoiceId.equals(invoiceId)))
        .go();
  }

  /// Saves or updates a draft invoice (status == 'draft'). Replaces all
  /// items for the invoice. Drafts never affect inventory.
  Future<void> saveDraftInvoice({
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
    await trySaveLocal(() => _saveLocalInvoice(invoice));

    await _clearItems(invoice.id);
    for (final item in items) {
      final itemPayload = item.toJson();
      if (isOnline) {
        await Supabase.instance.client
            .from('invoice_items')
            .insert(itemPayload);
      } else {
        await syncService.enqueue(
          tableName: 'invoice_items',
          recordId: item.id,
          operation: 'insert',
          payload: itemPayload,
        );
      }
      await trySaveLocal(() => _saveLocalItem(item));
    }
  }

  /// Replaces a draft invoice's items with [items], marks it as [status]
  /// (typically 'printed'), and deducts inventory for the new items.
  /// The previous draft items are discarded without inventory adjustment.
  Future<Invoice> finalizeDraft({
    required Invoice invoice,
    required List<InvoiceItem> items,
  }) async {
    await _clearItems(invoice.id);
    return saveInvoice(invoice: invoice, items: items);
  }

  /// Permanently deletes a draft invoice and its items. Drafts never affect
  /// inventory, so nothing is restored.
  Future<void> discardDraft(String invoiceId) async {
    await _clearItems(invoiceId);
    if (isOnline) {
      await Supabase.instance.client
          .from('invoices')
          .delete()
          .eq('id', invoiceId);
    } else {
      await syncService.enqueue(
        tableName: 'invoices',
        recordId: invoiceId,
        operation: 'delete',
        payload: {'id': invoiceId},
      );
    }
    await (db.delete(db.invoices)..where((t) => t.id.equals(invoiceId))).go();
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

    // Log rows that were truly removed (id present in oldItems but not in
    // newItems) — modified rows keep their id, so this only catches actual
    // deletions, not quantity/unit-type edits.
    final newIds = newItems.map((i) => i.id).toSet();
    final removed = oldItems.where((i) => !newIds.contains(i.id));
    final deletedAt = DateTime.now();
    for (final item in removed) {
      await _logDeletedItem(item, deletedAt);
    }

    // Update invoice record
    var inv = invoice;
    if (inv.status != 'draft' && inv.sequenceNumber == null) {
      inv = inv.copyWith(sequenceNumber: await getNextSequenceNumber());
    }
    final invPayload = inv.toJson();
    if (isOnline) {
      await Supabase.instance.client
          .from('invoices')
          .update(invPayload)
          .eq('id', inv.id);
    } else {
      await syncService.enqueue(
        tableName: 'invoices',
        recordId: inv.id,
        operation: 'update',
        payload: invPayload,
      );
    }
    await trySaveLocal(() => _saveLocalInvoice(inv));

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
      await trySaveLocal(() => _saveLocalItem(item));
    }
  }

  Future<void> _logDeletedItem(InvoiceItem item, DateTime deletedAt) async {
    final entry = DeletedInvoiceItem(
      id: const Uuid().v4(),
      invoiceId: item.invoiceId,
      productId: item.productId,
      unitType: item.unitType,
      quantity: item.quantity,
      pricePerPiece: item.pricePerPiece,
      subtotal: item.subtotal,
      isFree: item.isFree,
      deletedAt: deletedAt,
    );
    final payload = entry.toJson();
    if (isOnline) {
      await Supabase.instance.client
          .from('deleted_invoice_items')
          .insert(payload);
    } else {
      await syncService.enqueue(
        tableName: 'deleted_invoice_items',
        recordId: entry.id,
        operation: 'insert',
        payload: payload,
      );
    }
    await trySaveLocal(() => db.into(db.deletedInvoiceItems).insertOnConflictUpdate(
          DeletedInvoiceItemsCompanion(
            id: drift.Value(entry.id),
            invoiceId: drift.Value(entry.invoiceId),
            productId: drift.Value(entry.productId),
            unitType: drift.Value(entry.unitType),
            quantity: drift.Value(entry.quantity),
            pricePerPiece: drift.Value(entry.pricePerPiece),
            subtotal: drift.Value(entry.subtotal),
            isFree: drift.Value(entry.isFree),
            deletedAt: drift.Value(entry.deletedAt),
          ),
        ));
  }

  /// Returns the deletion history for an invoice, most recent first.
  Future<List<DeletedInvoiceItem>> getDeletedItems(String invoiceId) async {
    if (isOnline) {
      try {
        final data = await Supabase.instance.client
            .from('deleted_invoice_items')
            .select()
            .eq('invoice_id', invoiceId)
            .order('deleted_at', ascending: false);
        return (data as List)
            .map((j) => DeletedInvoiceItem.fromJson(j))
            .toList();
      } catch (e) {
        debugPrint('getDeletedItems Supabase failed: $e. Falling back to local.');
      }
    }
    final rows = await (db.select(db.deletedInvoiceItems)
          ..where((t) => t.invoiceId.equals(invoiceId))
          ..orderBy([(t) => drift.OrderingTerm.desc(t.deletedAt)]))
        .get();
    return rows
        .map((r) => DeletedInvoiceItem(
              id: r.id,
              invoiceId: r.invoiceId,
              productId: r.productId,
              unitType: r.unitType,
              quantity: r.quantity,
              pricePerPiece: r.pricePerPiece,
              subtotal: r.subtotal,
              isFree: r.isFree,
              deletedAt: r.deletedAt,
            ))
        .toList();
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
      // invoice_payments has a FK to invoices — must be removed before the invoice row
      await Supabase.instance.client
          .from('invoice_payments')
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

  /// Soft-cancels an invoice: sets status to 'cancelled' and, if it was
  /// printed, restores the ordered stock to inventory. The invoice and its
  /// items remain in the database and can be viewed via [getCancelled] or
  /// brought back via [restoreInvoice].
  Future<void> cancelInvoice(Invoice invoice) async {
    if (invoice.status == 'printed') {
      final items = await getItems(invoice.id);
      for (final item in items) {
        await inventoryRepo.adjust(
          productId: item.productId,
          deltaPieces: item.quantity, // restore deducted stock
        );
      }
    }
    final updated = {'status': 'cancelled'};
    if (isOnline) {
      await Supabase.instance.client
          .from('invoices')
          .update(updated)
          .eq('id', invoice.id);
    } else {
      await syncService.enqueue(
        tableName: 'invoices',
        recordId: invoice.id,
        operation: 'update',
        payload: updated,
      );
    }
    await (db.update(db.invoices)..where((t) => t.id.equals(invoice.id)))
        .write(const InvoicesCompanion(status: drift.Value('cancelled')));
  }

  /// Restores a cancelled invoice back to 'printed' and re-deducts its
  /// items' quantities from inventory (reversing [cancelInvoice]).
  Future<void> restoreInvoice(Invoice invoice) async {
    final items = await getItems(invoice.id);
    for (final item in items) {
      await inventoryRepo.adjust(
        productId: item.productId,
        deltaPieces: -item.quantity, // re-deduct stock
      );
    }
    final updated = {'status': 'printed'};
    if (isOnline) {
      await Supabase.instance.client
          .from('invoices')
          .update(updated)
          .eq('id', invoice.id);
    } else {
      await syncService.enqueue(
        tableName: 'invoices',
        recordId: invoice.id,
        operation: 'update',
        payload: updated,
      );
    }
    await (db.update(db.invoices)..where((t) => t.id.equals(invoice.id)))
        .write(const InvoicesCompanion(status: drift.Value('printed')));
  }

  /// Returns all cancelled invoices, most recently dated first.
  Future<List<Invoice>> getCancelled() async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('invoices')
          .select()
          .eq('status', 'cancelled')
          .order('invoice_date', ascending: false);
      return (data as List).map((j) => Invoice.fromJson(j)).toList();
    }
    final rows = await (db.select(db.invoices)
          ..where((t) => t.status.equals('cancelled'))
          ..orderBy([(t) => drift.OrderingTerm.desc(t.invoiceDate)]))
        .get();
    return rows.map(_invoiceFromRow).toList();
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
          sequenceNumber: drift.Value(inv.sequenceNumber),
          invoiceType:   drift.Value(inv.invoiceType),
          paymentType:    drift.Value(inv.paymentType),
          partialAmount:  drift.Value(inv.partialAmount),
          partialDate:    drift.Value(inv.partialDate),
          checkReference: drift.Value(inv.checkReference),
          checkAmount:    drift.Value(inv.checkAmount),
          checkIssuedDate: drift.Value(inv.checkIssuedDate),
          checkDueDate:   drift.Value(inv.checkDueDate),
          notes: drift.Value(inv.notes),
          actualAmount: drift.Value(inv.actualAmount),
          includeInLayout: drift.Value(inv.includeInLayout),
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
          isFree: drift.Value(item.isFree),
          discountPercent: drift.Value(item.discountPercent),
        ));
  }

  /// Returns IDs of clients that have at least one printed invoice that is
  /// either (a) payment type 'credit', or (b) payment type 'partial' with
  /// an outstanding balance (total > sum of payments).
  Future<Set<String>> getPendingCheckCreditClientIds() async {
    final clientIds = <String>{};

    if (isOnline) {
      try {
        // Credit invoices — entire amount is still outstanding.
        final creditData = await Supabase.instance.client
            .from('invoices')
            .select('client_id')
            .eq('status', 'printed')
            .eq('payment_type', 'credit');
        for (final e in creditData as List) {
          clientIds.add(e['client_id'] as String);
        }

        // Partial invoices — outstanding only if total > sum(payments).
        final partialData = await Supabase.instance.client
            .from('invoices')
            .select('client_id, total_amount, invoice_payments(amount)')
            .eq('status', 'printed')
            .eq('payment_type', 'partial');
        for (final inv in partialData as List) {
          final total = (inv['total_amount'] as num).toDouble();
          final payments = inv['invoice_payments'] as List;
          final paid = payments.fold<double>(
              0.0, (s, p) => s + (p['amount'] as num).toDouble());
          if (total - paid > 0.01) clientIds.add(inv['client_id'] as String);
        }

        return clientIds;
      } catch (e) {
        debugPrint(
            'getPendingCheckCreditClientIds Supabase failed: $e. Falling back to local.');
        clientIds.clear();
      }
    }

    // ── Offline (Drift) ──────────────────────────────────────────────────────
    final printedInvoices = await (db.select(db.invoices)
          ..where((t) => t.status.equals('printed')))
        .get();

    // Credit: full balance outstanding.
    for (final r in printedInvoices) {
      if (r.paymentType == 'credit') clientIds.add(r.clientId);
    }

    // Partial: compare total vs. sum of payments.
    final partials = printedInvoices
        .where((r) => r.paymentType == 'partial')
        .toList();
    if (partials.isNotEmpty) {
      final partialIds = partials.map((r) => r.id).toList();
      final allPayments = await (db.select(db.invoicePayments)
            ..where((t) => t.invoiceId.isIn(partialIds)))
          .get();
      final paidByInvoice = <String, double>{};
      for (final p in allPayments) {
        paidByInvoice[p.invoiceId] =
            (paidByInvoice[p.invoiceId] ?? 0.0) + p.amount;
      }
      for (final r in partials) {
        final paid = paidByInvoice[r.id] ?? 0.0;
        if (r.totalAmount - paid > 0.01) clientIds.add(r.clientId);
      }
    }

    return clientIds;
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

/// Unfiltered list â€” used for invalidation and the detail screen lookup.
final invoicesListProvider = FutureProvider<List<Invoice>>((ref) {
  return ref.watch(invoiceRepositoryProvider).getAll();
});

/// Draft invoices (status == 'draft') â€” used to offer resuming unfinished
/// invoices from the Invoices list.
final draftInvoicesProvider = FutureProvider<List<Invoice>>((ref) {
  return ref.watch(invoiceRepositoryProvider).getDrafts();
});

final cancelledInvoicesProvider = FutureProvider<List<Invoice>>((ref) {
  return ref.watch(invoiceRepositoryProvider).getCancelled();
});

final deletedInvoiceItemsProvider =
    FutureProvider.family<List<DeletedInvoiceItem>, String>((ref, invoiceId) {
  return ref.watch(invoiceRepositoryProvider).getDeletedItems(invoiceId);
});

/// Date-range filtered list â€” keyed on (startDate, endDate); null = no bound.
final filteredInvoicesProvider =
    FutureProvider.family<List<Invoice>, (DateTime?, DateTime?)>((ref, range) {
  final (start, end) = range;
  return ref
      .watch(invoiceRepositoryProvider)
      .getAll(startDate: start, endDate: end);
});

