import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/card_status.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/review_grade.dart';

void main() {
  group('BoxLevel', () {
    test('of accepts the whole 0..8 range and rejects outside it', () {
      for (var v = BoxLevel.min; v <= BoxLevel.max; v++) {
        final result = BoxLevel.of(v);
        expect(result, isA<Ok<BoxLevel>>());
        expect((result as Ok<BoxLevel>).value.value, v);
      }
      expect(BoxLevel.of(-1), isA<Err<BoxLevel>>());
      expect(BoxLevel.of(9), isA<Err<BoxLevel>>());
      expect((BoxLevel.of(9) as Err<BoxLevel>).failure, isA<ValidationFailure>());
    });

    test('named boxes sit at the documented positions', () {
      expect(BoxLevel.newCard.value, 0);
      expect(BoxLevel.firstBox.value, 1);
      expect(BoxLevel.mastered.value, 8);
    });

    test('flags: new / scheduled (1..7) / mastered', () {
      expect(BoxLevel.newCard.isNew, isTrue);
      expect(BoxLevel.newCard.isScheduled, isFalse);
      for (var v = 1; v <= 7; v++) {
        expect((BoxLevel.of(v) as Ok<BoxLevel>).value.isScheduled, isTrue);
      }
      expect(BoxLevel.mastered.isScheduled, isFalse);
      expect(BoxLevel.mastered.isMastered, isTrue);
    });

    test('promote steps up and clamps at the mastered ceiling (BR-3)', () {
      expect(BoxLevel.newCard.promote(), BoxLevel.firstBox);
      expect((BoxLevel.of(7) as Ok<BoxLevel>).value.promote(), BoxLevel.mastered);
      expect(BoxLevel.mastered.promote(), BoxLevel.mastered);
    });

    test('demote steps down and clamps at the box-1 floor (BR-4)', () {
      expect(BoxLevel.mastered.demote(), (BoxLevel.of(7) as Ok<BoxLevel>).value);
      expect(BoxLevel.firstBox.demote(), BoxLevel.firstBox);
    });

    test('equality is by value', () {
      expect(BoxLevel.of(3), BoxLevel.of(3));
      expect((BoxLevel.of(3) as Ok<BoxLevel>).value,
          (BoxLevel.of(3) as Ok<BoxLevel>).value);
    });
  });

  group('typed IDs', () {
    test('wrap and compare as their underlying string', () {
      expect(const CardId('c1').value, 'c1');
      expect(const CardId('c1'), const CardId('c1'));
      expect(const DeckId('d1').value, 'd1');
    });
  });

  group('ReviewGrade', () {
    test('is a binary pass/fail grade', () {
      expect(ReviewGrade.values, [ReviewGrade.pass, ReviewGrade.fail]);
      expect(ReviewGrade.pass.isPass, isTrue);
      expect(ReviewGrade.fail.isFail, isTrue);
    });
  });

  group('CardStatus', () {
    test('covers the lifecycle plus hidden', () {
      expect(CardStatus.values, [
        CardStatus.newCard,
        CardStatus.learning,
        CardStatus.due,
        CardStatus.mastered,
        CardStatus.hidden,
      ]);
      expect(CardStatus.hidden.isHidden, isTrue);
      expect(CardStatus.due.isHidden, isFalse);
    });
  });
}
