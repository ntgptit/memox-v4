/// Machine-clock day key `YYYY-MM-DD` — the `daily_activity.day` format shared by
/// study finalize and streak computation (`docs/database/schema-contract.md`).
String dayKey(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
