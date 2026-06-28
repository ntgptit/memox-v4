import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/domain/services/reminder_scheduler.dart';
import 'package:memox_v4/domain/types/reminder.dart';

void main() {
  test('disabled reminder yields no fire times', () {
    expect(
      ReminderScheduler.nextFireTimes(Reminder.off, DateTime(2026, 6, 29, 12)),
      isEmpty,
    );
  });

  test('one fire time per weekday, each after now at the set time', () {
    final now = DateTime(2026, 6, 29, 12);
    const reminder = Reminder(
      enabled: true,
      hour: 9,
      minute: 30,
      weekdays: <int>{1, 3, 5},
    );
    final times = ReminderScheduler.nextFireTimes(reminder, now);

    expect(times.length, 3);
    for (final t in times) {
      expect(t.isAfter(now), isTrue);
      expect(t.hour, 9);
      expect(t.minute, 30);
      expect(reminder.weekdays.contains(t.weekday), isTrue);
    }
    expect(times, orderedEquals(<DateTime>[...times]..sort()));
  });

  test('a time already passed today wraps to next week', () {
    final now = DateTime(2026, 6, 29, 10); // 10:00 on some weekday
    final reminder = Reminder(
      enabled: true,
      hour: 9,
      minute: 0,
      weekdays: <int>{now.weekday},
    );
    final next = ReminderScheduler.nextFireTimes(reminder, now).single;

    expect(next.weekday, now.weekday);
    expect(next.hour, 9);
    expect(next.isAfter(now.add(const Duration(days: 6))), isTrue);
  });
}
