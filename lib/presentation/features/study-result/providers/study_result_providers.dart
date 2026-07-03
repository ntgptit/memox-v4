import 'dart:math' as math;

import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/daily_goal.dart';
import 'package:memox_v4/domain/entities/streak.dart';
import 'package:memox_v4/domain/usecases/stats/streak_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_result_providers.g.dart';

/// The headline mood of the result, chosen from today's goal progress.
enum ResultHead { standard, goalMet, goalMissed }

/// The study-result summary — today's activity (the finished session's minutes +
/// words are already folded in), the goal, and the streak. v1 persists day totals
/// (not per-session records), so this is a "today so far" summary.
class StudyResultData {
  const StudyResultData({
    required this.words,
    required this.minutes,
    required this.goal,
    required this.goalMet,
    required this.goalPercent,
    required this.streak,
  });

  final int words;
  final int minutes;
  final DailyGoal goal;
  final bool goalMet;
  final double goalPercent;
  final Streak streak;

  ResultHead get head {
    if (goalMet) return ResultHead.goalMet;
    if (goal.isConfigured) return ResultHead.goalMissed;
    return ResultHead.standard;
  }

  int get goalPercentInt => (goalPercent * 100).round();
}

/// Builds the study-result summary from the day's activity + goal + streak (the
/// same read model the dashboard uses). An async notifier rendered with
/// `AsyncValue.when` — the loading branch is the finalizing view, a failed read is
/// the finalize-error surface. Failed reads throw their [Failure] (logged).
@riverpod
class StudyResultController extends _$StudyResultController {
  @override
  Future<StudyResultData> build() async {
    try {
      return await _load();
    } on Failure catch (failure, stackTrace) {
      ref.read(loggerProvider).error(
            'study result load failed',
            error: failure,
            stackTrace: stackTrace,
          );
      rethrow;
    }
  }

  Future<StudyResultData> _load() async {
    final now = ref.watch(clockProvider).now();
    final today = DateTime.utc(now.year, now.month, now.day);

    final activityService = ref.watch(dailyActivityServiceProvider);
    final settings = ref.watch(settingsRepositoryProvider);

    final activity = _value(await activityService.activityOn(now));
    final goal = await settings.watchDailyGoal().first;
    final history = await activityService.watchHistory().first;
    final streak = streakFromHistory(history: history, goal: goal, today: today);
    final goalMet =
        goal.isMetBy(minutes: activity.minutes, words: activity.words);

    return StudyResultData(
      words: activity.words,
      minutes: activity.minutes,
      goal: goal,
      goalMet: goalMet,
      goalPercent: _goalPercent(goal, activity, goalMet),
      streak: streak,
    );
  }

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

  // Failure is the domain error channel; the build() catch turns it into the
  // finalize-error AsyncValue.
  T _value<T>(Result<T> result) => switch (result) {
        Ok<T>(:final value) => value,
        // ignore: only_throw_errors
        Err<T>(:final failure) => throw failure,
      };
}
