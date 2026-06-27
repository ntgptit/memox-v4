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

  bool _met(Map<String, DayActivity> byDay, DailyGoal goal, DateTime day) {
    final activity = byDay[dayKey(day)];
    if (activity == null) return false;
    return goal.isMetBy(activity.seconds, activity.words);
  }
}
