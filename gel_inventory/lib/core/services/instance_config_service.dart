import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

// Single optional config file placed next to the executable lets multiple
// copies of the app run side by side, each with its own local database and
// on-screen label. Format: one `key=value` pair per line, e.g.:
//   db_name=gel_inventory_b.sqlite
//   header_title=Branch B
// Blank lines and lines starting with # are ignored.
const _configFileName = 'instance_config.txt';

Future<Map<String, String>> _readConfig() async {
  try {
    final exeDir = File(Platform.resolvedExecutable).parent;
    final file = File(p.join(exeDir.path, _configFileName));
    if (!await file.exists()) return {};
    final map = <String, String>{};
    for (final line in await file.readAsLines()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final i = trimmed.indexOf('=');
      if (i <= 0) continue;
      final value = trimmed.substring(i + 1).trim();
      if (value.isNotEmpty) map[trimmed.substring(0, i).trim()] = value;
    }
    return map;
  } catch (_) {
    return {};
  }
}

// Resolves the local sqlite filename. Checked in order:
//   1. `db_name` entry in instance_config.txt
//   2. GEL_INVENTORY_DB_NAME environment variable
//   3. default 'gel_inventory.sqlite'
Future<String> resolveDbName() async {
  final fromFile = (await _readConfig())['db_name'];
  if (fromFile != null) return fromFile;

  final envName = Platform.environment['GEL_INVENTORY_DB_NAME'];
  if (envName != null && envName.trim().isNotEmpty) return envName.trim();

  return 'gel_inventory.sqlite';
}

// Optional per-installation label shown on every page's app bar, taken from
// the `header_title` entry in instance_config.txt.
final headerTitleProvider = FutureProvider<String?>(
    (ref) async => (await _readConfig())['header_title']);
