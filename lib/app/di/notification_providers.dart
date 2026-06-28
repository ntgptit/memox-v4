import 'package:memox_v4/data/services/local_notification_service.dart';
import 'package:memox_v4/domain/services/notification_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_providers.g.dart';

/// OS notification scheduler for study reminders (W12). Tests override with a
/// fake — the real plugin is platform-channel only.
@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) => LocalNotificationService();
