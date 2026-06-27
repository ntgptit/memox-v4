import 'package:memox_v4/core/constants/settings_keys.dart';
import 'package:memox_v4/domain/models/app_settings.dart';
import 'package:memox_v4/domain/repositories/settings_repository.dart';
import 'package:memox_v4/domain/types/reminder.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Reads all settings into an [AppSettings] snapshot, applying schema defaults.
class GetSettingsUseCase {
  const GetSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Result<AppSettings>> call() async {
    final result = await _repository.readAll();
    return result.map(_parse);
  }

  AppSettings _parse(Map<String, String> raw) {
    int? intOf(String key) => raw[key] == null ? null : int.tryParse(raw[key]!);
    bool boolOf(String key, {required bool fallback}) =>
        raw[key] == null ? fallback : raw[key] == 'true' || raw[key] == '1';
    return AppSettings(
      nativeLanguage: raw[SettingsKeys.nativeLanguage],
      uiLanguage: raw[SettingsKeys.uiLanguage],
      leitnerBoxCount: intOf(SettingsKeys.leitnerBoxCount) ?? 8,
      gameWordsPerRound: intOf(SettingsKeys.gameWordsPerRound) ?? 5,
      gameRandom: boolOf(SettingsKeys.gameRandom, fallback: true),
      newCardsPerDay: intOf(SettingsKeys.newCardsPerDay) ?? 20,
      dailyGoalMinutes: intOf(SettingsKeys.dailyGoalMinutes),
      dailyGoalWords: intOf(SettingsKeys.dailyGoalWords),
      autoBackup: boolOf(SettingsKeys.autoBackup, fallback: true),
      reminder: _parseReminder(raw),
    );
  }

  Reminder _parseReminder(Map<String, String> raw) {
    final time = raw[SettingsKeys.reminderTime];
    if (time == null) return Reminder.off;
    final parts = time.split(':');
    final hour = int.tryParse(parts.first) ?? 9;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final weekdaysRaw = raw[SettingsKeys.reminderWeekdays];
    final weekdays = (weekdaysRaw == null || weekdaysRaw.isEmpty)
        ? <int>{1, 2, 3, 4, 5, 6, 7}
        : weekdaysRaw.split(',').map(int.tryParse).whereType<int>().toSet();
    return Reminder(
      enabled: true,
      hour: hour,
      minute: minute,
      weekdays: weekdays,
    );
  }
}
