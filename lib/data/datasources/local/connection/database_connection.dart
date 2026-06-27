import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Where the app's SQLite file lives, relative to the app documents dir.
const String _databaseFileName = 'memox.sqlite';

/// Opens the production database lazily: the file is resolved (and sqlite
/// loaded) on first query, off the UI isolate. Used by the `databaseProvider`
/// composition root; features never open a connection themselves.
QueryExecutor openLocalDatabase() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, _databaseFileName));
    return NativeDatabase.createInBackground(file);
  });
}

/// An ephemeral in-memory database — for tests and throwaway probes only.
QueryExecutor openInMemoryDatabase() => NativeDatabase.memory();
