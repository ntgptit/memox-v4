import 'package:memox_v4/core/utils/clock.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/review_grade.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';

/// The SRS engine — the product core. Pure and deterministic: it reads "now"
/// through an injected [Clock] (never `DateTime.now()`), so every transition is
/// reproducible in tests.
///
/// Implements the 8-box single-direction Leitner rules of
/// `docs/business/srs/srs-review.md`:
/// - new card graduates to box 1 after the 5-stage learn (BR-2 / D-002);
/// - a correct grade promotes one box, ceiling box 8 (BR-3 / D-005);
/// - a wrong grade demotes one box, floor box 1 (BR-4);
/// - due interval by box: 1·3·7·14·30·60·120 days for boxes 1..7; box 8 is
///   mastered and leaves the schedule (BR-5);
/// - at most `perDayCap` new cards enter per day (BR-7 / D-018).
class SrsScheduler {
  const SrsScheduler(this._clock);

  final Clock _clock;

  /// Review interval in days for boxes 1..7 (0-indexed by `box - 1`). Boxes 0 and
  /// 8 have no interval (unscheduled / mastered).
  static const List<int> intervalDays = [1, 3, 7, 14, 30, 60, 120];

  /// Days until the next review for [box], or null when the box is off-schedule.
  int? intervalDaysFor(BoxLevel box) {
    if (!box.isScheduled) return null;
    return intervalDays[box.value - BoxLevel.firstScheduled];
  }

  DateTime? _dueFrom(DateTime from, BoxLevel box) {
    final days = intervalDaysFor(box);
    if (days == null) return null;
    return from.add(Duration(days: days));
  }

  /// A new card completes the 5-stage learn and enters box 1 (D-002).
  SrsState graduate() {
    final now = _clock.now();
    return SrsState(
      box: BoxLevel.firstBox,
      dueAt: _dueFrom(now, BoxLevel.firstBox),
      lastReviewedAt: now,
    );
  }

  /// Apply a review [grade] to a card's [current] state, producing its next box
  /// and due time (D-003 / D-004 / D-005). A card promoted into box 8 becomes
  /// mastered and leaves the schedule (`dueAt` null).
  SrsState review(SrsState current, ReviewGrade grade) {
    final now = _clock.now();
    final nextBox = grade.isPass ? current.box.promote() : current.box.demote();
    return SrsState(
      box: nextBox,
      dueAt: _dueFrom(now, nextBox),
      lastReviewedAt: now,
    );
  }

  /// How many new cards may still be introduced today given the [perDayCap]
  /// (default 20, D-018) and how many were [introducedToday]. Never negative.
  int remainingNewCardsToday({
    required int perDayCap,
    required int introducedToday,
  }) {
    final remaining = perDayCap - introducedToday;
    return remaining < 0 ? 0 : remaining;
  }
}
