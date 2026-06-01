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

  bool get isOnline => connectivity.isOnline;
}
