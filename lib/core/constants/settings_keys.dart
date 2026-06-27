/// Keys for the flat `settings` store (`docs/database/schema-contract.md`).
/// The language-pair context keys (`active_pair_id`, `display_swapped`) are owned
/// by the language-pair repository.
abstract final class SettingsKeys {
  const SettingsKeys._();

  static const String nativeLanguage = 'native_language';
  static const String uiLanguage = 'ui_language';
  static const String leitnerBoxCount = 'leitner_box_count';
  static const String gameWordsPerRound = 'game_words_per_round';
  static const String gameRandom = 'game_random';
  static const String reminderTime = 'reminder_time';
  static const String reminderWeekdays = 'reminder_weekdays';
  static const String autoBackup = 'auto_backup';
  static const String backupPath = 'backup_path';
  static const String newCardsPerDay = 'new_cards_per_day';
  static const String dailyGoalMinutes = 'daily_goal_minutes';
  static const String dailyGoalWords = 'daily_goal_words';
  static const String themeMode = 'theme_mode';
  static const String accentColor = 'accent_color';
  static const String fontScale = 'font_scale';
}
