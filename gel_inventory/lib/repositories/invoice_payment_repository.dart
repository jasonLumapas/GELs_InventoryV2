import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/database/local_db.dart' hide InvoicePayment;
import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import '../models/invoice_payment.dart';
import 'base_repository.dart';

class InvoicePaymentRepository extends BaseRepository {
  InvoicePaymentRepository({
    required super.db,
    required super.connectivity,
    required super.syncService,
  });

  Future<List<InvoicePayment>> getForInvoice(String invoiceId) async {
    if (isOnline) {
      try {
        final data = await Supabase.instance.client
            .from('invoice_payments')
            .select()
            .eq('invoice_id', invoiceId)
            .order('payment_date', ascending: true);
        return (data as List).map((j) => InvoicePayment.fromJson(j)).toList();
      } catch (_) {}
    }
    final rows = await (db.select(db.invoicePayments)
          ..where((t) => t.invoiceId.equals(invoiceId))
          ..orderBy([(t) => drift.OrderingTerm.asc(t.paymentDate)]))
        .get();
    return rows
        .map((r) => InvoicePayment(
              id: r.id,
              invoiceId: r.invoiceId,
              amount: r.amount,
              paymentDate: r.paymentDate,
              notes: r.notes,
              createdAt: r.createdAt,
            ))
        .toList();
  }

  Future<void> add(InvoicePayment payment) async {
    final payload = payment.toJson();
    if (isOnline) {
      try {
        await Supabase.instance.client
            .from('invoice_payments')
            .insert(payload);
      } catch (_) {}
    } else {
      await syncService.enqueue(
        tableName: 'invoice_payments',
        recordId: payment.id,
        operation: 'insert',
        payload: payload,
      );
    }
    await trySaveLocal(() => db.into(db.invoicePayments).insert(
          InvoicePaymentsCompanion(
            id: drift.Value(payment.id),
            invoiceId: drift.Value(payment.invoiceId),
            amount: drift.Value(payment.amount),
            paymentDate: drift.Value(payment.paymentDate),
            notes: drift.Value(payment.notes),
            createdAt: drift.Value(payment.createdAt),
          ),
        ));
  }

  Future<void> delete(String id) async {
    if (isOnline) {
      try {
        await Supabase.instance.client
            .from('invoice_payments')
            .delete()
            .eq('id', id);
      } catch (_) {}
    } else {
      await syncService.enqueue(
        tableName: 'invoice_payments',
        recordId: id,
        operation: 'delete',
        payload: {'id': id},
      );
    }
    await (db.delete(db.invoicePayments)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}

final invoicePaymentRepositoryProvider =
    Provider<InvoicePaymentRepository>((ref) => InvoicePaymentRepository(
          db: ref.watch(localDatabaseProvider),
          connectivity: ref.watch(connectivityServiceProvider),
          syncService: ref.watch(syncServiceProvider),
        ));
