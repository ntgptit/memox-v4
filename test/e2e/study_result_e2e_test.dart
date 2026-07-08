// E2E — study-result (S.21). Tag `e2e`. Map SC-RESULT-* (docs/scenarios/study-result.md).
// Màn read-only: đọc daily_activity (hôm nay) + goal (settings) + streak + wrongCount. Headline
// do TRẠNG THÁI DB quyết (standard / goalMet / goalMissed). Lối vào tự nhiên là kết phiên học;
// ở đây điều hướng thẳng bằng GoRouter tới '/study/result' + seed DB.
@Tags(['e2e'])
library;

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox_v4/presentation/features/study-result/screens/study_result_screen.dart';
import 'package:memox_v4/presentation/features/study-result/widgets/result_hero.dart';
import 'package:memox_v4/presentation/features/study-result/widgets/streak_goal_card.dart';

import 'support/e2e_harness.dart';

// UTC midnight of the harness's fixed `now` (2026-07-03) — the daily_activity.day key.
final int _today = DateTime.utc(2026, 7, 3).microsecondsSinceEpoch;

Future<void> seedResult(E2EHarness h,
    {required int words, required int minutes, int? goalWords}) async {
  await h.db.into(h.db.dailyActivity).insert(DailyActivityCompanion.insert(
        day: Value(_today),
        minutes: Value(minutes),
        words: Value(words),
      ));
  if (goalWords != null) {
    await h.db.into(h.db.settings).insert(
          SettingsCompanion.insert(key: 'goal.words_target', value: '$goalWords'),
        );
  }
}

Future<void> gotoStudyResult(WidgetTester tester) async {
  GoRouter.of(tester.element(find.byType(DashboardScreen))).go('/study/result');
  await settle(tester);
  expect(find.byType(StudyResultScreen), findsOneWidget);
}

void main() {
  final now = DateTime.utc(2026, 7, 3, 9);

  // SC-RESULT · không có goal (unconfigured) ⇒ headline "Session complete"
  testWidgets('no goal configured → standard headline + stats', (tester) async {
    await pumpApp(tester, now: now, seed: (h) => seedResult(h, words: 8, minutes: 14));
    await gotoStudyResult(tester);

    expect(find.byType(ResultHero), findsOneWidget);
    expect(find.byType(StreakGoalCard), findsOneWidget);
    expect(find.text('Session complete'), findsOneWidget);
    expect(find.text('words'), findsOneWidget); // stat tile label
  });

  // SC-RESULT · đạt goal (words 8 ≥ target 5) ⇒ "Daily goal reached!"
  testWidgets('goal met → celebratory headline', (tester) async {
    await pumpApp(tester, now: now,
        seed: (h) => seedResult(h, words: 8, minutes: 14, goalWords: 5));
    await gotoStudyResult(tester);

    expect(find.text('Daily goal reached!'), findsOneWidget);
  });

  // SC-RESULT · chưa đạt goal (words 8 < target 20) ⇒ "Almost there!"
  testWidgets('goal configured but missed → almost-there headline',
      (tester) async {
    await pumpApp(tester, now: now,
        seed: (h) => seedResult(h, words: 8, minutes: 14, goalWords: 20));
    await gotoStudyResult(tester);

    expect(find.text('Almost there!'), findsOneWidget);
  });
}
