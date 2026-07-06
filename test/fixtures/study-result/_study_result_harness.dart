import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/domain/entities/daily_goal.dart';
import 'package:memox_v4/domain/entities/streak.dart';
import 'package:memox_v4/presentation/features/study-result/providers/study_result_providers.dart';

import '../../harness/provider_harness.dart';

// Shared seeds for the study-result golden fixtures. NOT a *_fixture.dart file,
// so the scaffolder ignores it.
//
// The screen renders through studyResultControllerProvider with
// `AsyncValue.when`: data → the summary, loading → the finalizing view, error →
// the finalize-error surface; finalizeRetryingProvider reframes a loading pass
// as "Retrying…". Rather than seed the whole activity/goal/streak chain and
// stall or fail it, we subclass the PUBLIC controller classes (their generated
// bases are private, but the notifiers themselves are public) and override
// `build()` to drive each branch deterministically. `head` is derived from the
// data (wrongCount ≥ 5 → manyWrong, else goalMet → goalMet, else configured →
// goalMissed, else standard), so each summary variant is just a data shape.

StudyResultData _data({
  required int words,
  required int minutes,
  required DailyGoal goal,
  required bool goalMet,
  required double goalPercent,
  required int streakCurrent,
  required int wrongCount,
}) => StudyResultData(
  words: words,
  minutes: minutes,
  goal: goal,
  goalMet: goalMet,
  goalPercent: goalPercent,
  streak: Streak(current: streakCurrent, longest: streakCurrent),
  wrongCount: wrongCount,
);

/// standard — no goal configured, a couple of misses → neutral "session done".
final StudyResultData studyResultStandard = _data(
  words: 12,
  minutes: 8,
  goal: const DailyGoal(),
  goalMet: false,
  goalPercent: 0,
  streakCurrent: 3,
  wrongCount: 1,
);

/// goal-met — the day's goal reached this session.
final StudyResultData studyResultGoalMet = _data(
  words: 20,
  minutes: 15,
  goal: const DailyGoal(minutesTarget: 10),
  goalMet: true,
  goalPercent: 1,
  streakCurrent: 5,
  wrongCount: 2,
);

/// goal-missed — a goal is configured but not yet reached today.
final StudyResultData studyResultGoalMissed = _data(
  words: 6,
  minutes: 4,
  goal: const DailyGoal(minutesTarget: 10),
  goalMet: false,
  goalPercent: 0.4,
  streakCurrent: 0,
  wrongCount: 2,
);

/// many-wrong — a lot of cards missed (≥ manyWrongThreshold) → review CTA.
final StudyResultData studyResultManyWrong = _data(
  words: 15,
  minutes: 10,
  goal: const DailyGoal(minutesTarget: 10),
  goalMet: false,
  goalPercent: 0.7,
  streakCurrent: 2,
  wrongCount: 7,
);

/// A settled summary state (standard / goal-met / goal-missed / many-wrong).
List<Override> studyResultDataOverrides(StudyResultData data) => [
  ...FakeHarness().overrides,
  studyResultControllerProvider.overrideWith(() => _FixedResult(data)),
];

/// finalizing — the write never resolves, so the view stays in loading;
/// [retrying] flips it to the "Retrying…" copy (retry-finalize).
List<Override> studyResultLoadingOverrides({bool retrying = false}) => [
  ...FakeHarness().overrides,
  studyResultControllerProvider.overrideWith(_LoadingResult.new),
  if (retrying) finalizeRetryingProvider.overrideWith(_RetryingOn.new),
];

/// finalize-error — the write fails, surfacing the retry/later error box.
List<Override> studyResultErrorOverrides() => [
  ...FakeHarness().overrides,
  studyResultControllerProvider.overrideWith(_ErrorResult.new),
];

class _FixedResult extends StudyResultController {
  _FixedResult(this._value);

  final StudyResultData _value;

  @override
  Future<StudyResultData> build() async => _value;
}

class _LoadingResult extends StudyResultController {
  @override
  Future<StudyResultData> build() => Completer<StudyResultData>().future;
}

class _ErrorResult extends StudyResultController {
  @override
  Future<StudyResultData> build() async =>
      // ignore: only_throw_errors -- reason: Failure is MemoX's domain error type; the real controller surfaces it as AsyncValue.error the same way
      throw const PersistenceFailure('finalize failed (golden fixture)');
}

class _RetryingOn extends FinalizeRetrying {
  @override
  bool build() => true;
}
