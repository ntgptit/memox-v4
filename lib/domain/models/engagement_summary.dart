import 'package:memox_v4/domain/types/daily_goal.dart';
import 'package:memox_v4/domain/types/streak.dart';

/// Today's effort + goal + streak + library snapshot for the dashboard.
class EngagementSummary {
  const EngagementSummary({
    required this.seconds,
    required this.words,
    required this.goal,
    required this.streak,
    required this.dueCount,
    required this.masteredCount,
    required this.totalWords,
  });

  final int seconds;
  final int words;
  final DailyGoal goal;
  final Streak streak;
  final int dueCount;
  final int masteredCount;
  final int totalWords;

  bool get goalMet => goal.isMetBy(seconds, words);
  bool get hasActivity => seconds > 0 || words > 0;

  /// Progress toward the goal (0..1) by the better of minutes/words; 0 if no goal.
  double get goalProgress {
    if (!goal.hasGoal) return 0;
    final byMinutes = (goal.minutes != null && goal.minutes! > 0)
        ? (seconds / 60) / goal.minutes!
        : 0.0;
    final byWords = (goal.words != null && goal.words! > 0)
        ? words / goal.words!
        : 0.0;
    final progress = byMinutes > byWords ? byMinutes : byWords;
    return progress > 1 ? 1.0 : progress;
  }

  double get masteredProgress =>
      totalWords == 0 ? 0 : masteredCount / totalWords;
}
