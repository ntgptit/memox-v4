import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/constants/settings_keys.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/daos/settings_dao.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/data/repositories/settings_repository_impl.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/usecases/settings/get_settings.dart';
import 'package:memox_v4/domain/usecases/settings/update_setting.dart';

void main() {
  late AppDatabase db;
  late SettingsRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    repository = SettingsRepositoryImpl(SettingsDao(db));
  });
  tearDown(() => db.close());

  test('defaults apply when nothing is stored', () async {
    final settings = (await GetSettingsUseCase(repository).call()).valueOrNull!;
    expect(settings.gameWordsPerRound, 5);
    expect(settings.gameRandom, isTrue);
    expect(settings.newCardsPerDay, 20);
    expect(settings.leitnerBoxCount, 8);
    expect(settings.reminder.enabled, isFalse);
  });

  test('writes persist and survive a new repository instance', () async {
    final update = UpdateSettingUseCase(repository);
    await update.call(SettingsKeys.gameWordsPerRound, '8');
    await update.call(SettingsKeys.dailyGoalWords, '30');

    // A fresh repository on the same db == reopening the app.
    final reopened = SettingsRepositoryImpl(SettingsDao(db));
    final settings = (await GetSettingsUseCase(reopened).call()).valueOrNull!;
    expect(settings.gameWordsPerRound, 8);
    expect(settings.dailyGoalWords, 30);
  });

  test('a null update resets a setting to its default', () async {
    final update = UpdateSettingUseCase(repository);
    await update.call(SettingsKeys.dailyGoalMinutes, '15');
    await update.call(SettingsKeys.dailyGoalMinutes, null);

    final settings = (await GetSettingsUseCase(repository).call()).valueOrNull!;
    expect(settings.dailyGoalMinutes, isNull);
  });

  test('reminder schedule round-trips', () async {
    final update = UpdateSettingUseCase(repository);
    await update.call(SettingsKeys.reminderTime, '13:30');
    await update.call(SettingsKeys.reminderWeekdays, '1,3,5');

    final reminder = (await GetSettingsUseCase(
      repository,
    ).call()).valueOrNull!.reminder;
    expect(reminder.enabled, isTrue);
    expect(reminder.timeText, '13:30');
    expect(reminder.weekdays, <int>{1, 3, 5});
  });
}
