import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/util/logger.dart';

void main() {
  test('LogLevel values follow the dart:developer / logging scale', () {
    expect(LogLevel.debug.value, 500);
    expect(LogLevel.info.value, 800);
    expect(LogLevel.warn.value, 900);
    expect(LogLevel.error.value, 1000);
  });

  test('every level emits without throwing, with structured fields', () {
    const log = AppLogger('test');

    expect(() => log.debug('d', op: 'op'), returnsNormally);
    expect(() => log.info('i', op: 'op', ms: 12), returnsNormally);
    expect(() => log.warn('w', failure: 'NotFoundFailure'), returnsNormally);
    expect(
      () => log.error(
        'e',
        op: 'load',
        failure: 'PersistenceFailure',
        cause: Exception('boom'),
        stackTrace: StackTrace.current,
      ),
      returnsNormally,
    );
  });
}
