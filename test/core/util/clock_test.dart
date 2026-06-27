import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/util/clock.dart';

class _FixedClock implements Clock {
  _FixedClock(this._instant);
  final DateTime _instant;
  @override
  DateTime now() => _instant;
  @override
  DateTime nowUtc() => _instant.toUtc();
}

void main() {
  test('SystemClock tracks the real time', () {
    const clock = SystemClock();
    final before = DateTime.now();
    final now = clock.now();

    expect(now.isBefore(before), isFalse);
    expect(clock.nowUtc().isUtc, isTrue);
  });

  test('a fake Clock is injectable for deterministic tests', () {
    final fixed = DateTime(2026, 6, 28, 9);
    final Clock clock = _FixedClock(fixed);

    expect(clock.now(), fixed);
    expect(clock.nowUtc(), fixed.toUtc());
  });
}
