/// One day of recorded effort.
typedef ActivityPoint = ({String day, int seconds, int words});

/// Cards in a Leitner box (box 0 = new/no schedule).
typedef BoxCount = ({int box, int count});

/// Raw statistics aggregates for a scope (`pairId == null` → whole app). The
/// day-bucketing into forecast/heatmap happens in the use case (it has the clock).
typedef StatsRaw = ({
  int pairs,
  int decks,
  List<BoxCount> boxes,
  List<int> dueAts,
  List<ActivityPoint> activity,
});

/// Aggregated learning statistics for a scope (`docs/business/statistics/statistics.md`).
/// Derived from `card`/`srs_state`/`daily_activity`; no persisted entity.
class StatisticsSummary {
  const StatisticsSummary({
    required this.pairs,
    required this.decks,
    required this.words,
    required this.mastered,
    required this.boxCounts,
    required this.dueForecast,
    required this.activity,
    required this.totalSeconds,
    required this.totalWords,
  });

  /// Empty/insufficient summary.
  static const StatisticsSummary empty = StatisticsSummary(
    pairs: 0,
    decks: 0,
    words: 0,
    mastered: 0,
    boxCounts: <int>[0, 0, 0, 0, 0, 0, 0, 0, 0],
    dueForecast: <int>[0, 0, 0, 0, 0, 0, 0],
    activity: <ActivityPoint>[],
    totalSeconds: 0,
    totalWords: 0,
  );

  final int pairs;
  final int decks;

  /// Visible (non-hidden) cards in scope.
  final int words;

  /// Mastered (box 8) cards in scope.
  final int mastered;

  /// Cards per Leitner box: index 0 = new (no schedule), 1..8 = boxes.
  final List<int> boxCounts;

  /// Cards becoming due on each of the next 7 days (index 0 = today).
  final List<int> dueForecast;

  /// Recent daily activity (oldest → newest), for the activity chart.
  final List<ActivityPoint> activity;

  final int totalSeconds;
  final int totalWords;

  double get masteredProgress => words == 0 ? 0 : mastered / words;

  /// Too little data to render meaningful charts.
  bool get hasEnoughData => words > 0;
}
