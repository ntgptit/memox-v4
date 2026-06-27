import 'package:drift/drift.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';

/// Typed access to the `language_pair` table and the two pair-context keys in
/// the flat `settings` store. Returns Drift rows; mapping to domain entities is
/// the repository's job (`docs/database/schema-contract.md`).
class LanguagePairDao {
  const LanguagePairDao(this._db);

  final AppDatabase _db;

  /// All pairs ordered by `order_index`.
  Future<List<LanguagePairData>> allPairs() =>
      (_db.select(_db.languagePair)
            ..orderBy(<OrderClauseGenerator<LanguagePair>>[
              (t) => OrderingTerm(expression: t.orderIndex),
            ]))
          .get();

  Future<int> countPairs() async {
    final rows = await _db.select(_db.languagePair).get();
    return rows.length;
  }

  Future<LanguagePairData> insertPair({
    required String sourceLang,
    required String targetLang,
    required int orderIndex,
  }) async {
    final id = await _db
        .into(_db.languagePair)
        .insert(
          LanguagePairCompanion.insert(
            sourceLang: sourceLang,
            targetLang: targetLang,
            orderIndex: Value(orderIndex),
          ),
        );
    return (_db.select(
      _db.languagePair,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> deletePair(int id) =>
      (_db.delete(_db.languagePair)..where((t) => t.id.equals(id))).go();

  /// Reads a flat setting value, or null when the key is unset.
  Future<String?> readSetting(String key) async {
    final row = await (_db.select(
      _db.settings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  /// Upserts a flat setting value.
  Future<void> writeSetting(String key, String value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(
        SettingsCompanion.insert(key: key, value: Value(value)),
      );
}
