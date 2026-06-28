import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:memox_v4/domain/services/notification_service.dart';
import 'package:memox_v4/domain/services/reminder_scheduler.dart';
import 'package:memox_v4/domain/types/reminder.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// `flutter_local_notifications`-backed [NotificationService]. Schedules one
/// weekly-repeating notification per selected weekday (`dayOfWeekAndTime`).
class LocalNotificationService implements NotificationService {
  LocalNotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const String _channelId = 'study_reminders';
  static const String _channelName = 'Study reminders';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialised = false;

  @override
  Future<void> init() async {
    if (_initialised) return;
    tz_data.initializeTimeZones();
    final localName = (await FlutterTimezone.getLocalTimezone()).identifier;
    tz.setLocalLocation(tz.getLocation(localName));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    _initialised = true;
  }

  @override
  Future<bool> requestPermission() async {
    await init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return true;
  }

  @override
  Future<void> sync(
    Reminder reminder, {
    required String title,
    required String body,
  }) async {
    await init();
    await _plugin.cancelAll();
    if (!reminder.enabled) return;
    // Without permission the OS silently drops scheduled notifications, so don't
    // bother scheduling them.
    if (!await requestPermission()) return;
    final times = ReminderScheduler.nextFireTimes(reminder, DateTime.now());
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    for (var i = 0; i < times.length; i++) {
      await _plugin.zonedSchedule(
        id: i,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(times[i], tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }
}
