import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/utils/clock.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/daily_goal.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/review_grade.dart';
import 'package:memox_v4/domain/entities/review_log.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/entities/streak.dart';
import 'package:memox_v4/domain/entities/study_mode.dart';
import 'package:memox_v4/domain/entities/study_session.dart';
import 'package:memox_v4/domain/repositories/review_repository.dart';
import 'package:memox_v4/domain/usecases/srs/srs_scheduler.dart';
import 'package:memox_v4/domain/usecases/study/build_study_queue.dart';
import 'package:memox_v4/domain/usecases/study/grade_card.dart';
import 'package:memox_v4/domain/usecases/study/graduate_card.dart';
import 'package:memox_v4/domain/usecases/study/streak_rollover.dart';

class _FixedClock implements Clock {
  const _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

BoxLevel _box(int v) => (BoxLevel.of(v) as Ok<BoxLevel>).value;

/// Records writes and serves canned reads, so the use-case orchestration can be
/// asserted without a real store. (Full fakes arrive in DM.9.)
class _FakeReviewRepository implements ReviewRepository {
  _FakeReviewRepository({required this.box});

  BoxLevel box;
  int? newQueueLimit;
  ({CardId cardId, BoxLevel box, DateTime? dueAt})? savedSchedule;
  ReviewLog? loggedReview;

  @override
  Future<Result<BoxLevel>> currentBox(CardId cardId) async => Ok(box);

  @override
  Future<Result<void>> saveSchedule({
    required CardId cardId,
    required BoxLevel box,
    DateTime? dueAt,
  }) async {
    savedSchedule = (cardId: cardId, box: box, dueAt: dueAt);
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> logReview(ReviewLog log) async {
    loggedReview = log;
    return const Ok<void>(null);
  }

  @override
  Future<Result<List<Card>>> newQueue({DeckId? within, required int limit}) async {
    newQueueLimit = limit;
    return const Ok([]);
  }

  @override
  Future<Result<List<Card>>> dueQueue({
    DeckId? within,
    required DateTime asOf,
    int? limit,
  }) async =>
      const Ok([]);

  @override
  Stream<int> watchDueCount({DeckId? within}) => Stream.value(0);
}

void main() {
  final now = DateTime.utc(2026, 7, 3, 9);
  final scheduler = SrsScheduler(_FixedClock(now));
  const cardId = CardId('c1');

  test('GraduateCard persists box 1 with a due date (D-002)', () async {
    final repo = _FakeReviewRepository(box: BoxLevel.newCard);
    final result = await GraduateCard(reviews: repo, scheduler: scheduler).call(cardId);

    expect(result, isA<Ok<SrsState>>());
    expect(repo.savedSchedule!.box, BoxLevel.firstBox);
    expect(repo.savedSchedule!.dueAt, now.add(const Duration(days: 1)));
  });

  group('GradeCard', () {
    test('pass promotes, saves the new schedule, and logs the outcome', () async {
      final repo = _FakeReviewRepository(box: _box(3));
      final result =
          await GradeCard(reviews: repo, scheduler: scheduler).call(cardId: cardId, grade: ReviewGrade.pass);

      expect(result, isA<Ok<SrsState>>());
      expect(repo.savedSchedule!.box, _box(4));
      expect(repo.savedSchedule!.dueAt, now.add(const Duration(days: 14)));
      expect(repo.loggedReview!.grade, ReviewGrade.pass);
      expect(repo.loggedReview!.reviewedAt, now); // agrees with the scheduler
    });

    test('fail demotes and reschedules', () async {
      final repo = _FakeReviewRepository(box: _box(5));
      await GradeCard(reviews: repo, scheduler: scheduler).call(cardId: cardId, grade: ReviewGrade.fail);
      expect(repo.savedSchedule!.box, _box(4));
    });
  });

  group('BuildStudyQueue.newCards caps intake (D-018)', () {
    test('limit = remaining allowance, never over the per-day cap', () async {
      final repo = _FakeReviewRepository(box: BoxLevel.newCard);
      final queue = BuildStudyQueue(reviews: repo, scheduler: scheduler);

      await queue.newCards(perDayCap: 20, introducedToday: 18);
      expect(repo.newQueueLimit, 2);

      await queue.newCards(perDayCap: 20, introducedToday: 20);
      expect(repo.newQueueLimit, 0);
    });
  });

  group('streak roll-over (D-021)', () {
    StudySession session(int minutes, int words) => StudySession(
          id: const StudySessionId('s'),
          deckId: const DeckId('d'),
          mode: StudyMode.dueReview,
          startedAt: now,
          durationMinutes: minutes,
          wordsStudied: words,
        );

    test('sums the day activity from sessions', () {
      final activity = dailyActivityFrom([session(5, 10), session(7, 4)]);
      expect(activity.minutes, 12);
      expect(activity.words, 14);
    });

    test('meeting a goal advances; missing resets', () {
      const goal = DailyGoal(minutesTarget: 10, wordsTarget: 20);
      const streak = Streak(current: 3, longest: 5);

      final met = rollOverStreak(current: streak, goal: goal, activity: (minutes: 10, words: 0));
      expect(met.current, 4);

      final missed = rollOverStreak(current: streak, goal: goal, activity: (minutes: 0, words: 0));
      expect(missed.current, 0);
      expect(missed.longest, 5);
    });
  });
}
