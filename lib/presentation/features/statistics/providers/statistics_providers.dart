import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/deck_stats.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/repositories/card_repository.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/domain/repositories/review_repository.dart';
import 'package:memox_v4/domain/usecases/stats/srs_stats.dart';
import 'package:memox_v4/domain/usecases/stats/streak_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'statistics_providers.g.dart';

/// How many weeks the study heatmap spans (kit `last 14 weeks`).
const int statsHeatmapWeeks = 14;
const int _daysPerWeek = 7;

/// The statistics view-model — everything the charts render.
class StatisticsData {
  const StatisticsData({
    required this.currentStreak,
    required this.longestStreak,
    required this.heatmapDays,
    required this.weeklyMinutes,
    required this.leitner,
    required this.masteryPercent,
    required this.totalCards,
    required this.masteredCards,
    required this.dueCards,
    required this.hasActivity,
  });

  final int currentStreak;
  final int longestStreak;

  /// Daily minutes for the last 14×7 days, oldest → newest (heatmap cells).
  final List<int> heatmapDays;

  /// Daily minutes for the last 7 days, oldest → newest (weekly bars).
  final List<int> weeklyMinutes;

  /// Cards per Leitner box 1..8.
  final Map<int, int> leitner;

  /// Mastered / visible fraction, 0..1.
  final double masteryPercent;
  final int totalCards;
  final int masteredCards;
  final int dueCards;

  /// Whether there is any recorded study activity (else the insufficient state).
  final bool hasActivity;
}

/// Assembles the statistics from the DM.5/stats use cases + the activity history.
/// An async notifier rendered with `AsyncValue.when`. A failed read throws its
/// [Failure] — surfaced localized by the screen and logged here; never swallowed.
///
/// Scope (This pair / All) and the accuracy chart are documented gaps: v1 has no
/// pair↔content link, and the frozen `ReviewRepository` exposes no review-log read
/// for accuracy. The donut shows **mastery** instead.
@riverpod
class StatisticsController extends _$StatisticsController {
  @override
  Future<StatisticsData> build() async {
    try {
      return await _load();
    } on Failure catch (failure, stackTrace) {
      ref.read(loggerProvider).error(
            'statistics load failed',
            error: failure,
            stackTrace: stackTrace,
          );
      rethrow;
    }
  }

  Future<StatisticsData> _load() async {
    final decks = ref.watch(deckRepositoryProvider);
    final cardsRepo = ref.watch(cardRepositoryProvider);
    final reviews = ref.watch(reviewRepositoryProvider);
    final activityService = ref.watch(dailyActivityServiceProvider);
    final settings = ref.watch(settingsRepositoryProvider);

    final now = ref.watch(clockProvider).now();
    final today = _day(now);

    final history = await activityService.watchHistory().first;
    final goal = await settings.watchDailyGoal().first;
    final streak = streakFromHistory(history: history, goal: goal, today: today);

    final heatmap = _daySeries(history, today, statsHeatmapWeeks * _daysPerWeek);
    final weekly = _daySeries(history, today, _daysPerWeek);

    final roots = await decks.watchChildren(null).first;
    var aggregate = DeckStats.empty;
    var dueTotal = 0;
    for (final deck in roots) {
      aggregate = aggregate + _value(await decks.statsFor(deck.id));
      dueTotal += _value(await reviews.dueQueue(within: deck.id, asOf: now)).length;
    }

    final states = await _collectStates(roots, decks, cardsRepo, reviews);
    final leitner = boxDistribution(states);

    final mastery = aggregate.visibleCount == 0
        ? 0.0
        : aggregate.masteredCount / aggregate.visibleCount;

    return StatisticsData(
      currentStreak: streak.current,
      longestStreak: streak.longest,
      heatmapDays: heatmap,
      weeklyMinutes: weekly,
      leitner: leitner,
      masteryPercent: mastery,
      totalCards: aggregate.visibleCount,
      masteredCards: aggregate.masteredCount,
      dueCards: dueTotal,
      hasActivity: history.isNotEmpty,
    );
  }

  /// Daily minutes for the [count] days ending today, oldest → newest.
  List<int> _daySeries(
    Map<DateTime, ({int minutes, int words})> history,
    DateTime today,
    int count,
  ) {
    return List<int>.generate(count, (i) {
      final day = today.subtract(Duration(days: count - 1 - i));
      return history[_day(day)]?.minutes ?? 0;
    });
  }

  /// Every card's SRS state across the whole deck tree (BFS) — the distribution
  /// source. No aggregate read exists on the frozen contracts, so this walks the
  /// tree; the Drift repo (DT.5) can replace it with one query.
  Future<List<SrsState>> _collectStates(
    List<Deck> roots,
    DeckRepository decks,
    CardRepository cardsRepo,
    ReviewRepository reviews,
  ) async {
    final visited = <String>{};
    final queue = <DeckId>[for (final deck in roots) deck.id];
    final states = <SrsState>[];
    while (queue.isNotEmpty) {
      final id = queue.removeLast();
      if (!visited.add(id.value)) continue;
      final cards = await cardsRepo.watchByDeck(id).first;
      for (final card in cards) {
        final box = _value(await reviews.currentBox(card.id));
        states.add(SrsState(box: box));
      }
      final children = await decks.watchChildren(id).first;
      for (final child in children) {
        queue.add(child.id);
      }
    }
    return states;
  }

  DateTime _day(DateTime dt) => DateTime.utc(dt.year, dt.month, dt.day);

  T _value<T>(Result<T> result) => switch (result) {
        Ok<T>(:final value) => value,
        // ignore: only_throw_errors
        Err<T>(:final failure) => throw failure,
      };
}
