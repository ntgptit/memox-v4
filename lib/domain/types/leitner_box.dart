/// A Leitner box (0..8). `0` = new (unscheduled); `1..7` carry a review interval
/// (`BoxInterval`); `8` = mastered (no schedule). Correct → +1 (cap 8); wrong →
/// −1 (floor 1) (`docs/contracts/types-catalog.md`, D-003/D-004/D-005).
class LeitnerBox {
  const LeitnerBox(this.value)
    : assert(
        value >= newBox && value <= masteredBox,
        'Leitner box out of range 0..8',
      );

  final int value;

  static const int newBox = 0;
  static const int scheduledFloor = 1;
  static const int masteredBox = 8;

  bool get isNew => value == newBox;
  bool get isMastered => value == masteredBox;

  /// Boxes 1..7 carry a due date; 0 (new) and 8 (mastered) do not.
  bool get hasSchedule => value >= scheduledFloor && value < masteredBox;

  /// Correct answer: up one box, capped at mastered (D-003 / D-005).
  LeitnerBox promote() =>
      LeitnerBox(value >= masteredBox ? masteredBox : value + 1);

  /// Wrong answer: down one box, floored at the scheduled floor (D-004).
  LeitnerBox demote() =>
      LeitnerBox(value <= scheduledFloor ? scheduledFloor : value - 1);
}
