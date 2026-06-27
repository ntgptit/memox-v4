import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/util/day_key.dart';
import 'package:memox_v4/domain/types/daily_goal.dart';
import 'package:memox_v4/domain/usecases/engagement/compute_streak.dart';

void main() {
  const useCase = ComputeStreakUseCase();
  const goal = DailyGoal(words: 5);
  final today = DateTime(2026, 6, 28, 10);

  DateTime daysAgo(int n) => today.subtract(Duration(days: n));
  Map<String, DayActivity> days(Map<int, int> wordsByOffset) =>
      <String, DayActivity>{
        for (final entry in wordsByOffset.entries)
          dayKey(daysAgo(entry.key)): (seconds: 0, words: entry.value),
      };

  test('D-021 / AC-1: consecutive met days count, today included', () {
    final streak = useCase.call(
      byDay: days(<int, int>{0: 6, 1: 6, 2: 6}),
      goal: goal,
      today: today,
    );
    expect(streak.days, 3);
  });

  test('today in progress (not yet met) does not reset the streak', () {
    // today below goal, but yesterday + before met → streak counts back from yesterday.
    final streak = useCase.call(
      byDay: days(<int, int>{0: 2, 1: 6, 2: 6}),
      goal: goal,
      today: today,
    );
    expect(streak.days, 2);
  });

  test('D-021 / AC-2: a missed earlier day resets the streak to 0', () {
    // yesterday missed and today missed → 0.
    final streak = useCase.call(
      byDay: days(<int, int>{0: 1, 1: 1, 2: 6}),
      goal: goal,
      today: today,
    );
    expect(streak.days, 0);
  });

  test('a gap breaks the streak (only contiguous met days count)', () {
    // today met, yesterday missed → streak is just today.
    final streak = useCase.call(
      byDay: days(<int, int>{0: 6, 1: 0, 2: 6}),
      goal: goal,
      today: today,
    );
    expect(streak.days, 1);
  });

  test('no goal set → streak is 0', () {
    final streak = useCase.call(
      byDay: days(<int, int>{0: 99, 1: 99}),
      goal: const DailyGoal(),
      today: today,
    );
    expect(streak.days, 0);
  });

  test('goal met by minutes OR words (BR-2)', () {
    const minutesGoal = DailyGoal(minutes: 10);
    final byDay = <String, DayActivity>{
      dayKey(today): (seconds: 600, words: 0),
      dayKey(daysAgo(1)): (seconds: 660, words: 0),
    };
    expect(useCase.call(byDay: byDay, goal: minutesGoal, today: today).days, 2);
  });
}
