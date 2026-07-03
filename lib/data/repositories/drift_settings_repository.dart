import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/domain/entities/daily_goal.dart';
import 'package:memox_v4/domain/repositories/settings_repository.dart';

/// Settings keys (schema contract §settings).
const String _kGoalMinutes = 'goal.minutes_target';
const String _kGoalWords = 'goal.words_target';
const String _kNewPerDay = 'srs.new_cards_per_day';

/// The default new-cards-per-day allowance when unset (D-018).
const int _defaultNewPerDay = 20;

/// Drift-backed [SettingsRepository] (DT.4) over the `settings` key–value table.
/// `watch*` streams re-emit on any settings write. A [DailyGoal] maps to two
/// keys (either may be unset → the row is absent). Failures wrap as [Failure].
class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<DailyGoal> watchDailyGoal() => _watchKeys([_kGoalMinutes, _kGoalWords])
      .map((values) => DailyGoal(
            minutesTarget: _int(values[_kGoalMinutes]),
            wordsTarget: _int(values[_kGoalWords]),
          ));

  @override
  Future<Result<void>> saveDailyGoal(DailyGoal goal) => guardAsync(() async {
        await _db.transaction(() async {
          await _put(_kGoalMinutes, goal.minutesTarget?.toString());
          await _put(_kGoalWords, goal.wordsTarget?.toString());
        });
      });

  @override
  Stream<int> watchNewCardsPerDay() => _watchKeys([_kNewPerDay])
      .map((values) => _int(values[_kNewPerDay]) ?? _defaultNewPerDay);

  @override
  Future<Result<void>> saveNewCardsPerDay(int count) =>
      guardAsync(() async => _put(_kNewPerDay, count.toString()));

  /// Watches the given keys, emitting a `{key: value}` map (missing keys absent).
  Stream<Map<String, String>> _watchKeys(List<String> keys) {
    final query = _db.select(_db.settings)..where((s) => s.key.isIn(keys));
    return query
        .watch()
        .map((rows) => {for (final row in rows) row.key: row.value});
  }

  /// Upsert (value != null) or delete (value == null) a single key.
  Future<void> _put(String key, String? value) async {
    if (value == null) {
      await (_db.delete(_db.settings)..where((s) => s.key.equals(key))).go();
      return;
    }
    await _db.into(_db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: value),
        );
  }

  int? _int(String? value) => value == null ? null : int.tryParse(value);
}
