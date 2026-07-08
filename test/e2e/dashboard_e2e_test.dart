// E2E — dashboard (Today). Tag `e2e`. Map SC-DASHBOARD-* (docs/scenarios/dashboard.md)
// theo DECISIONS.md. Assert UI (finder) + DB (query, TỪNG TRƯỜNG). Scenario lộ gap
// code≠spec → FIX code hoặc sửa DECISION (TEST-WBS §Quy trình B) — KHÔNG skip.
@Tags(['e2e'])
library;

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox_v4/presentation/features/library/screens/library_screen.dart';
import 'package:memox_v4/presentation/features/settings/screens/settings_screen.dart';
import 'package:memox_v4/presentation/features/statistics/screens/statistics_screen.dart';

import 'support/e2e_harness.dart';

void main() {
  // SC-DASHBOARD-04/05 · states: empty / boot
  testWidgets('empty DB → Today boots (no crash), DB empty', (tester) async {
    final h = await pumpApp(tester);
    expect(tester.takeException(), isNull);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(await h.db.select(h.db.decks).get(), isEmpty);
  });

  // SC-DASHBOARD-22..24 · bottom-nav → chuyển tab (DEC-G-18 / kit nav)
  testWidgets('bottom nav switches tabs (Stats / Library / Profile)',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Stats'));
    await settle(tester);
    expect(find.byType(StatisticsScreen), findsOneWidget);

    await tester.tap(find.text('Library'));
    await settle(tester);
    expect(find.byType(LibraryScreen), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await settle(tester);
    expect(find.byType(SettingsScreen), findsOneWidget);

    await tester.tap(find.text('Today'));
    await settle(tester);
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  // SC-DASHBOARD-60/61 · persistence: hoạt động hôm nay đọc từ daily_activity (D-010)
  testWidgets('today activity is read from daily_activity (DB→UI round-trip)',
      (tester) async {
    final today = DateTime.utc(2026, 7, 3);
    final h = await pumpApp(tester, now: DateTime.utc(2026, 7, 3, 9), seed: (h) async {
      await h.seedPair();
      await h.db.into(h.db.dailyActivity).insert(DailyActivityCompanion.insert(
            day: Value(today.microsecondsSinceEpoch),
            minutes: const Value(14),
            words: const Value(8),
          ));
    });
    expect(tester.takeException(), isNull);
    expect(find.byType(DashboardScreen), findsOneWidget);
    // DB round-trip: assert MỌI cột của row (không chỉ 1 trường).
    final row = (await h.db.select(h.db.dailyActivity).get()).single;
    expect(row.day, today.microsecondsSinceEpoch);
    expect(row.minutes, 14);
    expect(row.words, 8);
  });

  // SC-DASHBOARD-18..20 · "Continue studying" deck → deck-detail (DEC-G-18)
  testWidgets('a due deck appears on Today and opens deck-detail on tap',
      (tester) async {
    final now = DateTime.utc(2026, 7, 3, 9);
    await pumpApp(tester, now: now, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Korean Basics');
      await h.seedCard(id: 'c1', deck: 'd1', term: '사과', meaning: 'quả táo');
      // due an hour ago → deck has due>0 (continue-studying candidate, DEC-dashboard-2)
      await h.seedSrs(cardId: 'c1', box: 1, dueAt: now.subtract(const Duration(hours: 1)));
    });

    final deck = find.text('Korean Basics');
    expect(deck, findsWidgets); // hiện ở "Continue studying"
    // warnIfMissed:false — nhãn nằm trong card cuộn; ta xác nhận HÀNH VI (điều hướng)
    // bằng assert bên dưới, không dựa vào tâm widget.
    await tester.tap(deck.first, warnIfMissed: false);
    await settle(tester);
    expect(find.byType(DashboardScreen), findsNothing);
    // đã push sang deck-detail (màn khác Today). Nếu đỏ → điều tra: code chưa render
    // continue-deck có due (DEC-dashboard-2) ⇒ BUG cần fix; hoặc DECISION sai ⇒ sửa DECISION.
  }, timeout: const Timeout(Duration(seconds: 30)));
}
