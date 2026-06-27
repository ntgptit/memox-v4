/// Keys for the flat `settings` store (`docs/database/schema-contract.md`).
/// The language-pair context keys (`active_pair_id`, `display_swapped`) are owned
/// by the language-pair repository; W12 owns writing the goal keys.
abstract final class SettingsKeys {
  const SettingsKeys._();

  static const String dailyGoalMinutes = 'daily_goal_minutes';
  static const String dailyGoalWords = 'daily_goal_words';
}
