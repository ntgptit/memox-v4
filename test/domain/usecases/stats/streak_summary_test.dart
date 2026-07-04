import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/domain/entities/daily_goal.dart';
import 'package:memox_v4/domain/entities/streak.dart';
import 'package:memox_v4/domain/usecases/stats/streak_summary_usecase.dart';
import 'package:memox_v4/domain/usecases/study/streak_rollover_usecases.dart';

void main() {
  // Goal met by 15 minutes (words target unused in these cases).
  const goal = DailyGoal(minutesTarget: 15);
  final today = DateTime.utc(2026, 7, 3);

  DateTime day(int d) => DateTime.utc(2026, 7, d);
  Map<DateTime, DailyActivity> history(Map<int, int> minutesByDay) => {
        for (final e in minutesByDay.entries)
          day(e.key): (minutes: e.value, words: 0),
      };

  test('empty history is the zero streak', () {
    expect(
      streakFromHistory(history: const {}, goal: goal, today: today),
      Streak.zero,
    );
  });

  test('days below the goal never count', () {
    // 10 < 15 → not met.
    final streak =
        streakFromHistory(history: history({3: 10}), goal: goal, today: today);
    expect(streak, Streak.zero);
  });

  test('a met today counts toward the current run', () {
    final streak = streakFromHistory(
      history: history({1: 20, 2: 20, 3: 20}),
      goal: goal,
      today: today,
    );
    expect(streak.current, 3);
    expect(streak.longest, 3);
  });

  test('an unmet today keeps a run that ended yesterday alive (grace)', () {
    // Today not studied yet, but yesterday + the day before were met.
    final streak = streakFromHistory(
      history: history({1: 20, 2: 20}),
      goal: goal,
      today: today,
    );
    expect(streak.current, 2);
    expect(streak.longest, 2);
  });

  test('a full missed day resets the current run to zero', () {
    // Last met day is 2 days before today → the run is broken.
    final streak =
        streakFromHistory(history: history({1: 20}), goal: goal, today: today);
    expect(streak.current, 0);
    expect(streak.longest, 1);
  });

  test('longest can exceed the current run', () {
    // A 3-day run in June, then only today met (current run of 1).
    final streak = streakFromHistory(
      history: {
        DateTime.utc(2026, 6, 10): (minutes: 20, words: 0),
        DateTime.utc(2026, 6, 11): (minutes: 20, words: 0),
        DateTime.utc(2026, 6, 12): (minutes: 20, words: 0),
        today: (minutes: 20, words: 0),
      },
      goal: goal,
      today: today,
    );
    expect(streak.current, 1);
    expect(streak.longest, 3);
  });

  test('words can satisfy the goal instead of minutes', () {
    const wordsGoal = DailyGoal(wordsTarget: 20);
    final streak = streakFromHistory(
      history: {today: (minutes: 0, words: 25)},
      goal: wordsGoal,
      today: today,
    );
    expect(streak.current, 1);
  });
}
