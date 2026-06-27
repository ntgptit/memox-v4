import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/services/srs_scheduler.dart';
import 'package:memox_v4/domain/types/last_result.dart';

void main() {
  const scheduler = SrsScheduler();
  final oneDay = const Duration(days: 1).inMilliseconds;

  test('D-002: a new card schedules into box 1 with a due date', () {
    final state = scheduler.scheduleNewCard(7, 1000);
    expect(state.cardId, 7);
    expect(state.box, 1);
    expect(state.dueAt, 1000 + oneDay);
    expect(state.reviewedAt, 1000);
    expect(state.lastResult, isNull);
  });

  test('D-003: correct promotes +1 and recomputes due by BoxInterval', () {
    final state = scheduler.applyGrade(
      const SrsState(cardId: 1, box: 3),
      1,
      LastResult.correct,
      2000,
    );
    expect(state.box, 4);
    expect(state.dueAt, 2000 + const Duration(days: 14).inMilliseconds);
    expect(state.lastResult, LastResult.correct);
  });

  test('D-004: wrong demotes −1, floored at box 1', () {
    expect(
      scheduler
          .applyGrade(const SrsState(cardId: 1, box: 3), 1, LastResult.wrong, 0)
          .box,
      2,
    );
    expect(
      scheduler
          .applyGrade(const SrsState(cardId: 1, box: 1), 1, LastResult.wrong, 0)
          .box,
      1,
    );
  });

  test('D-005: box 8 + correct stays mastered with no due date', () {
    final state = scheduler.applyGrade(
      const SrsState(cardId: 1, box: 8),
      1,
      LastResult.correct,
      0,
    );
    expect(state.box, 8);
    expect(state.dueAt, isNull);
  });

  test('box 8 + wrong demotes to box 7 and reschedules', () {
    final state = scheduler.applyGrade(
      const SrsState(cardId: 1, box: 8),
      1,
      LastResult.wrong,
      0,
    );
    expect(state.box, 7);
    expect(state.dueAt, const Duration(days: 120).inMilliseconds);
  });

  test('grading a card with no prior state starts from new (box 1)', () {
    final state = scheduler.applyGrade(null, 5, LastResult.correct, 0);
    expect(state.box, 1);
  });
}
