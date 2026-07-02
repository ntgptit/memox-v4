import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/reminder.dart';

/// Schedules the OS study reminders (settings). Reliability depends on the OS
/// notification permission + battery-optimisation state (BR-4), so permission is
/// part of the contract. One notification per selected weekday at the set time.
abstract interface class ReminderNotificationService {
  Future<Result<bool>> hasPermission();
  Future<Result<bool>> requestPermission();

  /// Replace any existing schedule with [reminder] (a disabled reminder cancels).
  Future<Result<void>> schedule(Reminder reminder);

  Future<Result<void>> cancelAll();
}
