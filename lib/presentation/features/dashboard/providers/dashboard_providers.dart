import 'dart:math' as math;

import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/daily_goal.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/deck_stats.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/streak.dart';
import 'package:memox_v4/domain/usecases/library/deck_usecases.dart';
import 'package:memox_v4/domain/usecases/stats/streak_summary_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_providers.g.dart';

/// Which dashboard layout the kit renders — derived purely from the assembled
/// data (`docs/design/screen-state-matrix.md`, dashboard rows).
enum DashboardStatus {
  /// The library has no decks yet — the first-run onboarding layout
  /// (hero invitation + how-it-works steps).
  empty,

  /// Has decks but no study activity today — the full layout with zeroed
  /// figures plus a nudge banner (the user's decks/goal/streak stay visible).
  notStudied,

  /// Today's goal is met — the celebration banner + full layout (D-021).
  goalMet,

  /// The streak has broken to zero and today's goal isn't met yet (D-021).
  streakReset,

  /// A normal day with activity and a live streak.
  loaded,
}

/// One due-deck row in the "Continue studying" list.
class DashboardDeck {
  const DashboardDeck({
    required this.id,
    required this.name,
    required this.cardCount,
    required this.dueCount,
    required this.progress,
  });

  final DeckId id;
  final String name;

  /// Visible (non-hidden) cards in the deck subtree.
  final int cardCount;

  /// Cards due for review now in the subtree.
  final int dueCount;

  /// Mastered / visible fraction, 0..1.
  final double progress;
}

/// The immutable dashboard view-model — everything the screen renders, assembled
/// from the DM.5 use cases via the repository providers. Feature-local (a read
/// model), so it lives with the screen, not in `domain/`.
class DashboardData {
  const DashboardData({
    required this.minutes,
    required this.words,
    required this.goal,
    required this.goalMet,
    required this.goalPercent,
    required this.streak,
    required this.masteredPercent,
    required this.hasDecks,
    required this.dueDecks,
  });

  final int minutes;
  final int words;
  final DailyGoal goal;
  final bool goalMet;

  /// Progress toward the goal, 0..1 (1.0 once met).
  final double goalPercent;
  final Streak streak;

  /// Mastered fraction across the whole library, 0..1.
  final double masteredPercent;

  /// Whether the library has any root deck — `false` drives the first-run
  /// onboarding layout.
  final bool hasDecks;
  final List<DashboardDeck> dueDecks;

  bool get hasActivity => minutes > 0 || words > 0;

  DashboardStatus get status {
    if (!hasDecks) return DashboardStatus.empty;
    if (goalMet) return DashboardStatus.goalMet;
    if (!hasActivity) return DashboardStatus.notStudied;
    if (streak.current == 0) return DashboardStatus.streakReset;
    return DashboardStatus.loaded;
  }
}

/// Assembles [DashboardData] for the Today screen. An async notifier so the screen
/// renders it with `AsyncValue.when` (loading / error / data). A failed data read
/// throws its [Failure] — surfaced localized to the user by the screen and logged
/// here for developers; never swallowed. Holds no navigation (a UI concern).
@riverpod
class DashboardController extends _$DashboardController {
  @override
  Future<DashboardData> build() async {
    try {
      return await _load();
    } on Failure catch (failure, stackTrace) {
      ref
          .read(loggerProvider)
          .error('dashboard load failed', error: failure, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<DashboardData> _load() async {
    final now = ref.watch(clockProvider).now();
    final today = DateTime.utc(now.year, now.month, now.day);

    final activityService = ref.watch(dailyActivityServiceProvider);
    final settings = ref.watch(settingsRepositoryProvider);
    final decks = ref.watch(deckRepositoryProvider);
    final reviews = ref.watch(reviewRepositoryProvider);

    final activity = _value(await activityService.activityOn(now));
    final goal = await settings.watchDailyGoal().first;
    final history = await activityService.watchHistory().first;
    final streak = streakFromHistory(history: history, goal: goal, today: today);
    final goalMet =
        goal.isMetBy(minutes: activity.minutes, words: activity.words);

    final roots = await decks.watchChildren(null).first;
    var mastered = DeckStats.empty;
    final dueDecks = <DashboardDeck>[];
    for (final deck in roots) {
      final stats = _value(await decks.statsFor(deck.id));
      mastered = mastered + stats;
      final due = _value(await reviews.dueQueue(within: deck.id, asOf: now));
      if (due.isEmpty) continue;
      dueDecks.add(DashboardDeck(
        id: deck.id,
        name: deck.name,
        cardCount: stats.visibleCount,
        dueCount: due.length,
        progress: stats.progress,
      ));
    }

    return DashboardData(
      minutes: activity.minutes,
      words: activity.words,
      goal: goal,
      goalMet: goalMet,
      goalPercent: _goalPercent(goal, activity, goalMet),
      streak: streak,
      masteredPercent: mastered.progress,
      hasDecks: roots.isNotEmpty,
      dueDecks: dueDecks,
    );
  }

  /// Create the learner's first root deck from the first-run onboarding CTA
  /// (kit `dashboard/create-deck`). Same convention as the library flow: a
  /// clock-stamped id, name validated by [Deck.create] (BR-1). Refreshes the
  /// dashboard on success (the onboarding layout yields to loaded); a failure
  /// is logged, not swallowed.
  Future<void> createDeck(String name) async {
    final id =
        DeckId('deck-${ref.read(clockProvider).now().microsecondsSinceEpoch}');
    final created = Deck.create(id: id, name: name);
    if (created case Err(:final failure)) {
      ref.read(loggerProvider).error('create deck rejected', error: failure);
      return;
    }
    final saved = await SaveDeckUseCase(ref.read(deckRepositoryProvider))
        .call((created as Ok<Deck>).value);
    saved.fold(
      (_) => ref.invalidateSelf(), // guard:invalidate-reviewed -- reason: refresh the dashboard after the first deck is created so onboarding yields to loaded
      (failure) =>
          ref.read(loggerProvider).error('create deck failed', error: failure),
    );
  }

  /// Fraction of the goal reached — the best of the configured targets, clamped
  /// to 1.0 (full once met, matching the kit's 100% ring).
  double _goalPercent(
    DailyGoal goal,
    ({int minutes, int words}) activity,
    bool met,
  ) {
    if (met) return 1;
    var best = 0.0;
    final minutesTarget = goal.minutesTarget;
    if (minutesTarget != null && minutesTarget > 0) {
      best = math.max(best, activity.minutes / minutesTarget);
    }
    final wordsTarget = goal.wordsTarget;
    if (wordsTarget != null && wordsTarget > 0) {
      best = math.max(best, activity.words / wordsTarget);
    }
    return best.clamp(0.0, 1.0);
  }

  /// Unwrap a [Result], throwing the [Failure] to the async error branch — the
  /// data layer never throws, so an [Err] here is a real load failure.
  T _value<T>(Result<T> result) => switch (result) {
        Ok<T>(:final value) => value,
        // Failure is the app's error type (not an Exception/Error subclass); the
        // async error branch carries it to the localized surface + the logger.
        // ignore: only_throw_errors -- reason: Failure is MemoX's domain error type; unwrapping the Result and rethrowing surfaces it as AsyncValue.error at the provider boundary
        Err<T>(:final failure) => throw failure,
      };
}
