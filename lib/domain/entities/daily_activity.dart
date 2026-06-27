/// Per-day study totals for a pair (`daily_activity`,
/// `docs/database/schema-contract.md`). Only DueReview/NewLearn add to it (D-010).
class DailyActivity {
  const DailyActivity({
    required this.day,
    required this.pairId,
    required this.seconds,
    required this.words,
  });

  /// `YYYY-MM-DD` (machine clock).
  final String day;
  final int pairId;
  final int seconds;
  final int words;
}
