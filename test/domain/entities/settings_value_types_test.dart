import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/domain/entities/reminder.dart';
import 'package:memox_v4/domain/entities/theme_settings.dart';

void main() {
  group('ThemeSettings', () {
    test('defaults to system / brand / medium', () {
      const settings = ThemeSettings();
      expect(settings.mode, ColorMode.system);
      expect(settings.accent, AccentColor.brand);
      expect(settings.fontScale, FontScale.medium);
    });

    test('copyWith changes only the given fields', () {
      const settings = ThemeSettings();
      final dark = settings.copyWith(mode: ColorMode.dark);
      expect(dark.mode, ColorMode.dark);
      expect(dark.accent, AccentColor.brand);
      expect(dark, isNot(settings));
    });
  });

  group('Reminder', () {
    test('is enabled only when it has weekdays', () {
      expect(Reminder.off.isEnabled, isFalse);
      const daily = Reminder(hour: 8, minute: 30, weekdays: {1, 2, 3, 4, 5});
      expect(daily.isEnabled, isTrue);
    });

    test('equality is by value including the weekday set', () {
      expect(
        const Reminder(hour: 8, minute: 0, weekdays: {1, 3}),
        const Reminder(hour: 8, minute: 0, weekdays: {3, 1}),
      );
    });

    test('rejects out-of-range time', () {
      expect(() => Reminder(hour: 24, minute: 0, weekdays: const {}), throwsA(isA<AssertionError>()));
      expect(() => Reminder(hour: 0, minute: 60, weekdays: const {}), throwsA(isA<AssertionError>()));
    });
  });
}
