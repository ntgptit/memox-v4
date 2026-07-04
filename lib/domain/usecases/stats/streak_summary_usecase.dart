import 'package:memox_v4/domain/entities/daily_goal.dart';
import 'package:memox_v4/domain/entities/streak.dart';
import 'package:memox_v4/domain/usecases/study/streak_rollover_usecases.dart';

/// Derives the [Streak] (current run + longest ever) from the day-by-day activity
/// history and the daily goal (engagement BR-3 / D-021). Pure — a read model over
/// the same data the midnight [rollOverStreak] persists, used by the dashboard
/// before a streak column is stored.
///
/// A day counts toward a run when its activity meets the goal ([DailyGoal.isMetBy]).
/// The current run stays alive until the day closes: today is only counted once
/// its goal is met, but a run ending *yesterday* is not yet broken — so a learner
/// who met the goal yesterday and hasn't studied yet today still shows that run,
/// while a gap of a full day resets the current run to zero.
Streak streakFromHistory({
  required Map<DateTime, DailyActivity> history,
  required DailyGoal goal,
  required DateTime today,
}) {
  final metDays = <DateTime>{
    for (final entry in history.entries)
      if (goal.isMetBy(minutes: entry.value.minutes, words: entry.value.words))
        _day(entry.key),
  };
  if (metDays.isEmpty) return Streak.zero;

  final current = _currentRun(metDays, _day(today));
  final longest = _longestRun(metDays);
  // longest is over the same set the current run belongs to, so it dominates;
  // the max guard only defends the Streak(longest >= current) invariant.
  return Streak(current: current, longest: longest > current ? longest : current);
}

/// Consecutive met-days ending at [today] (if met) or [today] - 1 day (grace for
/// the still-open day). Zero when neither today nor yesterday was met.
int _currentRun(Set<DateTime> metDays, DateTime today) {
  var cursor = metDays.contains(today)
      ? today
      : today.subtract(const Duration(days: 1));
  var run = 0;
  while (metDays.contains(cursor)) {
    run++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return run;
}

/// The longest consecutive run of met-days anywhere in the history.
int _longestRun(Set<DateTime> metDays) {
  var longest = 0;
  for (final day in metDays) {
    // Count only from a run's first day (the day before it is not a met-day).
    if (metDays.contains(day.subtract(const Duration(days: 1)))) continue;
    var run = 0;
    var cursor = day;
    while (metDays.contains(cursor)) {
      run++;
      cursor = cursor.add(const Duration(days: 1));
    }
    if (run > longest) longest = run;
  }
  return longest;
}

DateTime _day(DateTime dt) => DateTime.utc(dt.year, dt.month, dt.day);
