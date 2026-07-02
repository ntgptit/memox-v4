import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/daily_goal.dart';

/// The settings contract. **Frozen** once screens code against it (R4).
///
/// Read/write policy: `watch*` streams are the live read source (settings drive
/// the dashboard goal + the new-card cap reactively); setters return void or a
/// [Failure]. Theme / reminder / language settings are added with their own
/// entities in the settings work (DM.8) — this is the foundational subset the
/// SRS + engagement flows depend on.
abstract interface class SettingsRepository {
  /// The learner's daily goal (engagement). Emits the current value + updates.
  Stream<DailyGoal> watchDailyGoal();

  Future<Result<void>> saveDailyGoal(DailyGoal goal);

  /// The per-day new-card cap (D-018, default 20). Emits the current value +
  /// updates.
  Stream<int> watchNewCardsPerDay();

  Future<Result<void>> saveNewCardsPerDay(int count);
}
