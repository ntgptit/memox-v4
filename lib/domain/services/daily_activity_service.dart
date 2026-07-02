import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/study_session.dart';

/// Persists and reads the day's study effort (`daily_activity`). Only
/// "Lặp lại"/"Học" sessions are recorded, and those are the only ones that count
/// toward the day (engagement BR-1 / D-010). Feeds the dashboard, streak, and the
/// stats heatmap.
abstract interface class DailyActivityService {
  /// Add a finished session's minutes + words to its day's totals.
  Future<Result<void>> record(StudySession session);

  /// The accumulated activity on a given calendar day (machine time).
  Future<Result<({int minutes, int words})>> activityOn(DateTime day);

  /// The dated history for the heatmap + streak computation.
  Stream<Map<DateTime, ({int minutes, int words})>> watchHistory();
}
