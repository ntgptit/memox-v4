import 'package:drift/drift.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';

/// Read/write access to the flat `settings` key-value store.
class SettingsDao {
  const SettingsDao(this._db);

  final AppDatabase _db;

  Future<String?> read(String key) async {
    final row = await (_db.select(
      _db.settings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<Map<String, String>> readAll() async {
    final rows = await _db.select(_db.settings).get();
    return <String, String>{
      for (final r in rows)
        if (r.value != null) r.key: r.value!,
    };
  }

  Future<void> write(String key, String value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(
        SettingsCompanion.insert(key: key, value: Value(value)),
      );

  Future<void> remove(String key) =>
      (_db.delete(_db.settings)..where((t) => t.key.equals(key))).go();
}
