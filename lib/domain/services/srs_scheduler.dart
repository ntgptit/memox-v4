import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/types/box_interval.dart';
import 'package:memox_v4/domain/types/last_result.dart';
import 'package:memox_v4/domain/types/leitner_box.dart';

/// Pure 8-box Leitner transitions — the core scheduling logic, free of IO. Time
/// is passed in (`nowMs`) so it stays deterministic (`docs/business/srs/srs-review.md`).
class SrsScheduler {
  const SrsScheduler();

  /// A new card graduating from NewLearn enters box 1 with a due date (D-002).
  SrsState scheduleNewCard(int cardId, int nowMs) {
    const box = LeitnerBox.scheduledFloor;
    final days = BoxInterval.daysForBox(box)!;
    return SrsState(
      cardId: cardId,
      box: box,
      dueAt: nowMs + Duration(days: days).inMilliseconds,
      reviewedAt: nowMs,
    );
  }

  /// Applies a grade: correct → +1 (cap 8), wrong → −1 (floor 1); recomputes the
  /// due date from the new box (null at box 8 — mastered, D-003/D-004/D-005).
  SrsState applyGrade(
    SrsState? current,
    int cardId,
    LastResult result,
    int nowMs,
  ) {
    final currentBox = LeitnerBox(current?.box ?? LeitnerBox.newBox);
    final nextBox = result == LastResult.correct
        ? currentBox.promote()
        : currentBox.demote();
    final days = BoxInterval.daysForBox(nextBox.value);
    return SrsState(
      cardId: cardId,
      box: nextBox.value,
      dueAt: days == null ? null : nowMs + Duration(days: days).inMilliseconds,
      lastResult: result,
      reviewedAt: nowMs,
    );
  }
}
