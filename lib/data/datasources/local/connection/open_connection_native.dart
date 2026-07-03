import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// The on-disk database file name (native platforms).
const String _dbFileName = 'memox.sqlite';

/// Native (mobile / desktop / VM): a lazily-opened `NativeDatabase` on a file in
/// the application-documents directory, run on a background isolate.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, _dbFileName));
    return NativeDatabase.createInBackground(file);
  });
}
