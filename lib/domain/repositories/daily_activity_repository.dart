import 'package:memox_v4/domain/entities/daily_activity.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Persists per-day study totals (`daily_activity`). Adds are cumulative within a
/// day. Errors map to [Failure] at the boundary.
abstract interface class DailyActivityRepository {
  /// Adds [seconds] and [words] to the [pairId]/[day] total (creating the row).
  Future<Result<void>> add({
    required int pairId,
    required String day,
    required int seconds,
    required int words,
  });

  /// The totals for a day, or null when nothing has been recorded.
  Future<Result<DailyActivity?>> forDay(int pairId, String day);

  /// Every recorded day for a pair — the input to streak computation.
  Future<Result<List<DailyActivity>>> allForPair(int pairId);
}
