import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/core/util/day_key.dart';
import 'package:memox_v4/domain/models/statistics_summary.dart';
import 'package:memox_v4/domain/repositories/statistics_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Builds the statistics read-model for a scope. Box distribution and library
/// counts come from the repository; the due forecast and the activity window are
/// bucketed here against the injected clock (BR-3).
class GetStatisticsUseCase {
  const GetStatisticsUseCase(this._repository, this._clock);

  static const int _forecastDays = 7;
  static const int _activityWindow = 84; // 12 weeks for the heatmap

  final StatisticsRepository _repository;
  final Clock _clock;

  Future<Result<StatisticsSummary>> call({required int? pairId}) async {
    final now = _clock.now();
    final today = DateTime(now.year, now.month, now.day);
    // Only the last [_activityWindow] days feed the heatmap; bound the query so a
    // long history isn't fetched whole (lifetime totals come from a SUM).
    final since = dayKey(
      today.subtract(const Duration(days: _activityWindow - 1)),
    );
    final result = await _repository.read(pairId, activitySince: since);
    return result.map((raw) => _build(raw, today));
  }

  StatisticsSummary _build(StatsRaw raw, DateTime today) {
    final boxCounts = List<int>.filled(9, 0);
    for (final entry in raw.boxes) {
      if (entry.box >= 0 && entry.box <= 8) boxCounts[entry.box] = entry.count;
    }
    final words = boxCounts.fold<int>(0, (sum, n) => sum + n);
    final mastered = boxCounts[8];

    final forecast = List<int>.filled(_forecastDays, 0);
    for (final dueAt in raw.dueAts) {
      final due = DateTime.fromMillisecondsSinceEpoch(dueAt);
      final dueDay = DateTime(due.year, due.month, due.day);
      var offset = dueDay.difference(today).inDays;
      if (offset < 0) offset = 0;
      if (offset < _forecastDays) forecast[offset]++;
    }

    final byDay = <String, ActivityPoint>{
      for (final a in raw.activity) a.day: a,
    };
    final activity = <ActivityPoint>[];
    for (var i = _activityWindow - 1; i >= 0; i--) {
      final key = dayKey(today.subtract(Duration(days: i)));
      activity.add(byDay[key] ?? (day: key, seconds: 0, words: 0));
    }

    return StatisticsSummary(
      pairs: raw.pairs,
      decks: raw.decks,
      words: words,
      mastered: mastered,
      boxCounts: boxCounts,
      dueForecast: forecast,
      activity: activity,
      totalSeconds: raw.totalSeconds,
      totalWords: raw.totalWords,
      accuracyCorrect: raw.accuracyCorrect,
      accuracyTotal: raw.accuracyTotal,
    );
  }
}
