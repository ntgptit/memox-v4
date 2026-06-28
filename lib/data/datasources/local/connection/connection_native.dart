import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const String _databaseFileName = 'memox.sqlite';

/// Mobile/desktop: native sqlite3 via dart:ffi, file on disk.
QueryExecutor openLocalDatabase() => LazyDatabase(() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, _databaseFileName));
  return NativeDatabase.createInBackground(file);
});

QueryExecutor openInMemoryDatabase() => NativeDatabase.memory();
