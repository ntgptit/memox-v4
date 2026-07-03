import 'package:drift/drift.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/data/models/mappers/time_mapper.dart';
import 'package:memox_v4/domain/entities/study_session.dart';
import 'package:memox_v4/domain/services/daily_activity_service.dart';

/// Drift-backed [DailyActivityService] (DT.7). `record` stores the finished
/// session and folds its minutes + words into its calendar-day roll-up (one
/// transaction, D-010); `activityOn` reads a day; `watchHistory` streams the
/// roll-up for the streak + heatmap. The day key is the UTC midnight of the
/// session's `startedAt`, matching `streakFromHistory`.
class DriftDailyActivityService implements DailyActivityService {
  DriftDailyActivityService(this._db);

  final AppDatabase _db;

  @override
  Future<Result<void>> record(StudySession session) => guardAsync(() async {
        await _db.transaction(() async {
          await _db.into(_db.studySessions).insert(
                StudySessionsCompanion.insert(
                  id: session.id.value,
                  deckId: session.deckId.value,
                  mode: session.mode.name,
                  startedAt: dateTimeToMicros(session.startedAt)!,
                  durationMinutes: session.durationMinutes,
                  wordsStudied: session.wordsStudied,
                ),
                mode: InsertMode.insertOrReplace,
              );

          final dayKey = _dayKey(session.startedAt);
          final existing = await (_db.select(_db.dailyActivity)
                ..where((a) => a.day.equals(dayKey)))
              .getSingleOrNull();
          await _db.into(_db.dailyActivity).insertOnConflictUpdate(
                DailyActivityCompanion.insert(
                  day: Value(dayKey),
                  minutes:
                      Value((existing?.minutes ?? 0) + session.durationMinutes),
                  words: Value((existing?.words ?? 0) + session.wordsStudied),
                ),
              );
        });
      });

  @override
  Future<Result<({int minutes, int words})>> activityOn(DateTime day) =>
      guardAsync(() async {
        final row = await (_db.select(_db.dailyActivity)
              ..where((a) => a.day.equals(_dayKey(day))))
            .getSingleOrNull();
        return (minutes: row?.minutes ?? 0, words: row?.words ?? 0);
      });

  @override
  Stream<Map<DateTime, ({int minutes, int words})>> watchHistory() {
    return _db.select(_db.dailyActivity).watch().map((rows) => {
          for (final row in rows)
            microsToDateTime(row.day)!: (minutes: row.minutes, words: row.words),
        });
  }

  /// UTC midnight of [dt]'s day, in microseconds — the `daily_activity.day` key.
  int _dayKey(DateTime dt) {
    final utc = dt.toUtc();
    return DateTime.utc(utc.year, utc.month, utc.day).microsecondsSinceEpoch;
  }
}
