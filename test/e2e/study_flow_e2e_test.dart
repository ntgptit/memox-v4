import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/utils/clock.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/data/providers/database_provider.dart';
import 'package:memox_v4/domain/entities/daily_goal.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/review_grade.dart';
import 'package:memox_v4/presentation/features/dashboard/providers/dashboard_providers.dart';
import 'package:memox_v4/presentation/features/study-session/providers/study_session_providers.dart';

/// V.4 — the full study loop end-to-end: due → grade → box move → goal/streak,
/// driven through the **real** providers (study-session + dashboard controllers)
/// over a **real** Drift DB (in-memory), not the fakes. Ties FE (the Riverpod
/// controllers) to BE (repositories + services + Drift). Covers D-003 (grade →
/// box move), D-002 (graduate), D-010 (session counts), D-021 (goal/streak).
class _FixedClock implements Clock {
  const _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

void main() {
  final now = DateTime.utc(2026, 7, 3, 9);
  final today = DateTime.utc(2026, 7, 3);

  late AppDatabase db;
  late ProviderContainer container;

  ProviderContainer boot() {
    db = AppDatabase.memory();
    final c = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(_FixedClock(now)),
    ]);
    addTearDown(c.dispose);
    addTearDown(db.close);
    return c;
  }

  Future<void> seedDeck() async {
    await db.into(db.languagePairs).insert(LanguagePairsCompanion.insert(
        id: 'lp',
        learningLanguage: 'ko',
        nativeLanguage: 'vi',
        createdAt: 0,
        isActive: const Value(true)));
    await db.into(db.decks).insert(DecksCompanion.insert(
        id: 'd', name: 'Deck', languagePairId: 'lp', createdAt: 0));
  }

  Future<void> seedCard(String id, String term, String meaning) async {
    await db.into(db.cards).insert(CardsCompanion.insert(
        id: id, deckId: 'd', term: term, createdAt: 0));
    await db.into(db.cardMeanings).insert(CardMeaningsCompanion.insert(
        id: 'm-$id', cardId: id, language: 'vi', content: meaning));
  }

  T ok<T>(Result<T> r) => (r as Ok<T>).value;

  /// Let the controller's fire-and-forget session record settle.
  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 40));

  test('due review: grade pass moves the box + updates goal & streak', () async {
    container = boot();
    await seedDeck();
    await seedCard('c-due', '학교', 'trường học');
    // Due an hour ago, box 1.
    await db.into(db.srsStates).insert(SrsStatesCompanion.insert(
        cardId: 'c-due',
        box: 1,
        dueAt: Value(now.subtract(const Duration(hours: 1)).microsecondsSinceEpoch)));
    // A one-word goal so a single reviewed card meets it today.
    ok(await container
        .read(settingsRepositoryProvider)
        .saveDailyGoal(const DailyGoal(wordsTarget: 1)));

    // The real session controller builds a single due-review step over Drift.
    final start = await container.read(studySessionControllerProvider.future);
    expect(start.current!.kind, StudyStageKind.dueReview);
    expect(start.current!.card.id.value, 'c-due');

    // Grade it correct → GradeCardUseCase → SRS box move + review log (D-003).
    await container
        .read(studySessionControllerProvider.notifier)
        .gradeDue(ReviewGrade.pass);
    await settle();

    // BE: the box moved 1 → 2 and the outcome was logged.
    expect(ok(await container.read(reviewRepositoryProvider).currentBox(
            const CardId('c-due')))
        .value, 2);
    expect((await db.select(db.reviewLogs).get()).single.grade, 'pass');

    // The session counted toward the day (D-010).
    final activity =
        ok(await container.read(dailyActivityServiceProvider).activityOn(today));
    expect(activity.words, greaterThanOrEqualTo(1));

    // FE: the dashboard (real, over Drift) now reads the goal as met + a streak.
    final dash = await container.read(dashboardControllerProvider.future);
    expect(dash.goalMet, isTrue);
    expect(dash.streak.current, 1);
  });

  test('new learn: walking the 5 stages graduates the card into box 1', () async {
    container = boot();
    await seedDeck();
    await seedCard('c-new', '친구', 'bạn'); // no SRS row → new

    // Pin the session provider so it isn't auto-disposed across `settle()`
    // (a fresh read would otherwise rebuild it into an empty/loading session).
    container.listen(studySessionControllerProvider, (_, _) {});
    final notifier = container.read(studySessionControllerProvider.notifier);
    StudySessionState read() =>
        container.read(studySessionControllerProvider).requireValue;

    await container.read(studySessionControllerProvider.future);
    expect(read().current!.kind, StudyStageKind.review);

    notifier.advance(); // review → matching
    final matching = read().current!;
    for (final tile in matching.terms) {
      notifier.selectTerm(tile.cardId);
      notifier.selectMeaning(tile.cardId);
    }
    final choice = read().current!;
    expect(choice.kind, StudyStageKind.choice);
    notifier.choose(choice.correctChoice); // → recall
    notifier.reveal();
    notifier.advance(); // → typing
    expect(read().current!.kind, StudyStageKind.typing);
    await notifier.checkTyping(); // graduate (D-002) → complete
    await settle();

    expect(read().isComplete, isTrue);
    // BE: the new card graduated into box 1, scheduled one day out.
    expect(ok(await container.read(reviewRepositoryProvider).currentBox(
            const CardId('c-new')))
        .value, 1);
    final srs =
        (await db.select(db.srsStates).get()).firstWhere((s) => s.cardId == 'c-new');
    expect(srs.dueAt, isNotNull);
  });
}
