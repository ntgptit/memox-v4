import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/repositories/review_repository.dart';
import 'package:memox_v4/domain/usecases/srs/srs_scheduler.dart';

/// Graduates a new card into the schedule once its 5-stage learn is complete:
/// the card enters box 1 with a due date (BR-2 / D-002). Persists the new SRS
/// position via [ReviewRepository].
class GraduateCard {
  const GraduateCard({
    required ReviewRepository reviews,
    required SrsScheduler scheduler,
  })  : _reviews = reviews,
        _scheduler = scheduler;

  final ReviewRepository _reviews;
  final SrsScheduler _scheduler;

  Future<Result<SrsState>> call(CardId cardId) async {
    final next = _scheduler.graduate();
    final saved = await _reviews.saveSchedule(
      cardId: cardId,
      box: next.box,
      dueAt: next.dueAt,
    );
    if (saved case Err(:final failure)) return Err(failure);
    return Ok(next);
  }
}
