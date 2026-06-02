import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/database/local_db.dart' hide Client;
import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import '../models/client.dart';
import 'base_repository.dart';

class ClientRepository extends BaseRepository {
  ClientRepository({
    required super.db,
    required super.connectivity,
    required super.syncService,
  });

  Future<List<Client>> getAll() async {
    if (isOnline) {
      final data = await Supabase.instance.client
          .from('clients')
          .select()
          .order('name');
      final clients = (data as List).map((j) => Client.fromJson(j)).toList();
      for (final c in clients) {
        await trySaveLocal(() => _saveLocal(c));
      }
      return clients;
    }
    final rows = await (db.select(db.clients)
          ..orderBy([(t) => drift.OrderingTerm.asc(t.name)]))
        .get();
    return rows
        .map((r) => Client(
              id: r.id,
              name: r.name,
              address: r.address,
              createdAt: r.createdAt,
            ))
        .toList();
  }

  Future<void> upsert(Client client) async {
    final payload = client.toJson();
    if (isOnline) {
      await Supabase.instance.client.from('clients').upsert(payload);
    } else {
      await syncService.enqueue(
        tableName: 'clients',
        recordId: client.id,
        operation: 'insert',
        payload: payload,
      );
    }
    await trySaveLocal(() => _saveLocal(client));
  }

  Future<void> delete(String id) async {
    if (isOnline) {
      await Supabase.instance.client.from('clients').delete().eq('id', id);
    } else {
      await syncService.enqueue(
        tableName: 'clients',
        recordId: id,
        operation: 'delete',
        payload: {'id': id},
      );
    }
    await (db.delete(db.clients)..where((t) => t.id.equals(id))).go();
  }

  Future<void> _saveLocal(Client c) async {
    await db.into(db.clients).insertOnConflictUpdate(ClientsCompanion(
          id: drift.Value(c.id),
          name: drift.Value(c.name),
          address: drift.Value(c.address),
          createdAt: drift.Value(c.createdAt),
        ));
  }
}

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepository(
    db: ref.watch(localDatabaseProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    syncService: ref.watch(syncServiceProvider),
  );
});

final clientsListProvider = FutureProvider<List<Client>>((ref) {
  return ref.watch(clientRepositoryProvider).getAll();
});
