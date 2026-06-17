import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/database/local_db.dart' hide Supplier;
import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import '../models/supplier.dart';
import 'base_repository.dart';

class SupplierRepository extends BaseRepository {
  SupplierRepository({
    required super.db,
    required super.connectivity,
    required super.syncService,
  });

  Future<List<Supplier>> getAll() async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('suppliers')
          .select()
          .order('name');
      final suppliers =
          (data as List).map((j) => Supplier.fromJson(j)).toList();
      await Future.wait(suppliers.map((s) => trySaveLocal(() => _saveLocal(s))));
      return suppliers;
    }
    final rows = await (db.select(db.suppliers)
          ..orderBy([(t) => drift.OrderingTerm.asc(t.name)]))
        .get();
    return rows
        .map((r) => Supplier(
              id: r.id,
              name: r.name,
              contact: r.contact,
              address: r.address,
              createdAt: r.createdAt,
            ))
        .toList();
  }

  Future<void> upsert(Supplier supplier) async {
    final payload = supplier.toJson();
    if (isOnline) {
      await Supabase.instance.client.from('suppliers').upsert(payload);
    } else {
      await syncService.enqueue(
        tableName: 'suppliers',
        recordId: supplier.id,
        operation: 'insert',
        payload: payload,
      );
    }
    await trySaveLocal(() => _saveLocal(supplier));
  }

  Future<void> delete(String id) async {
    if (isOnline) {
      await Supabase.instance.client.from('suppliers').delete().eq('id', id);
    } else {
      await syncService.enqueue(
        tableName: 'suppliers',
        recordId: id,
        operation: 'delete',
        payload: {'id': id},
      );
    }
    await (db.delete(db.suppliers)..where((t) => t.id.equals(id))).go();
  }

  Future<void> _saveLocal(Supplier s) async {
    await db.into(db.suppliers).insertOnConflictUpdate(SuppliersCompanion(
          id: drift.Value(s.id),
          name: drift.Value(s.name),
          contact: drift.Value(s.contact),
          address: drift.Value(s.address),
          createdAt: drift.Value(s.createdAt),
        ));
  }
}

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return SupplierRepository(
    db: ref.watch(localDatabaseProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    syncService: ref.watch(syncServiceProvider),
  );
});

final suppliersListProvider = FutureProvider<List<Supplier>>((ref) {
  return ref.watch(supplierRepositoryProvider).getAll();
});

String newId() => const Uuid().v4();
