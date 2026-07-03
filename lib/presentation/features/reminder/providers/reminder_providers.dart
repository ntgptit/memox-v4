import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/reminder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reminder_providers.g.dart';

/// The default reminder time when none is configured (kit shows 13:00).
const int _defaultHour = 13;
const int _defaultMinute = 0;

/// Every weekday (Mon..Sun) — used when the master toggle turns reminders on.
const Set<int> _allWeekdays = {1, 2, 3, 4, 5, 6, 7};

/// The minute steps offered by the time picker (kit quarter-hour granularity).
const List<int> reminderMinuteSteps = [0, 15, 30, 45];

/// The reminder config (time + weekdays). **Session state** — v1 has no reminder
/// store (DM.8 only *schedules* via the OS), so this is not persisted across
/// restarts (documented gap; DT.7 could back it with settings). Every change
/// re-schedules through [ReminderNotificationService]; enabling requests OS
/// permission first (BR-4). Failures are logged, not swallowed.
@riverpod
class ReminderController extends _$ReminderController {
  @override
  Reminder build() => const Reminder(
        hour: _defaultHour,
        minute: _defaultMinute,
        weekdays: {},
      );

  Future<void> setEnabled(bool enabled) async {
    if (!enabled) {
      state = _withWeekdays(const {});
      await _reschedule();
      return;
    }
    if (!await _ensurePermission()) return;
    state = _withWeekdays(_allWeekdays);
    await _reschedule();
  }

  Future<void> toggleWeekday(int weekday) async {
    final next = {...state.weekdays};
    if (!next.remove(weekday)) next.add(weekday);
    state = _withWeekdays(next);
    await _reschedule();
  }

  Future<void> setTime(int hour, int minute) async {
    state = Reminder(hour: hour, minute: minute, weekdays: state.weekdays);
    await _reschedule();
  }

  Reminder _withWeekdays(Set<int> weekdays) =>
      Reminder(hour: state.hour, minute: state.minute, weekdays: weekdays);

  Future<bool> _ensurePermission() async {
    final result =
        await ref.read(reminderNotificationServiceProvider).requestPermission();
    return result.fold(
      (granted) => granted,
      (failure) {
        ref.read(loggerProvider).error('reminder permission failed', error: failure);
        return false;
      },
    );
  }

  Future<void> _reschedule() async {
    final result =
        await ref.read(reminderNotificationServiceProvider).schedule(state);
    if (result case Err(:final failure)) {
      ref.read(loggerProvider).error('reminder schedule failed', error: failure);
    }
  }
}

/// The pending hour/minute on the time-picker sheet (applied on Done).
@riverpod
class ReminderTimeDraft extends _$ReminderTimeDraft {
  @override
  ({int hour, int minute}) build() =>
      (hour: _defaultHour, minute: _defaultMinute);

  void reset(int hour, int minute) => state = (hour: hour, minute: minute);
  void setHour(int hour) => state = (hour: hour, minute: state.minute);
  void setMinute(int minute) => state = (hour: state.hour, minute: minute);
}
