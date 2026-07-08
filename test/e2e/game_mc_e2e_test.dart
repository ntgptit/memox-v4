// E2E — game-mc (S.15, multiple choice). Tag `e2e`. Map SC-MC-* (docs/scenarios/game-mc.md).
// Trò chơi KHÔNG ghi DB (D-013) — assert cơ chế (render/answer/complete) + bất biến srs_state.
// Prompt = term, 4 lựa chọn = nghĩa (1 đúng + 3 nhiễu). Vào màn: Library → deck → play-sheet →
// Single game → game-picker → Multiple choice.
@Tags(['e2e'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/features/game-mc/screens/game_mc_screen.dart';
import 'package:memox_v4/presentation/features/game-picker/widgets/game_option.dart';
import 'package:memox_v4/presentation/shared/composites/mx_menu_item.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_choice_option.dart';

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

Future<void> openMc(WidgetTester tester) async {
  await tester.tap(find.text('Library'));
  await settle(tester);
  await tester.tap(find.text('Deck'));
  await settle(tester);
  await tester.tap(find.widgetWithIcon(MxMenuItem, Icons.sports_esports)); // game-picker
  await settle(tester);
  await tester.tap(find.widgetWithText(GameOption, 'Multiple choice'));
  await settle(tester);
  expect(find.byType(GameMcScreen), findsOneWidget);
}

void main() {
  final now = DateTime.utc(2026, 7, 3, 9);

  // SC-MC · render — prompt + 4 lựa chọn + progress 0/4
  testWidgets('round renders prompt + 4 choices with 0/total progress',
      (tester) async {
    await pumpApp(tester, now: now, seed: (h) => seedPlayable(h, now));
    await openMc(tester);

    expect(find.byType(MxChoiceOption), findsNWidgets(4));
    expect(find.text('0/4'), findsOneWidget);
  });

  // SC-MC · trả lời → khoá lựa chọn + hiện "Next"
  testWidgets('answering locks choices and reveals Next', (tester) async {
    await pumpApp(tester, now: now, seed: (h) => seedPlayable(h, now));
    await openMc(tester);

    await tester.tap(find.byType(MxChoiceOption).first);
    await settle(tester);
    expect(find.text('Next'), findsOneWidget); // nút Next hiện sau khi đáp
    // lựa chọn bị khoá (onPressed null).
    expect(
      tester.widgetList<MxChoiceOption>(find.byType(MxChoiceOption))
          .every((c) => c.onPressed == null),
      isTrue,
    );
  });

  // SC-MC · trả lời hết → "Round complete!"
  testWidgets('answering every question completes the round', (tester) async {
    await pumpApp(tester, now: now, seed: (h) => seedPlayable(h, now));
    await openMc(tester);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byType(MxChoiceOption).first);
      await settle(tester);
      await tester.tap(find.text('Next'));
      await settle(tester);
    }
    expect(find.text('Round complete!'), findsOneWidget);
  });

  // SC-MC · D-013 — chơi KHÔNG đổi srs_state
  testWidgets('playing does not mutate srs_state (D-013)', (tester) async {
    final h = await pumpApp(tester, now: now, seed: (h) => seedPlayable(h, now));
    await openMc(tester);
    await tester.tap(find.byType(MxChoiceOption).first);
    await settle(tester);

    final srs = await h.db.select(h.db.srsStates).get();
    expect(srs.length, 4);
    expect(srs.every((s) => s.box == 1), isTrue);
  });
}
