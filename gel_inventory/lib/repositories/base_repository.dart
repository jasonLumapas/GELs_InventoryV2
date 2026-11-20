import '../core/constants.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import '../core/database/local_db.dart';

abstract class BaseRepository {
  final LocalDatabase db;
  final ConnectivityService connectivity;
  final SyncService syncService;

  const BaseRepository({
    required this.db,
    required this.connectivity,
    required this.syncService,
  });

  bool get isOnline => !AppConstants.offlineOnly && connectivity.isOnline;

  /// Runs a local cache write and silently swallows any SQLite error.
  /// When online, Supabase is the source of truth, so a cache failure
  /// should never crash the app.
  Future<void> trySaveLocal(Future<void> Function() write) async {
    try {
      await write();
    } catch (_) {
      // Local write failed (e.g. readonly DB on first run); ignore when online.
    }
  }
}
