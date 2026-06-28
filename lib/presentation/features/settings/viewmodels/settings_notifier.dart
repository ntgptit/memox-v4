import 'package:memox_v4/app/di/notification_providers.dart';
import 'package:memox_v4/app/di/settings_providers.dart';
import 'package:memox_v4/app/di/sync_providers.dart';
import 'package:memox_v4/core/constants/settings_keys.dart';
import 'package:memox_v4/domain/models/app_settings.dart';
import 'package:memox_v4/domain/types/reminder.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/types/sync.dart';
import 'package:memox_v4/domain/usecases/settings/get_settings.dart';
import 'package:memox_v4/domain/usecases/settings/update_setting.dart';
import 'package:memox_v4/presentation/features/engagement/viewmodels/engagement_notifier.dart';
import 'package:memox_v4/presentation/features/language_pair/viewmodels/language_pair_notifier.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_notifier.g.dart';

/// User settings (kept alive). Persists each change, then refreshes the
/// dashboard goal when the daily goal changes.
@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  static const String _backupFileName = 'memox_backup.json';

  UpdateSettingUseCase get _update =>
      UpdateSettingUseCase(ref.read(settingsRepositoryProvider));

  @override
  Future<AppSettings> build() => _load();

  Future<AppSettings> _load() async {
    final result = await GetSettingsUseCase(
      ref.read(settingsRepositoryProvider),
    ).call();
    return result.valueOrNull ?? const AppSettings();
  }

  Future<void> _set(
    String key,
    String? value, {
    bool affectsGoal = false,
  }) async {
    await _update.call(key, value);
    state = await AsyncValue.guard(_load);
    if (affectsGoal) ref.invalidate(engagementProvider);
  }

  Future<void> setGameWordsPerRound(int value) =>
      _set(SettingsKeys.gameWordsPerRound, '$value');

  Future<void> setGameRandom(bool value) =>
      _set(SettingsKeys.gameRandom, '$value');

  Future<void> setNewCardsPerDay(int value) =>
      _set(SettingsKeys.newCardsPerDay, '$value');

  Future<void> setDailyGoalMinutes(int? value) =>
      _set(SettingsKeys.dailyGoalMinutes, value?.toString(), affectsGoal: true);

  Future<void> setDailyGoalWords(int? value) =>
      _set(SettingsKeys.dailyGoalWords, value?.toString(), affectsGoal: true);

  Future<void> setAutoBackup(bool value) =>
      _set(SettingsKeys.autoBackup, '$value');

  Future<void> setReminder(
    Reminder reminder, {
    required String notificationTitle,
    required String notificationBody,
  }) async {
    if (!reminder.enabled) {
      await _update.call(SettingsKeys.reminderTime, null);
    } else {
      await _update.call(SettingsKeys.reminderTime, reminder.timeText);
      final weekdays = (reminder.weekdays.toList()..sort()).join(',');
      await _update.call(SettingsKeys.reminderWeekdays, weekdays);
    }
    state = await AsyncValue.guard(_load);
    await ref
        .read(notificationServiceProvider)
        .sync(reminder, title: notificationTitle, body: notificationBody);
  }

  /// Snapshot all data to the documents directory; returns the file path.
  Future<Result<String>> backupNow() async {
    final path = await _backupPath();
    final result = await ref.read(backupRepositoryProvider).backup(path);
    if (result is Ok<void>) {
      await _set(SettingsKeys.backupPath, path);
    }
    return result.map((_) => path);
  }

  /// Restore from the last local backup file.
  Future<Result<void>> restoreNow() async {
    final path = await _backupPath();
    final result = await ref.read(backupRepositoryProvider).restore(path);
    if (result is Ok<void>) {
      ref.invalidate(languagePairProvider);
      ref.invalidate(engagementProvider);
      ref.invalidateSelf();
    }
    return result;
  }

  /// Syncs with the cloud (snapshot-level LWW, W10). The use case owns sign-in
  /// detection; when it reports [SyncOutcome.signInRequired] we run the
  /// interactive sign-in and retry once. A pull refreshes the library + dashboard
  /// like a local restore.
  Future<Result<SyncOutcome>> syncNow() async {
    var result = await ref.read(syncNowProvider).call();
    if (result.valueOrNull == SyncOutcome.signInRequired) {
      final signIn = await ref.read(cloudSyncServiceProvider).signIn();
      if (signIn is Err<void>) return Err<SyncOutcome>(signIn.failure);
      result = await ref.read(syncNowProvider).call();
    }
    if (result case Ok(value: SyncOutcome.pulled)) {
      ref.invalidate(languagePairProvider);
      ref.invalidate(engagementProvider);
      ref.invalidateSelf();
    }
    return result;
  }

  Future<String> _backupPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$_backupFileName';
  }
}
