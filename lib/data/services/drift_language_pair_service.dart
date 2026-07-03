import 'package:drift/drift.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/utils/clock.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/data/models/mappers/language_pair_mapper.dart';
import 'package:memox_v4/data/models/mappers/time_mapper.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/language_pair.dart';
import 'package:memox_v4/domain/services/language_pair_service.dart';

/// Drift-backed [LanguagePairService] (DT.7) over the `language_pairs` table.
/// The "selected" pair is the single `is_active` row (D-030 single-pair v1);
/// `select` flips activity atomically. Removing a pair cascades its decks (FK).
class DriftLanguagePairService implements LanguagePairService {
  DriftLanguagePairService(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  @override
  Stream<List<LanguagePair>> watchAll() {
    final query = _db.select(_db.languagePairs)
      ..orderBy([(p) => OrderingTerm(expression: p.createdAt)]);
    return query
        .watch()
        .map((rows) => [for (final row in rows) languagePairFromRow(row)]);
  }

  @override
  Stream<LanguagePairId?> watchSelected() {
    final query = _db.select(_db.languagePairs)
      ..where((p) => p.isActive.equals(true));
    return query.watch().map((rows) =>
        rows.isEmpty ? null : LanguagePairId(rows.first.id));
  }

  @override
  Future<Result<void>> select(LanguagePairId id) => guardAsync(() async {
        await _db.transaction(() async {
          await _db.update(_db.languagePairs).write(
                const LanguagePairsCompanion(isActive: Value(false)),
              );
          await (_db.update(_db.languagePairs)
                ..where((p) => p.id.equals(id.value)))
              .write(const LanguagePairsCompanion(isActive: Value(true)));
        });
      });

  @override
  Future<Result<LanguagePair>> add(LanguagePair pair) => guardAsync(() async {
        await _db.into(_db.languagePairs).insert(
              LanguagePairsCompanion.insert(
                id: pair.id.value,
                learningLanguage: pair.learningLanguage,
                nativeLanguage: pair.nativeLanguage,
                createdAt: dateTimeToMicros(_clock.now())!,
              ),
            );
        return pair;
      });

  @override
  Future<Result<void>> remove(LanguagePairId id) => guardAsync(() async {
        // FK cascade drops the pair's decks + their cards/meanings/srs (D-024).
        await (_db.delete(_db.languagePairs)..where((p) => p.id.equals(id.value)))
            .go();
      });
}
