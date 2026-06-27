import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/domain/repositories/daily_activity_repository.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/types/study_entry.dart';

/// Records study activity on session end. Only DueReview/NewLearn add seconds +
/// words to `daily_activity` (D-010); Review/Game/Player are a no-op (D-007).
class FinalizeStudySessionUseCase {
  const FinalizeStudySessionUseCase(this._repository, this._clock);

  final DailyActivityRepository _repository;
  final Clock _clock;

  Future<Result<void>> call({
    required int pairId,
    required StudyEntry entry,
    required int seconds,
    required int words,
  }) {
    if (!entry.changesSchedule) return Future.value(const Ok<void>(null));
    return _repository.add(
      pairId: pairId,
      day: _dayKey(_clock.now()),
      seconds: seconds,
      words: words,
    );
  }

  String _dayKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
