import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/domain/usecases/game/evaluate_typing.dart';

void main() {
  const evaluate = EvaluateTypingUseCase();

  test('exact match', () {
    expect(evaluate('mesa', 'mesa'), isTrue);
  });

  test('case and whitespace insensitive', () {
    expect(evaluate(' Mesa ', 'mesa'), isTrue);
    expect(evaluate('me  sa', 'me sa'), isTrue);
  });

  test('accepts a single-character typo', () {
    expect(evaluate('mesa', 'mese'), isTrue);
    expect(evaluate('mes', 'mesa'), isTrue);
  });

  test('rejects far-off answers', () {
    expect(evaluate('table', 'mesa'), isFalse);
  });

  test('rejects empty input', () {
    expect(evaluate('', 'mesa'), isFalse);
  });
}
