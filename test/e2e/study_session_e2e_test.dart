// E2E — study-session (S.20), lõi SRS. Tag `e2e`. Map SC-STUDY-* (docs/scenarios/study-srs.md).
// DueReview ("Lặp lại"): chấm pass/fail → GHI srs_state (box ±1) + review_logs + daily_activity
// (D-003/D-004/D-010). Seed CHỈ thẻ đến hạn ⇒ phiên vào thẳng dueReview. Điều hướng: push '/study'.
@Tags(['e2e'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox_v4/presentation/features/study-session/screens/study_session_screen.dart';

import 'support/e2e_harness.dart';

Future<void> openStudy(WidgetTester tester) async {
  GoRouter.of(tester.element(find.byType(DashboardScreen))).push('/study');
  await settle(tester);
  expect(find.byType(StudySessionScreen), findsOneWidget);
}

void main() {
  final now = DateTime.utc(2026, 7, 3, 9);

  // SC-STUDY-03 · DueReview chấm Đúng → lên 1 ô + dời hạn + review_logs + daily_activity
  testWidgets('grading a due card "Next" (pass) advances the box (D-003)',
      (tester) async {
    final h = await pumpApp(tester, now: now, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
      await h.seedCard(id: 'c0', deck: 'd1', term: '고양이', meaning: 'cat');
      await h.seedSrs(cardId: 'c0', box: 1, dueAt: now.subtract(const Duration(hours: 1)));
    });
    await openStudy(tester);

    // Stage dueReview: chạm "Next" = chấm Đúng.
    await tester.tap(find.text('Next'));
    await settle(tester);

    final srs = (await h.db.select(h.db.srsStates).get()).single;
    expect(srs.cardId, 'c0');
    expect(srs.box, 2); // box 1 → 2 khi Đúng
    expect(srs.dueAt, isNotNull);
    expect(srs.dueAt! > now.microsecondsSinceEpoch, isTrue); // dời hạn về tương lai
    // review_logs +1
    expect((await h.db.select(h.db.reviewLogs).get()).length, 1);
    // daily_activity: DueReview đóng góp (D-010) — hôm nay có ≥1 từ.
    final activity = (await h.db.select(h.db.dailyActivity).get()).single;
    expect(activity.words >= 1, isTrue);
  });

  // SC-STUDY-04 · DueReview chấm Sai → lùi 1 ô (sàn ô 1) + review_logs (D-004)
  testWidgets('grading a due card "Relearn" (fail) drops the box (D-004)',
      (tester) async {
    final h = await pumpApp(tester, now: now, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
      await h.seedCard(id: 'c0', deck: 'd1', term: '학교', meaning: 'school');
      await h.seedSrs(cardId: 'c0', box: 3, dueAt: now.subtract(const Duration(hours: 1)));
    });
    await openStudy(tester);

    await tester.tap(find.text('Relearn')); // chấm Sai
    await settle(tester);

    final srs = (await h.db.select(h.db.srsStates).get()).single;
    expect(srs.cardId, 'c0');
    expect(srs.box, 2); // box 3 → 2 khi Sai (lùi 1, sàn ô 1)
    expect((await h.db.select(h.db.reviewLogs).get()).length, 1);
  });
}
