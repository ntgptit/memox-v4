import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/app/di/notification_providers.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/domain/services/notification_service.dart';
import 'package:memox_v4/domain/types/reminder.dart';
import 'package:memox_v4/presentation/features/settings/viewmodels/settings_notifier.dart';

class _FakeNotificationService implements NotificationService {
  Reminder? lastSynced;
  String? lastTitle;
  String? lastBody;

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> sync(
    Reminder reminder, {
    required String title,
    required String body,
  }) async {
    lastSynced = reminder;
    lastTitle = title;
    lastBody = body;
  }
}

void main() {
  late AppDatabase db;
  late _FakeNotificationService fake;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    fake = _FakeNotificationService();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(fake),
      ],
    );
    container.listen(settingsProvider, (_, _) {});
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test(
    'setReminder persists the schedule and syncs the OS scheduler',
    () async {
      await container.read(settingsProvider.future);
      const reminder = Reminder(
        enabled: true,
        hour: 8,
        minute: 15,
        weekdays: <int>{1, 2, 3},
      );

      await container
          .read(settingsProvider.notifier)
          .setReminder(reminder, notificationTitle: 'T', notificationBody: 'B');

      // Synced to the OS scheduler with the right reminder + copy.
      expect(fake.lastSynced?.enabled, isTrue);
      expect(fake.lastSynced?.hour, 8);
      expect(fake.lastSynced?.weekdays, <int>{1, 2, 3});
      expect(fake.lastTitle, 'T');
      expect(fake.lastBody, 'B');

      // Persisted (survives a reload).
      final settings = await container.read(settingsProvider.future);
      expect(settings.reminder.enabled, isTrue);
      expect(settings.reminder.timeText, '08:15');
    },
  );
}
