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

  /// Fixed id/name for the placeholder client used by Bad Orders / Returns
  /// when no client is specified.
  static const noClientId = '00000000-0000-0000-0000-000000000000';
  static const noClientName = 'No Client Specified';

  /// Returns the "No Client Specified" placeholder client, creating it if
  /// it doesn't exist yet.
  Future<Client> getOrCreateNoClientPlaceholder() async {
    final all = await getAll();
    for (final c in all) {
      if (c.id == noClientId) return c;
    }
    final placeholder = Client(
      id: noClientId,
      name: noClientName,
      address: null,
      createdAt: DateTime.now(),
    );
    await upsert(placeholder);
    return placeholder;
  }

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
