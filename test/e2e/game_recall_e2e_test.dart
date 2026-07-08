// E2E — game-recall (S.16). Tag `e2e`. Map SC-RECALL-* (docs/scenarios/game-recall.md).
// Trò chơi KHÔNG ghi DB (D-013) — assert cơ chế (show → tự chấm Got it/Forgot → complete) +
// bất biến srs_state. Vào màn: Library → deck → play-sheet → Single game → game-picker → Recall.
@Tags(['e2e'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/features/game-recall/screens/game_recall_screen.dart';
import 'package:memox_v4/presentation/features/game-picker/widgets/game_option.dart';
import 'package:memox_v4/presentation/shared/composites/mx_menu_item.dart';

import 'support/e2e_harness.dart';

Future<void> seedPlayable(E2EHarness h, DateTime now) async {
  await h.seedPair();
  await h.seedDeck(id: 'd1', name: 'Deck');
  const cards = [('c0', '고양이', 'cat'), ('c1', '개', 'dog'), ('c2', '물', 'water'), ('c3', '불', 'fire')];
  for (final (id, term, meaning) in cards) {
    await h.seedCard(id: id, deck: 'd1', term: term, meaning: meaning);
    await h.seedSrs(cardId: id, box: 1, dueAt: now.subtract(const Duration(hours: 1)));
  }
}

Future<void> openRecall(WidgetTester tester) async {
  await tester.tap(find.text('Library'));
  await settle(tester);
  await tester.tap(find.text('Deck'));
  await settle(tester);
  await tester.tap(find.widgetWithIcon(MxMenuItem, Icons.sports_esports));
  await settle(tester);
  await tester.tap(find.widgetWithText(GameOption, 'Recall'));
  await settle(tester);
  expect(find.byType(GameRecallScreen), findsOneWidget);
}

void main() {
  final now = DateTime.utc(2026, 7, 3, 9);

  // SC-RECALL · render — term + nút "Show" + progress 0/4
  testWidgets('round renders term with Show and 0/total progress',
      (tester) async {
    await pumpApp(tester, now: now, seed: (h) => seedPlayable(h, now));
    await openRecall(tester);

    expect(find.text('Show'), findsOneWidget);
    expect(find.text('0/4'), findsOneWidget);
  });

  // SC-RECALL · Show → lộ nghĩa + nút Got it / Forgot
  testWidgets('Show reveals the meaning and self-grade actions', (tester) async {
    await pumpApp(tester, now: now, seed: (h) => seedPlayable(h, now));
    await openRecall(tester);

    await tester.tap(find.text('Show'));
    await settle(tester);
    expect(find.text('Got it'), findsOneWidget);
    expect(find.text('Forgot'), findsOneWidget);
  });

  // SC-RECALL · Got it hết → "Round complete!"
  testWidgets('grading every card "Got it" completes the round', (tester) async {
    await pumpApp(tester, now: now, seed: (h) => seedPlayable(h, now));
    await openRecall(tester);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Show'));
      await settle(tester);
      await tester.tap(find.text('Got it'));
      await settle(tester);
    }
    expect(find.text('Round complete!'), findsOneWidget);
  });

  // SC-RECALL · D-013 — chơi KHÔNG đổi srs_state
  testWidgets('playing does not mutate srs_state (D-013)', (tester) async {
    final h = await pumpApp(tester, now: now, seed: (h) => seedPlayable(h, now));
    await openRecall(tester);
    await tester.tap(find.text('Show'));
    await settle(tester);
    await tester.tap(find.text('Got it'));
    await settle(tester);

    final srs = await h.db.select(h.db.srsStates).get();
    expect(srs.length, 4);
    expect(srs.every((s) => s.box == 1), isTrue);
  });
}
