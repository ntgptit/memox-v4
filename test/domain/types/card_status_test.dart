import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/domain/types/card_status.dart';

void main() {
  test('hidden dominates every other signal', () {
    expect(
      deriveCardStatus(hidden: true, box: 3, isDue: true),
      CardStatus.hidden,
    );
  });

  test('null or box 0 is a new card', () {
    expect(
      deriveCardStatus(hidden: false, box: null, isDue: false),
      CardStatus.newCard,
    );
    expect(
      deriveCardStatus(hidden: false, box: 0, isDue: false),
      CardStatus.newCard,
    );
  });

  test('box 8 is mastered', () {
    expect(
      deriveCardStatus(hidden: false, box: 8, isDue: true),
      CardStatus.mastered,
    );
  });

  test('a scheduled card that is due reads as due', () {
    expect(
      deriveCardStatus(hidden: false, box: 3, isDue: true),
      CardStatus.due,
    );
  });

  test('a scheduled card that is not due reads as learning', () {
    expect(
      deriveCardStatus(hidden: false, box: 3, isDue: false),
      CardStatus.learning,
    );
  });
}
