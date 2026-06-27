import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';

/// App-wide handle to the local database. Kept alive for the app's lifetime
/// (the connection is expensive and shared); closed when the container is
/// disposed. Feature repositories read their DAOs off this single instance.
///
/// Tests override this with `AppDatabase.forTesting(openInMemoryDatabase())`.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
