import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';

void main() {
  group('Result', () {
    test('Ok.fold / map', () {
      const result = Ok<int>(2);
      expect(result.isOk, isTrue);
      expect(result.fold((v) => v * 10, (_) => -1), 20);
      expect(result.map((v) => v + 1), const Ok<int>(3));
    });

    test('Err.fold / map passes the failure through', () {
      const failure = NotFoundFailure('missing');
      const result = Err<int>(failure);
      expect(result.isOk, isFalse);
      expect(result.fold((_) => 'ok', (f) => f.message), 'missing');
      expect(result.map((v) => v + 1), const Err<int>(failure));
    });
  });

  group('guard', () {
    test('returns Ok on success', () {
      expect(guard(() => 42), const Ok<int>(42));
    });

    test('wraps an unknown throw as UnexpectedFailure with the cause', () {
      final result = guard<int>(() => throw StateError('boom'));
      final failure = (result as Err<int>).failure;
      expect(failure, isA<UnexpectedFailure>());
      expect(failure.cause, isA<StateError>());
    });

    test('passes a thrown Failure through unchanged', () {
      const thrown = ValidationFailure('bad input');
      final result = guard<int>(() => throw thrown);
      expect((result as Err<int>).failure, same(thrown));
    });

    test('onError classifies the error', () {
      final result = guard<int>(
        () => throw Exception('io'),
        onError: (e, st) => PersistenceFailure('db', cause: e, stackTrace: st),
      );
      expect((result as Err<int>).failure, isA<PersistenceFailure>());
    });
  });

  group('guardAsync', () {
    test('returns Ok on success', () async {
      expect(await guardAsync(() async => 7), const Ok<int>(7));
    });

    test('wraps a thrown error', () async {
      final result = await guardAsync<int>(() async => throw StateError('x'));
      expect((result as Err<int>).failure, isA<UnexpectedFailure>());
    });
  });
}
