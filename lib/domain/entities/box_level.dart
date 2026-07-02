import 'package:equatable/equatable.dart';
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';

/// A card's Leitner box (`LeitnerBox` in the glossary), the core SRS position.
///
/// Per `docs/business/srs/srs-review.md` the range is **0..8**:
/// - **0** — a new card, not yet scheduled (BR-1).
/// - **1..7** — scheduled boxes, each with its own review interval (BR-5:
///   1·3·7·14·30·60·120 days).
/// - **8** — mastered; scheduling stops (BR-5, AC-4).
///
/// This value object owns only its range invariant and the mechanical up/down
/// clamps (ceiling 8 per BR-3, floor 1 per BR-4). The *review* decision — which
/// direction a grade moves the box, and the next due date — belongs to the SRS
/// scheduler service (D-003/D-004/D-005), not here.
class BoxLevel extends Equatable {
  const BoxLevel._(this.value);

  /// Lowest box — a new, unscheduled card.
  static const int min = 0;

  /// The box a card enters once it is first scheduled (BR-2).
  static const int firstScheduled = 1;

  /// Highest box — mastered; no further scheduling (BR-5).
  static const int max = 8;

  static const BoxLevel newCard = BoxLevel._(min);
  static const BoxLevel firstBox = BoxLevel._(firstScheduled);
  static const BoxLevel mastered = BoxLevel._(max);

  final int value;

  /// Validated construction from an untrusted source (persistence, input).
  /// Returns [ValidationFailure] when [value] is outside `0..8`.
  static Result<BoxLevel> of(int value) {
    if (value < min || value > max) {
      return Err(
        ValidationFailure('Box level $value is out of range [$min..$max]'),
      );
    }
    return Ok(BoxLevel._(value));
  }

  bool get isNew => value == min;
  bool get isMastered => value == max;

  /// Boxes 1..7 carry a review interval and take part in scheduling.
  bool get isScheduled => value >= firstScheduled && value < max;

  /// Mechanical promote — up one box, clamped at the [max] ceiling (BR-3).
  BoxLevel promote() => isMastered ? this : BoxLevel._(value + 1);

  /// Mechanical demote — down one box, clamped at the [firstScheduled] floor
  /// (BR-4: a wrong answer never pushes a card below box 1).
  BoxLevel demote() => value <= firstScheduled ? this : BoxLevel._(value - 1);

  @override
  List<Object> get props => [value];

  @override
  String toString() => 'BoxLevel($value)';
}
