/// Consecutive days meeting the daily goal (`docs/contracts/types-catalog.md`).
/// Resets to 0 on a missed day; no streak-saver in v1 (D-021).
class Streak {
  const Streak(this.days) : assert(days >= 0, 'streak cannot be negative');

  final int days;
}
