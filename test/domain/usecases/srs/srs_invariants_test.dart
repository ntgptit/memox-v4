import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/utils/clock.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/review_grade.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/services/srs_scheduler.dart';

/// V.2 — invariant/property sweep for the SRS engine, complementing the
/// example-based `srs_scheduler_test.dart`. Exhaustively exercises every box and
/// both grades, plus multi-step sequences, so a scheduler regression is caught by
/// a property, not a single hand-picked case. Covers D-002/003/004/005 · BR-3/4/5
/// · D-018.
class _FixedClock implements Clock {
  const _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

BoxLevel _box(int value) => (BoxLevel.of(value) as Ok<BoxLevel>).value;

void main() {
  final now = DateTime.utc(2026, 7, 3, 9);
  final scheduler = SrsScheduler(_FixedClock(now));

  SrsState stateAt(int box) => SrsState(box: _box(box));

  group('single-transition property table (all boxes × both grades)', () {
    test('pass promotes with a box-8 ceiling; fail demotes with a box-1 floor',
        () {
      for (var box = 0; box <= 8; box++) {
        final pass = scheduler.review(stateAt(box), ReviewGrade.pass);
        final fail = scheduler.review(stateAt(box), ReviewGrade.fail);

        // promote() ceilings at 8; demote() floors at 1 (box 0 is not scheduled,
        // so it stays put on a fail).
        final expectedPass = box >= 8 ? 8 : box + 1;
        final expectedFail = box <= 1 ? box : box - 1;
        expect(pass.box.value, expectedPass, reason: 'pass from box $box');
        expect(fail.box.value, expectedFail, reason: 'fail from box $box');
      }
    });

    test('every transition stamps lastReviewedAt = now', () {
      for (var box = 0; box <= 8; box++) {
        for (final grade in ReviewGrade.values) {
          expect(scheduler.review(stateAt(box), grade).lastReviewedAt, now);
        }
      }
    });

    test('dueAt is exactly now + the next box interval (null off-schedule)', () {
      for (var box = 0; box <= 8; box++) {
        for (final grade in ReviewGrade.values) {
          final next = scheduler.review(stateAt(box), grade);
          final interval = scheduler.intervalDaysFor(next.box);
          expect(
            next.dueAt,
            interval == null ? isNull : now.add(Duration(days: interval)),
            reason: 'due for box $box, ${grade.name}',
          );
        }
      }
    });
  });

  group('bounds invariant under arbitrary grade sequences', () {
    test('the box never leaves [0, 8] for any pass/fail sequence', () {
      // A deterministic, adversarial mix of grades.
      const sequences = [
        [true, true, true, true, true, true, true, true, true, true],
        [false, false, false, false, false, false],
        [true, false, true, false, true, false, true],
        [true, true, true, false, true, true, false, false, true],
      ];
      for (final seq in sequences) {
        var state = SrsState.newborn;
        for (final pass in seq) {
          state = scheduler.review(
              state, pass ? ReviewGrade.pass : ReviewGrade.fail);
          expect(state.box.value, inInclusiveRange(0, 8));
        }
      }
    });
  });

  group('ladder + mastery invariants', () {
    test('7 consecutive passes from box 1 reach box 8; 7 fails return to box 1',
        () {
      var state = stateAt(1);
      for (var i = 0; i < 7; i++) {
        state = scheduler.review(state, ReviewGrade.pass);
      }
      expect(state.box, BoxLevel.mastered);
      expect(state.dueAt, isNull);

      for (var i = 0; i < 7; i++) {
        state = scheduler.review(state, ReviewGrade.fail);
      }
      expect(state.box, BoxLevel.firstBox);
      expect(state.dueAt, now.add(const Duration(days: 1)));
    });

    test('a mastered card absorbs any number of passes (stays box 8, no due)',
        () {
      var state = stateAt(8);
      for (var i = 0; i < 5; i++) {
        state = scheduler.review(state, ReviewGrade.pass);
        expect(state.box, BoxLevel.mastered);
        expect(state.dueAt, isNull);
      }
      // A single fail drops it back onto the schedule at box 7 (120-day interval).
      final demoted = scheduler.review(state, ReviewGrade.fail);
      expect(demoted.box.value, 7);
      expect(demoted.dueAt, now.add(const Duration(days: 120)));
    });
  });

  group('interval table is strictly increasing (1..7)', () {
    test('each scheduled box has a longer interval than the previous', () {
      var previous = 0;
      for (var box = 1; box <= 7; box++) {
        final days = scheduler.intervalDaysFor(_box(box))!;
        expect(days, greaterThan(previous), reason: 'box $box interval');
        previous = days;
      }
    });
  });

  group('graduate is deterministic and clock-driven', () {
    test('always box 1, due one day out, stamped now — for any clock', () {
      for (final at in [
        DateTime.utc(2020),
        DateTime.utc(2026, 7, 3, 9),
        DateTime.utc(2030, 12, 31, 23, 59),
      ]) {
        final graduated = SrsScheduler(_FixedClock(at)).graduate();
        expect(graduated.box, BoxLevel.firstBox);
        expect(graduated.dueAt, at.add(const Duration(days: 1)));
        expect(graduated.lastReviewedAt, at);
      }
    });

    test('the due time tracks the injected clock (no wall clock)', () {
      final a = SrsScheduler(_FixedClock(DateTime.utc(2026, 1, 1))).graduate();
      final b = SrsScheduler(_FixedClock(DateTime.utc(2026, 1, 2))).graduate();
      expect(b.dueAt!.difference(a.dueAt!), const Duration(days: 1));
    });
  });

  group('new-card intake invariants (D-018)', () {
    test('remaining == max(0, cap - introduced) and is monotonic', () {
      const cap = 20;
      int? previous;
      for (var introduced = 0; introduced <= 30; introduced++) {
        final remaining = scheduler.remainingNewCardsToday(
            perDayCap: cap, introducedToday: introduced);
        expect(remaining, (cap - introduced) < 0 ? 0 : cap - introduced);
        expect(remaining, inInclusiveRange(0, cap));
        if (previous != null) {
          expect(remaining, lessThanOrEqualTo(previous));
        }
        previous = remaining;
      }
    });
  });
}
