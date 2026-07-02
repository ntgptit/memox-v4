/// App-wide constants — names/ids/config only. No feature logic, and **no
/// user-facing copy** (that stays in ARB / l10n).
abstract final class AppConstants {
  const AppConstants._();

  /// Wordmark (brand identity, not translatable copy).
  static const String appName = 'MemoX';

  /// New cards introduced to the SRS scheduler per day (D-018).
  static const int newCardsPerDayDefault = 20;

  /// Number of Leitner boxes (D-002…D-005).
  static const int leitnerBoxCount = 8;
}
