import 'package:drift/drift.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';

/// Typed access to `daily_activity` (PK day + pair_id). Adds are cumulative.
class DailyActivityDao {
  const DailyActivityDao(this._db);

  final AppDatabase _db;

  Future<DailyActivityData?> forDay(int pairId, String day) =>
      (_db.select(_db.dailyActivity)
            ..where((t) => t.pairId.equals(pairId) & t.day.equals(day)))
          .getSingleOrNull();

  Future<List<DailyActivityData>> allForPair(int pairId) => (_db.select(
    _db.dailyActivity,
  )..where((t) => t.pairId.equals(pairId))).get();

  Future<void> add({
    required int pairId,
    required String day,
    required int seconds,
    required int words,
  }) async {
    final existing = await forDay(pairId, day);
    await _db
        .into(_db.dailyActivity)
        .insertOnConflictUpdate(
          DailyActivityCompanion.insert(
            day: day,
            pairId: pairId,
            seconds: Value((existing?.seconds ?? 0) + seconds),
            words: Value((existing?.words ?? 0) + words),
          ),
        );
  }
}
