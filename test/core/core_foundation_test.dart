import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/constants/app_constants.dart';
import 'package:memox_v4/core/logging/app_logger.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/core/utils/clock.dart';

void main() {
  group('loggerProvider', () {
    test('yields a DevLogger by default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(loggerProvider), isA<DevLogger>());
    });

    test('is overridable (for tests / a reporting sink)', () {
      final fake = _FakeLogger();
      final container = ProviderContainer(
        overrides: [loggerProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);
      container.read(loggerProvider).info('hi');
      expect(fake.infos, ['hi']);
    });
  });

  test('SystemClock.now returns the current time', () {
    const clock = SystemClock();
    final before = DateTime.now();
    final now = clock.now();
    expect(now.difference(before).inSeconds.abs(), lessThan(2));
  });

  test('AppConstants expose the v1 config values', () {
    expect(AppConstants.appName, 'MemoX');
    expect(AppConstants.newCardsPerDayDefault, 20);
    expect(AppConstants.leitnerBoxCount, 8);
  });
}

final class _FakeLogger implements AppLogger {
  final List<String> infos = [];

  @override
  void debug(String message) {}

  @override
  void info(String message) => infos.add(message);

  @override
  void warn(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}
}
