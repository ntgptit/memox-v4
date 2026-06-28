import 'package:memox_v4/core/util/day_key.dart';
import 'package:memox_v4/domain/types/daily_goal.dart';
import 'package:memox_v4/domain/types/streak.dart';

/// A day's totals.
typedef DayActivity = ({int seconds, int words});

/// Counts the current streak: consecutive days (ending today) that met the goal
/// (D-021). Today is skipped if not yet met (it's still in progress, not a miss);
/// a missed earlier day stops the count. With no goal, the streak is 0.
class ComputeStreakUseCase {
  const ComputeStreakUseCase();

  Streak call({
    required Map<String, DayActivity> byDay,
    required DailyGoal goal,
    required DateTime today,
  }) {
    if (!goal.hasGoal) return const Streak(0);
    var count = 0;
    var day = DateTime(today.year, today.month, today.day);
    if (!_met(byDay, goal, day)) {
      day = day.subtract(const Duration(days: 1));
    }
    while (_met(byDay, goal, day)) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return Streak(count);
  }

  /// The longest run of consecutive goal-met days over the whole history.
  int longest({
    required Map<String, DayActivity> byDay,
    required DailyGoal goal,
  }) {
    if (!goal.hasGoal) return 0;
    final metDays = <DateTime>[
      for (final entry in byDay.entries)
        if (goal.isMetBy(entry.value.seconds, entry.value.words))
          _parseDay(entry.key),
    ]..sort();
    if (metDays.isEmpty) return 0;
    var best = 1;
    var run = 1;
    for (var i = 1; i < metDays.length; i++) {
      run = metDays[i].difference(metDays[i - 1]).inDays == 1 ? run + 1 : 1;
      if (run > best) best = run;
    }
    return best;
  }

  bool _met(Map<String, DayActivity> byDay, DailyGoal goal, DateTime day) {
    final activity = byDay[dayKey(day)];
    if (activity == null) return false;
    return goal.isMetBy(activity.seconds, activity.words);
  }

  static DateTime _parseDay(String key) {
    final parts = key.split('-');
    // UTC midnight so consecutive calendar days are exactly 24h apart — a local
    // DateTime would mis-count `inDays` across a DST boundary.
    return DateTime.utc(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}
