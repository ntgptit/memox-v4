import 'package:memox_v4/domain/types/reminder.dart';

/// Pure computation of when a [Reminder] fires — testable without the OS.
abstract final class ReminderScheduler {
  const ReminderScheduler._();

  /// The next fire instant for each enabled weekday, at/after [now], sorted
  /// ascending. Empty when the reminder is disabled or has no weekdays.
  static List<DateTime> nextFireTimes(Reminder reminder, DateTime now) {
    if (!reminder.enabled || reminder.weekdays.isEmpty) {
      return const <DateTime>[];
    }
    final times = <DateTime>[
      for (final weekday in reminder.weekdays)
        _nextForWeekday(weekday, reminder.hour, reminder.minute, now),
    ];
    times.sort();
    return times;
  }

  static DateTime _nextForWeekday(
    int weekday,
    int hour,
    int minute,
    DateTime now,
  ) {
    final daysAhead = (weekday - now.weekday) % 7;
    var candidate = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    ).add(Duration(days: daysAhead));
    if (!candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 7));
    }
    return candidate;
  }
}
