import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/review_grade.dart';
import 'package:memox_v4/domain/entities/review_log.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/repositories/review_repository.dart';
import 'package:memox_v4/domain/services/srs_scheduler.dart';

/// Applies a review grade to a due card: read its current box, run the scheduler
/// (promote on pass / demote on fail, D-003/D-004/D-005), persist the new SRS
/// position, and record the graded outcome for stats. Returns the new [SrsState].
///
/// The scheduler stamps `lastReviewedAt` with its clock's "now"; the same instant
/// is reused for the review log so the two writes agree.
class GradeCardUseCase {
  const GradeCardUseCase({
    required ReviewRepository reviews,
    required SrsScheduler scheduler,
  })  : _reviews = reviews,
        _scheduler = scheduler;

  final ReviewRepository _reviews;
  final SrsScheduler _scheduler;

  Future<Result<SrsState>> call({
    required CardId cardId,
    required ReviewGrade grade,
  }) async {
    final boxResult = await _reviews.currentBox(cardId);
    if (boxResult case Err(:final failure)) return Err(failure);
    final currentBox = (boxResult as Ok<BoxLevel>).value;

    final next = _scheduler.review(SrsState(box: currentBox), grade);

    final saved = await _reviews.saveSchedule(
      cardId: cardId,
      box: next.box,
      dueAt: next.dueAt,
    );
    if (saved case Err(:final failure)) return Err(failure);

    final logged = await _reviews.logReview(
      // Invariant: `review()` always stamps `lastReviewedAt`, so `!` is a checked
      // assertion with no reachable null path (nothing meaningful to handle).
      ReviewLog(cardId: cardId, grade: grade, reviewedAt: next.lastReviewedAt!),
    );
    if (logged case Err(:final failure)) return Err(failure);

    return Ok(next);
  }
}
