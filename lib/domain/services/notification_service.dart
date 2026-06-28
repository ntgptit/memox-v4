import 'package:memox_v4/domain/types/reminder.dart';

/// Schedules / cancels OS notifications for the study [Reminder]. Implemented in
/// the data layer over `flutter_local_notifications`; abstracted so the settings
/// flow stays testable (the plugin itself is platform-channel only).
abstract interface class NotificationService {
  /// One-time setup (plugin + timezone). Safe to call repeatedly.
  Future<void> init();

  /// Requests the OS notification permission; returns whether it is granted.
  Future<bool> requestPermission();

  /// Reconciles scheduled notifications with [reminder]: cancels everything,
  /// then (when enabled) schedules a weekly notification per selected weekday.
  Future<void> sync(
    Reminder reminder, {
    required String title,
    required String body,
  });
}
