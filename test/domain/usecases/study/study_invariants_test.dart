import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/domain/entities/daily_goal.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/streak.dart';
import 'package:memox_v4/domain/entities/study_mode.dart';
import 'package:memox_v4/domain/entities/study_session.dart';
import 'package:memox_v4/domain/usecases/study/streak_rollover.dart';

/// V.2 — invariant sweep for the engagement/study use cases (streak roll-over +
/// daily-activity summation), complementing the example-based tests. Covers
/// D-021 (streak advance/reset) and D-010 (only counting sessions accumulate).
StudySession _session(String id, {required int minutes, required int words}) =>
    StudySession(
      id: StudySessionId(id),
      deckId: const DeckId('d'),
      mode: StudyMode.newLearn,
      startedAt: DateTime.utc(2026, 7, 3, 9),
      durationMinutes: minutes,
      wordsStudied: words,
    );

void main() {
  group('dailyActivityFrom (D-010)', () {
    test('empty sessions sum to zero', () {
      expect(dailyActivityFrom(const []), (minutes: 0, words: 0));
    });

    test('sums minutes and words across sessions', () {
      final activity = dailyActivityFrom([
        _session('a', minutes: 6, words: 3),
        _session('b', minutes: 4, words: 7),
      ]);
      expect(activity, (minutes: 10, words: 10));
    });
  });

  group('rollOverStreak (D-021)', () {
    const goal = DailyGoal(minutesTarget: 15, wordsTarget: 20);

    DailyActivity act(int minutes, int words) => (minutes: minutes, words: words);

    test('meeting either target advances; the record ratchets', () {
      const start = Streak(current: 4, longest: 9);
      final byMinutes =
          rollOverStreak(current: start, goal: goal, activity: act(15, 0));
      expect(byMinutes.current, 5);
      final byWords =
          rollOverStreak(current: start, goal: goal, activity: act(0, 20));
      expect(byWords.current, 5);
    });

    test('a met day that sets a record raises longest', () {
      const atRecord = Streak(current: 9, longest: 9);
      final next =
          rollOverStreak(current: atRecord, goal: goal, activity: act(20, 0));
      expect(next.current, 10);
      expect(next.longest, 10);
    });

    test('a missed day resets current to 0 but preserves longest', () {
      const start = Streak(current: 7, longest: 12);
      final next =
          rollOverStreak(current: start, goal: goal, activity: act(5, 5));
      expect(next.current, 0);
      expect(next.longest, 12);
    });

    test('longest never decreases across an arbitrary met/missed sequence', () {
      var streak = Streak.zero;
      const days = [true, true, false, true, true, true, false, false, true];
      var maxLongest = 0;
      for (final met in days) {
        streak = rollOverStreak(
          current: streak,
          goal: goal,
          activity: met ? act(20, 0) : act(0, 0),
        );
        expect(streak.longest, greaterThanOrEqualTo(maxLongest));
        expect(streak.longest, greaterThanOrEqualTo(streak.current));
        maxLongest = streak.longest;
      }
    });

    test('an unconfigured goal can never be met — every day resets', () {
      const noGoal = DailyGoal();
      final next = rollOverStreak(
          current: const Streak(current: 3, longest: 3),
          goal: noGoal,
          activity: act(999, 999));
      expect(next.current, 0);
    });
  });

  group('Streak entity invariants', () {
    test('advanced/reset keep longest >= current through any sequence', () {
      var streak = Streak.zero;
      const ops = [true, true, true, false, true, false, false, true, true];
      for (final advance in ops) {
        streak = advance ? streak.advanced() : streak.reset();
        expect(streak.longest, greaterThanOrEqualTo(streak.current));
        expect(streak.current, greaterThanOrEqualTo(0));
      }
    });

    test('advanced raises longest only when it exceeds the record', () {
      final below = const Streak(current: 2, longest: 5).advanced();
      expect(below.current, 3);
      expect(below.longest, 5); // still under the record

      final atRecord = const Streak(current: 5, longest: 5).advanced();
      expect(atRecord.longest, 6);
    });
  });
}
