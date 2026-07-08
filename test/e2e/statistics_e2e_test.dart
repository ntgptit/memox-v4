// E2E — statistics (S.09). Tag `e2e`. Map SC-STATS-* (docs/scenarios/statistics.md).
// Read-only, DB-driven: hasActivity = có daily_activity; overview (total/mastered/due) suy từ
// cards + srs_state. Vào màn: bottom-nav "Stats".
@Tags(['e2e'])
library;

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/data/datasources/local/app_database.dart';
import 'package:memox_v4/presentation/features/statistics/screens/statistics_screen.dart';
import 'package:memox_v4/presentation/features/statistics/widgets/donut.dart';
import 'package:memox_v4/presentation/features/statistics/widgets/heatmap.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';

import 'support/e2e_harness.dart';

/// The stat tile (MxCard) that carries [label] — scopes the value assertion so
/// a shared number (e.g. a Leitner bar) elsewhere doesn't cause a false match.
Finder statValue(String label, String value) => find.descendant(
      of: find.ancestor(of: find.text(label), matching: find.byType(MxCard)),
      matching: find.text(value),
    );

final int _today = DateTime.utc(2026, 7, 3).microsecondsSinceEpoch;

Future<void> openStats(WidgetTester tester) async {
  await tester.tap(find.text('Stats'));
  await settle(tester);
  expect(find.byType(StatisticsScreen), findsOneWidget);
}

void main() {
  final now = DateTime.utc(2026, 7, 3, 9);

  // SC-STATS · chưa có hoạt động ⇒ "Not enough data"
  testWidgets('no activity history → insufficient state', (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
    });
    await openStats(tester);
    expect(find.text('Not enough data'), findsOneWidget);
  });

  // SC-STATS · có hoạt động ⇒ loaded; overview (total/mastered/due) khớp DB
  testWidgets('with activity → loaded overview reflects DB counts',
      (tester) async {
    await pumpApp(tester, now: now, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
      // 5 thẻ hiện: 2 mastered (box 8), 1 due (box 1 quá hạn), 2 new (không srs).
      for (var i = 0; i < 5; i++) {
        await h.seedCard(id: 'c$i', deck: 'd1', term: 't$i', meaning: 'm$i');
      }
      await h.seedSrs(cardId: 'c0', box: 8);
      await h.seedSrs(cardId: 'c1', box: 8);
      await h.seedSrs(cardId: 'c2', box: 1, dueAt: now.subtract(const Duration(hours: 1)));
      // 1 dòng hoạt động ⇒ hasActivity = true.
      await h.db.into(h.db.dailyActivity).insert(DailyActivityCompanion.insert(
            day: Value(_today),
            minutes: const Value(10),
            words: const Value(4),
          ));
    });
    await openStats(tester);

    expect(find.byType(Heatmap), findsOneWidget);
    expect(find.byType(Donut), findsOneWidget);
    expect(find.text('Library overview'), findsOneWidget);
    expect(statValue('total', '5'), findsOneWidget); // total visible = 5
    expect(statValue('mastered', '2'), findsOneWidget); // mastered = 2 (box 8)
    expect(statValue('due', '1'), findsOneWidget); // due = 1
  });
}
