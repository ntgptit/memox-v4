import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/utils/clock.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/review_grade.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/usecases/srs/srs_scheduler.dart';

class _FixedClock implements Clock {
  const _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

BoxLevel _box(int v) => (BoxLevel.of(v) as Ok<BoxLevel>).value;

void main() {
  final now = DateTime.utc(2026, 7, 3, 9);
  final scheduler = SrsScheduler(_FixedClock(now));

  group('interval table (BR-5)', () {
    test('boxes 1..7 map to 1·3·7·14·30·60·120 days; 0 and 8 are off-schedule', () {
      const expected = {1: 1, 2: 3, 3: 7, 4: 14, 5: 30, 6: 60, 7: 120};
      expected.forEach((box, days) {
        expect(scheduler.intervalDaysFor(_box(box)), days);
      });
      expect(scheduler.intervalDaysFor(BoxLevel.newCard), isNull);
      expect(scheduler.intervalDaysFor(BoxLevel.mastered), isNull);
    });
  });

  group('graduate (D-002)', () {
    test('a new card enters box 1 due one day out', () {
      final state = scheduler.graduate();
      expect(state.box, BoxLevel.firstBox);
      expect(state.dueAt, now.add(const Duration(days: 1)));
      expect(state.lastReviewedAt, now);
    });
  });

  group('review — correct (BR-3 / D-003 / D-005)', () {
    test('promotes one box and reschedules by the new interval', () {
      final from = SrsState(box: _box(3), dueAt: now);
      final next = scheduler.review(from, ReviewGrade.pass);
      expect(next.box, _box(4));
      expect(next.dueAt, now.add(const Duration(days: 14)));
    });

    test('box 7 → box 8 masters the card and drops it off the schedule', () {
      final next = scheduler.review(SrsState(box: _box(7), dueAt: now), ReviewGrade.pass);
      expect(next.box, BoxLevel.mastered);
      expect(next.dueAt, isNull);
      expect(next.isScheduled, isFalse);
    });

    test('a mastered card stays at box 8 (AC-4 / D-005)', () {
      final next = scheduler.review(const SrsState(box: BoxLevel.mastered), ReviewGrade.pass);
      expect(next.box, BoxLevel.mastered);
      expect(next.dueAt, isNull);
    });
  });

  group('review — wrong (BR-4 / D-004)', () {
    test('demotes one box and reschedules', () {
      final next = scheduler.review(SrsState(box: _box(5), dueAt: now), ReviewGrade.fail);
      expect(next.box, _box(4));
      expect(next.dueAt, now.add(const Duration(days: 14)));
    });

    test('box 1 stays at box 1 (floor)', () {
      final next = scheduler.review(SrsState(box: BoxLevel.firstBox, dueAt: now), ReviewGrade.fail);
      expect(next.box, BoxLevel.firstBox);
      expect(next.dueAt, now.add(const Duration(days: 1)));
    });
  });

  group('new-card intake cap (BR-7 / D-018)', () {
    test('never exceeds the per-day cap and never goes negative', () {
      expect(scheduler.remainingNewCardsToday(perDayCap: 20, introducedToday: 0), 20);
      expect(scheduler.remainingNewCardsToday(perDayCap: 20, introducedToday: 12), 8);
      expect(scheduler.remainingNewCardsToday(perDayCap: 20, introducedToday: 20), 0);
      expect(scheduler.remainingNewCardsToday(perDayCap: 20, introducedToday: 25), 0);
    });
  });

  group('SrsState.isDue', () {
    test('true only for a scheduled card whose due time has arrived', () {
      final due = SrsState(box: _box(1), dueAt: now);
      expect(due.isDue(now), isTrue);
      expect(due.isDue(now.subtract(const Duration(minutes: 1))), isFalse);
      expect(SrsState.newborn.isDue(now), isFalse);
      expect(const SrsState(box: BoxLevel.mastered).isDue(DateTime.utc(2030)), isFalse);
    });
  });

  test('full progression box1→box8 by repeated correct grades is deterministic', () {
    var state = scheduler.graduate(); // box 1
    for (var expectedBox = 2; expectedBox <= 8; expectedBox++) {
      state = scheduler.review(state, ReviewGrade.pass);
      expect(state.box, _box(expectedBox));
    }
    expect(state.box, BoxLevel.mastered);
    expect(state.dueAt, isNull);
  });
}
