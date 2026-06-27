import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show DailyActivityData;
import 'package:memox_v4/domain/entities/daily_activity.dart';

/// Maps a Drift `daily_activity` row to the domain [DailyActivity].
DailyActivity mapDailyActivity(DailyActivityData row) => DailyActivity(
  day: row.day,
  pairId: row.pairId,
  seconds: row.seconds,
  words: row.words,
);
