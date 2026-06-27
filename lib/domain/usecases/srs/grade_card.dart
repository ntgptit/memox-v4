import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/repositories/srs_repository.dart';
import 'package:memox_v4/domain/services/srs_scheduler.dart';
import 'package:memox_v4/domain/types/last_result.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Grades a card during review: correct → +1 (cap 8), wrong → −1 (floor 1),
/// recomputing the due date from the new box (D-003/D-004/D-005).
class GradeCardUseCase {
  const GradeCardUseCase(
    this._repository,
    this._clock, [
    this._scheduler = const SrsScheduler(),
  ]);

  final SrsRepository _repository;
  final Clock _clock;
  final SrsScheduler _scheduler;

  Future<Result<SrsState>> call(int cardId, LastResult result) async {
    final current = (await _repository.stateFor(cardId)).valueOrNull;
    final next = _scheduler.applyGrade(
      current,
      cardId,
      result,
      _clock.now().millisecondsSinceEpoch,
    );
    final saved = await _repository.upsert(next);
    return switch (saved) {
      Ok() => Ok(next),
      Err(:final failure) => Err(failure),
    };
  }
}
