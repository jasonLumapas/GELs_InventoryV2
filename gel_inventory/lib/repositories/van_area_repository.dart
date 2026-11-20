import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/database/local_db.dart' hide VanArea;
import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import '../models/van_area.dart';
import 'base_repository.dart';

class VanAreaRepository extends BaseRepository {
  VanAreaRepository({
    required super.db,
    required super.connectivity,
    required super.syncService,
  });

  Future<List<VanArea>> getAll() async {
    if (isOnline) {
      try {
        final data = await Supabase.instance.client
            .from('van_areas')
            .select()
            .order('name');
        return (data as List).map((j) => VanArea.fromJson(j)).toList();
      } catch (_) {}
    }
    final rows = await (db.select(db.vanAreas)
          ..orderBy([(t) => drift.OrderingTerm.asc(t.name)]))
        .get();
    return rows.map((r) => VanArea(id: r.id, name: r.name)).toList();
  }

  Future<VanArea> add(String name) async {
    final area = VanArea(id: const Uuid().v4(), name: name.trim());
    final payload = area.toJson();
    if (isOnline) {
      try {
        await Supabase.instance.client.from('van_areas').insert(payload);
      } catch (_) {}
    } else {
      await syncService.enqueue(
        tableName: 'van_areas',
        recordId: area.id,
        operation: 'insert',
        payload: payload,
      );
    }
    await trySaveLocal(() => db.into(db.vanAreas).insert(
          VanAreasCompanion(
            id: drift.Value(area.id),
            name: drift.Value(area.name),
          ),
        ));
    return area;
  }

  Future<void> delete(String id) async {
    if (isOnline) {
      try {
        await Supabase.instance.client
            .from('van_areas')
            .delete()
            .eq('id', id);
      } catch (_) {}
    } else {
      await syncService.enqueue(
        tableName: 'van_areas',
        recordId: id,
        operation: 'delete',
        payload: {'id': id},
      );
    }
    await (db.delete(db.vanAreas)..where((t) => t.id.equals(id))).go();
  }
}

final vanAreaRepositoryProvider = Provider<VanAreaRepository>((ref) =>
    VanAreaRepository(
      db: ref.watch(localDatabaseProvider),
      connectivity: ref.watch(connectivityServiceProvider),
      syncService: ref.watch(syncServiceProvider),
    ));
