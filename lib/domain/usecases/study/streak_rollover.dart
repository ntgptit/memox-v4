import 'package:memox_v4/domain/entities/daily_goal.dart';
import 'package:memox_v4/domain/entities/streak.dart';
import 'package:memox_v4/domain/entities/study_session.dart';

/// A day's study effort — minutes and words. Only "Lặp lại"/"Học" sessions exist
/// as [StudySession]s, and those are exactly the activities that count toward the
/// day (engagement BR-1 / D-010).
typedef DailyActivity = ({int minutes, int words});

/// Sums the day's activity from its finished sessions.
DailyActivity dailyActivityFrom(Iterable<StudySession> sessions) {
  var minutes = 0;
  var words = 0;
  for (final session in sessions) {
    minutes += session.durationMinutes;
    words += session.wordsStudied;
  }
  return (minutes: minutes, words: words);
}

/// Rolls the streak over at day close (midnight, machine time): meeting at least
/// one goal target advances it, otherwise it resets to zero (engagement BR-3 /
/// D-021). Pure — the caller decides when a day closes and persists the result.
Streak rollOverStreak({
  required Streak current,
  required DailyGoal goal,
  required DailyActivity activity,
}) {
  final met = goal.isMetBy(minutes: activity.minutes, words: activity.words);
  return met ? current.advanced() : current.reset();
}
