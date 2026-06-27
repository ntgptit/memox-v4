import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/repositories/srs_repository.dart';
import 'package:memox_v4/domain/services/srs_scheduler.dart';
import 'package:memox_v4/domain/types/leitner_box.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Schedules a card into box 1 once NewLearn (5 stages) is complete (D-002).
/// Idempotent: an already-scheduled card (box ≥ 1) is left unchanged.
class ScheduleNewCardUseCase {
  const ScheduleNewCardUseCase(
    this._repository,
    this._clock, [
    this._scheduler = const SrsScheduler(),
  ]);

  final SrsRepository _repository;
  final Clock _clock;
  final SrsScheduler _scheduler;

  Future<Result<SrsState>> call(int cardId) async {
    final current = (await _repository.stateFor(cardId)).valueOrNull;
    if (current != null && current.box >= LeitnerBox.scheduledFloor) {
      return Ok(current);
    }
    final next = _scheduler.scheduleNewCard(
      cardId,
      _clock.now().millisecondsSinceEpoch,
    );
    final saved = await _repository.upsert(next);
    return switch (saved) {
      Ok() => Ok(next),
      Err(:final failure) => Err(failure),
    };
  }
}
