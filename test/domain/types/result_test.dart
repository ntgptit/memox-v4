import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/domain/types/result.dart';

void main() {
  const ok = Ok<int>(7);
  const err = Err<int>(NotFoundFailure());

  test('isOk / isErr discriminate the branches', () {
    expect(ok.isOk, isTrue);
    expect(ok.isErr, isFalse);
    expect(err.isErr, isTrue);
    expect(err.isOk, isFalse);
  });

  test('valueOrNull / failureOrNull project the held value', () {
    expect(ok.valueOrNull, 7);
    expect(ok.failureOrNull, isNull);
    expect(err.valueOrNull, isNull);
    expect(err.failureOrNull, isA<NotFoundFailure>());
  });

  test('fold collapses both branches', () {
    expect(ok.fold((v) => 'ok:$v', (f) => 'err'), 'ok:7');
    expect(err.fold((v) => 'ok', (f) => 'err'), 'err');
  });

  test('map transforms Ok and passes Err through unchanged', () {
    expect(ok.map((v) => v * 2).valueOrNull, 14);
    final mapped = err.map((v) => v * 2);
    expect(mapped.isErr, isTrue);
    expect(mapped.failureOrNull, same(err.failureOrNull));
  });

  test('getOrElse falls back on failure', () {
    expect(ok.getOrElse((f) => -1), 7);
    expect(err.getOrElse((f) => -1), -1);
  });
}
