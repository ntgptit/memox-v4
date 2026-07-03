import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_provider.g.dart';

/// The on-disk database file name.
const String _dbFileName = 'memox.sqlite';

/// The single app-wide [AppDatabase] (Drift), opened lazily on a file in the
/// application-documents directory. Kept alive for the whole session and closed
/// on dispose. Tests override this provider with `AppDatabase.memory()`, so the
/// file/plugin path never runs under `flutter test`.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase(
    LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, _dbFileName));
      return NativeDatabase.createInBackground(file);
    }),
  );
  ref.onDispose(db.close);
  return db;
}
