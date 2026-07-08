// E2E harness smoke (TEST-WBS T.0). Tag `e2e`.
@Tags(['e2e'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/features/dashboard/screens/dashboard_screen.dart';

import 'support/e2e_harness.dart';

void main() {
  testWidgets('boots the real app over an empty in-memory Drift DB (no crash)',
      (tester) async {
    final h = await pumpApp(tester);

    expect(tester.takeException(), isNull);
    // Booted into the Today tab shell over the real (empty) DB.
    expect(find.byType(DashboardScreen), findsOneWidget);
    // The DB is real and starts empty (migration created the tables).
    expect(await h.db.select(h.db.decks).get(), isEmpty);
    expect(await h.db.select(h.db.cards).get(), isEmpty);
  });

  testWidgets('seed helpers persist through the real DB (round-trip)',
      (tester) async {
    final h = await pumpApp(tester, seed: (h) async {
      await h.seedPair(id: 'lp-ko', learning: '한국어', native: 'English');
      await h.seedDeck(id: 'd1', name: 'Korean Basics', pair: 'lp-ko');
      await h.seedCard(id: 'c1', deck: 'd1', term: '사과', meaning: 'quả táo');
    });

    expect((await h.db.select(h.db.languagePairs).get()).map((r) => r.id),
        contains('lp-ko'));
    expect((await h.db.select(h.db.decks).get()).single.name, 'Korean Basics');
    expect((await h.db.select(h.db.cards).get()).single.term, '사과');
  });
}
