// E2E — game-typing (S.17). Tag `e2e`. Map SC-TYPING-* (docs/scenarios/game-typing.md).
// Trò chơi KHÔNG ghi DB (D-013) — assert cơ chế (gõ đúng → correct/Next; gõ sai → wrong +
// Correct/Retry) + bất biến srs_state. Prompt = nghĩa, người chơi gõ term. Vào màn: Library →
// deck → play-sheet → Single game → game-picker → Typing.
@Tags(['e2e'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/features/game-typing/screens/game_typing_screen.dart';
import 'package:memox_v4/presentation/features/game-picker/widgets/game_option.dart';
import 'package:memox_v4/presentation/shared/composites/mx_menu_item.dart';

import 'support/e2e_harness.dart';

/// 4 cặp (nghĩa → term) để dò nghĩa đang hiển thị rồi gõ đúng term.
const _pairs = {'cat': '고양이', 'dog': '개', 'water': '물', 'fire': '불'};

Future<void> seedPlayable(E2EHarness h, DateTime now) async {
  await h.seedPair();
  await h.seedDeck(id: 'd1', name: 'Deck');
  var i = 0;
  for (final entry in _pairs.entries) {
    await h.seedCard(id: 'c$i', deck: 'd1', term: entry.value, meaning: entry.key);
    await h.seedSrs(cardId: 'c$i', box: 1, dueAt: now.subtract(const Duration(hours: 1)));
    i++;
  }
}

Future<void> openTyping(WidgetTester tester) async {
  await tester.tap(find.text('Library'));
  await settle(tester);
  await tester.tap(find.text('Deck'));
  await settle(tester);
  await tester.tap(find.widgetWithIcon(MxMenuItem, Icons.sports_esports));
  await settle(tester);
  await tester.tap(find.widgetWithText(GameOption, 'Typing'));
  await settle(tester);
  expect(find.byType(GameTypingScreen), findsOneWidget);
}

/// The term whose meaning is currently prompted on screen.
String _currentTerm(WidgetTester tester) {
  for (final entry in _pairs.entries) {
    if (find.text(entry.key).evaluate().isNotEmpty) return entry.value;
  }
  fail('no known meaning is on screen');
}

void main() {
  final now = DateTime.utc(2026, 7, 3, 9);

  // SC-TYPING · render — nhãn MEANING + nút Check + progress 0/4
  testWidgets('round renders the meaning prompt with 0/total progress',
      (tester) async {
    await pumpApp(tester, now: now, seed: (h) => seedPlayable(h, now));
    await openTyping(tester);

    expect(find.text('MEANING'), findsOneWidget);
    expect(find.text('Check'), findsOneWidget);
    expect(find.text('0/4'), findsOneWidget);
  });

  // SC-TYPING · gõ đúng → correct + nút Next
  testWidgets('typing the correct term grades correct and reveals Next',
      (tester) async {
    await pumpApp(tester, now: now, seed: (h) => seedPlayable(h, now));
    await openTyping(tester);

    await tester.enterText(find.byType(TextField), _currentTerm(tester));
    await settle(tester);
    await tester.tap(find.text('Check'));
    await settle(tester);
    expect(find.text('Next'), findsOneWidget); // đáp đúng → Next
  });

  // SC-TYPING · gõ sai → wrong + Correct/Retry
  testWidgets('a wrong answer offers Correct / Retry', (tester) async {
    await pumpApp(tester, now: now, seed: (h) => seedPlayable(h, now));
    await openTyping(tester);

    await tester.enterText(find.byType(TextField), 'zzzz'); // sai
    await settle(tester);
    await tester.tap(find.text('Check'));
    await settle(tester);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Correct'), findsOneWidget); // tự nhận đúng
  });

  // SC-TYPING · gõ đúng hết → "Round complete!"
  testWidgets('typing every term correctly completes the round', (tester) async {
    await pumpApp(tester, now: now, seed: (h) => seedPlayable(h, now));
    await openTyping(tester);

    for (var i = 0; i < 4; i++) {
      await tester.enterText(find.byType(TextField), _currentTerm(tester));
      await settle(tester);
      await tester.tap(find.text('Check'));
      await settle(tester);
      await tester.tap(find.text('Next'));
      await settle(tester);
    }
    expect(find.text('Round complete!'), findsOneWidget);
  });

  // SC-TYPING · D-013 — chơi KHÔNG đổi srs_state
  testWidgets('playing does not mutate srs_state (D-013)', (tester) async {
    final h = await pumpApp(tester, now: now, seed: (h) => seedPlayable(h, now));
    await openTyping(tester);
    await tester.enterText(find.byType(TextField), _currentTerm(tester));
    await settle(tester);
    await tester.tap(find.text('Check'));
    await settle(tester);

    final srs = await h.db.select(h.db.srsStates).get();
    expect(srs.length, 4);
    expect(srs.every((s) => s.box == 1), isTrue);
  });
}
