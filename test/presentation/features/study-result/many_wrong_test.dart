import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/domain/entities/daily_goal.dart';
import 'package:memox_v4/domain/entities/streak.dart';
import 'package:memox_v4/presentation/features/study-result/providers/study_result_providers.dart';

StudyResultData _data({
  required int wrongCount,
  bool goalMet = false,
  DailyGoal goal = const DailyGoal(minutesTarget: 15),
}) =>
    StudyResultData(
      words: 0,
      minutes: 0,
      goal: goal,
      goalMet: goalMet,
      goalPercent: 0,
      streak: Streak.zero,
      wrongCount: wrongCount,
    );

void main() {
  test('head is manyWrong at/above the threshold, over the goal moods', () {
    // At the threshold → manyWrong.
    expect(_data(wrongCount: manyWrongThreshold).head, ResultHead.manyWrong);

    // Takes precedence even over a met goal.
    expect(
      _data(wrongCount: manyWrongThreshold, goalMet: true).head,
      ResultHead.manyWrong,
    );

    // Below the threshold falls through to the goal-based moods.
    expect(
      _data(wrongCount: manyWrongThreshold - 1, goalMet: true).head,
      ResultHead.goalMet,
    );
    expect(
      _data(wrongCount: 0, goal: const DailyGoal(minutesTarget: 15)).head,
      ResultHead.goalMissed,
    );
    expect(
      _data(wrongCount: 0, goal: const DailyGoal()).head,
      ResultHead.standard,
    );
  });
}
