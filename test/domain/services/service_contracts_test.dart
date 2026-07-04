import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/reminder.dart';
import 'package:memox_v4/domain/entities/study_mode.dart';
import 'package:memox_v4/domain/entities/study_session.dart';
import 'package:memox_v4/domain/entities/theme_settings.dart';
import 'package:memox_v4/domain/services/audio_service.dart';
import 'package:memox_v4/domain/services/backup_restore_service.dart';
import 'package:memox_v4/domain/services/daily_activity_service.dart';
import 'package:memox_v4/domain/services/import_export_file_service.dart';
import 'package:memox_v4/domain/services/reminder_notification_service.dart';
import 'package:memox_v4/domain/services/settings_service.dart';

/// The DM.8 services are pure contracts (plugin adapters land in DT.7). This
/// proves each is implementable and type-stable — a signature change breaks these
/// stubs. Behaviour lives in the adapters, not here.
void main() {
  test('SettingsService is implementable', () async {
    final SettingsService s = _StubSettings();
    expect(await s.watchTheme().first, isA<ThemeSettings>());
    expect(await s.watchGameWordsPerRound().first, 5);
    expect(await s.saveTheme(const ThemeSettings()), isA<Ok<void>>());
  });

  test('DailyActivityService is implementable', () async {
    final DailyActivityService s = _StubActivity();
    final total = await s.activityOn(DateTime.utc(2026));
    expect((total as Ok).value.minutes, 0);
    expect(
      await s.record(StudySession(
        id: const StudySessionId('s'),
        deckId: const DeckId('d'),
        mode: StudyMode.dueReview,
        startedAt: DateTime.utc(2026),
        durationMinutes: 1,
        wordsStudied: 1,
      )),
      isA<Ok<void>>(),
    );
  });

  test('Reminder / Audio / File / Backup services are implementable', () async {
    final ReminderNotificationService reminders = _StubReminders();
    expect(await reminders.schedule(Reminder.off), isA<Ok<void>>());
    expect((await reminders.hasPermission() as Ok<bool>).value, isFalse);

    final AudioService audio = _StubAudio();
    expect(await audio.speak('neko', languageCode: 'ja'), isA<Ok<void>>());

    final ImportExportFileService files = _StubFiles();
    expect((await files.pickTextFile() as Ok<String?>).value, isNull);

    final BackupRestoreService backup = _StubBackup();
    expect((await backup.createBackup() as Ok<String>).value, isNotEmpty);
  });
}

class _StubSettings implements SettingsService {
  @override
  Stream<ThemeSettings> watchTheme() => Stream.value(const ThemeSettings());
  @override
  Future<Result<void>> saveTheme(ThemeSettings settings) async => const Ok<void>(null);
  @override
  Stream<int> watchGameWordsPerRound() => Stream.value(5);
  @override
  Future<Result<void>> saveGameWordsPerRound(int count) async => const Ok<void>(null);
  @override
  Stream<bool> watchSrsDueNotifications() => Stream.value(false);
  @override
  Future<Result<void>> saveSrsDueNotifications(bool enabled) async =>
      const Ok<void>(null);
}

class _StubActivity implements DailyActivityService {
  @override
  Future<Result<void>> record(StudySession session) async => const Ok<void>(null);
  @override
  Future<Result<({int minutes, int words})>> activityOn(DateTime day) async =>
      const Ok((minutes: 0, words: 0));
  @override
  Stream<Map<DateTime, ({int minutes, int words})>> watchHistory() => Stream.value(const {});
}

class _StubReminders implements ReminderNotificationService {
  @override
  Future<Result<bool>> hasPermission() async => const Ok(false);
  @override
  Future<Result<bool>> requestPermission() async => const Ok(true);
  @override
  Future<Result<void>> schedule(Reminder reminder) async => const Ok<void>(null);
  @override
  Future<Result<void>> cancelAll() async => const Ok<void>(null);
}

class _StubAudio implements AudioService {
  @override
  Future<Result<void>> speak(String text,
          {required String languageCode, double rate = 1.0}) async =>
      const Ok<void>(null);
  @override
  Future<Result<void>> stop() async => const Ok<void>(null);
}

class _StubFiles implements ImportExportFileService {
  @override
  Future<Result<String?>> pickTextFile() async => const Ok(null);
  @override
  Future<Result<void>> writeTextFile({required String suggestedName, required String content}) async =>
      const Ok<void>(null);
  @override
  Future<Result<String>> readClipboard() async => const Ok('');
  @override
  Future<Result<void>> writeClipboard(String text) async => const Ok<void>(null);
}

class _StubBackup implements BackupRestoreService {
  @override
  Future<Result<String>> createBackup() async => const Ok('/tmp/backup.json');
  @override
  Future<Result<void>> restoreBackup(String source) async => const Ok<void>(null);
}
