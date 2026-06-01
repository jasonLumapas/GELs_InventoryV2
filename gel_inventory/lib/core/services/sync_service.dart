import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../database/local_db.dart';
import 'connectivity_service.dart';

class SyncService {
  final LocalDatabase _db;
  final SupabaseClient _supabase;
  final ConnectivityService _connectivity;

  SyncService(this._db, this._supabase, this._connectivity) {
    _connectivity.onlineStream.listen((online) {
      if (online) _drainQueue();
    });
  }

  Future<void> enqueue({
    required String tableName,
    required String recordId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    await _db.into(_db.syncQueue).insert(SyncQueueCompanion(
          id: drift.Value(const Uuid().v4()),
          targetTable: drift.Value(tableName),
          recordId: drift.Value(recordId),
          operation: drift.Value(operation),
          payload: drift.Value(jsonEncode(payload)),
        ));
  }

  Future<void> _drainQueue() async {
    final items = await (_db.select(_db.syncQueue)
          ..orderBy([(t) => drift.OrderingTerm.asc(t.createdAt)]))
        .get();

    for (final item in items) {
      try {
        final payload = jsonDecode(item.payload) as Map<String, dynamic>;
        switch (item.operation) {
          case 'insert':
            await _supabase.from(item.targetTable).upsert(payload);
          case 'update':
            await _supabase
                .from(item.targetTable)
                .update(payload)
                .eq('id', item.recordId);
          case 'delete':
            await _supabase
                .from(item.targetTable)
                .delete()
                .eq('id', item.recordId);
        }
        await (_db.delete(_db.syncQueue)
              ..where((t) => t.id.equals(item.id)))
            .go();
      } catch (_) {
        // Leave in queue if sync fails; retry next reconnect
        break;
      }
    }
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(localDatabaseProvider);
  final supabase = Supabase.instance.client;
  final connectivity = ref.watch(connectivityServiceProvider);
  return SyncService(db, supabase, connectivity);
});

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  final db = LocalDatabase();
  ref.onDispose(db.close);
  return db;
});
