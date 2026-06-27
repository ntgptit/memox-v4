import 'package:memox_v4/domain/types/reminder.dart';

/// User settings snapshot with defaults from `docs/database/schema-contract.md`.
class AppSettings {
  const AppSettings({
    this.nativeLanguage,
    this.uiLanguage,
    this.leitnerBoxCount = 8,
    this.gameWordsPerRound = 5,
    this.gameRandom = true,
    this.newCardsPerDay = 20,
    this.dailyGoalMinutes,
    this.dailyGoalWords,
    this.autoBackup = true,
    this.reminder = Reminder.off,
  });

  final String? nativeLanguage;
  final String? uiLanguage;

  /// Fixed at 8 in v1 (display-only).
  final int leitnerBoxCount;

  final int gameWordsPerRound;
  final bool gameRandom;
  final int newCardsPerDay;
  final int? dailyGoalMinutes;
  final int? dailyGoalWords;
  final bool autoBackup;
  final Reminder reminder;

  AppSettings copyWith({
    int? gameWordsPerRound,
    bool? gameRandom,
    int? newCardsPerDay,
    int? Function()? dailyGoalMinutes,
    int? Function()? dailyGoalWords,
    bool? autoBackup,
    Reminder? reminder,
  }) => AppSettings(
    nativeLanguage: nativeLanguage,
    uiLanguage: uiLanguage,
    leitnerBoxCount: leitnerBoxCount,
    gameWordsPerRound: gameWordsPerRound ?? this.gameWordsPerRound,
    gameRandom: gameRandom ?? this.gameRandom,
    newCardsPerDay: newCardsPerDay ?? this.newCardsPerDay,
    dailyGoalMinutes: dailyGoalMinutes != null
        ? dailyGoalMinutes()
        : this.dailyGoalMinutes,
    dailyGoalWords: dailyGoalWords != null
        ? dailyGoalWords()
        : this.dailyGoalWords,
    autoBackup: autoBackup ?? this.autoBackup,
    reminder: reminder ?? this.reminder,
  );
}
