import 'package:memox_v4/data/datasources/local/drift/app_database.dart';

/// Read access to the flat `settings` key-value store.
class SettingsDao {
  const SettingsDao(this._db);

  final AppDatabase _db;

  Future<String?> read(String key) async {
    final row = await (_db.select(
      _db.settings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }
}
