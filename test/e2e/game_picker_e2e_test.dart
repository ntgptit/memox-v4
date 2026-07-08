// E2E — game-picker (S.13). Tag `e2e`. Map SC-GAMEPICKER-* (docs/scenarios/game-picker.md)
// theo DECISIONS.md. Màn read-only (source in-memory) → assert UI suy ra từ ĐẾM trong DB
// (canPlay = wordCount ≥ gameMinWords=4) + điều hướng. Vào màn: Library → deck → play-sheet
// → "Single game" (icon sports_esports, push).
@Tags(['e2e'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/features/game-matching/screens/game_matching_screen.dart';
import 'package:memox_v4/presentation/features/game-picker/screens/game_picker_screen.dart';
import 'package:memox_v4/presentation/features/game-picker/widgets/game_option.dart';
import 'package:memox_v4/presentation/features/game-picker/widgets/scope_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_action_callout.dart';
import 'package:memox_v4/presentation/shared/composites/mx_menu_item.dart';

import 'support/e2e_harness.dart';

/// Library → deck → play-sheet → "Single game" (push game-picker).
Future<void> openGamePicker(WidgetTester tester, String deckName) async {
  await tester.tap(find.text('Library'));
  await settle(tester);
  await tester.tap(find.text(deckName)); // play-sheet
  await settle(tester);
  await tester.tap(find.widgetWithIcon(MxMenuItem, Icons.sports_esports));
  await settle(tester);
  expect(find.byType(GamePickerScreen), findsOneWidget);
}

bool _matchingEnabled(WidgetTester tester) =>
    tester.widget<GameOption>(find.widgetWithText(GameOption, 'Matching'))
        .onPressed !=
    null;

/// Seed a deck of [n] brand-new cards (no srs ⇒ due=0, visible=n).
Future<void> seedNewDeck(E2EHarness h, {required int n, String deck = 'd1'}) async {
  await h.seedPair();
  await h.seedDeck(id: deck, name: 'Deck');
  for (var i = 0; i < n; i++) {
    await h.seedCard(id: '$deck-c$i', deck: deck, term: 'term$i', meaning: 'm$i');
  }
}

void main() {
  // SC-GAMEPICKER · nguồn "By schedule" mặc định, due=0 < 4 ⇒ banner + game khoá
  testWidgets('not enough due words → callout shown, games disabled',
      (tester) async {
    await pumpApp(tester, seed: (h) => seedNewDeck(h, n: 5)); // 5 new, 0 due
    await openGamePicker(tester, 'Deck');

    expect(find.byType(MxActionCallout), findsOneWidget);
    expect(find.text('This set needs at least 4 words to play.'), findsOneWidget);
    expect(_matchingEnabled(tester), isFalse);
  });

  // SC-GAMEPICKER · đủ thẻ đến hạn (schedule ≥ 4) ⇒ không banner, game bật + điều hướng
  testWidgets('enough due words → no callout, game navigates to Matching',
      (tester) async {
    final now = DateTime.utc(2026, 7, 3, 9);
    await pumpApp(tester, now: now, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
      for (var i = 0; i < 4; i++) {
        await h.seedCard(id: 'c$i', deck: 'd1', term: 't$i', meaning: 'm$i');
        await h.seedSrs(cardId: 'c$i', box: 1, dueAt: now.subtract(const Duration(hours: 1)));
      }
    });
    await openGamePicker(tester, 'Deck');

    expect(find.byType(MxActionCallout), findsNothing);
    expect(_matchingEnabled(tester), isTrue);

    await tester.tap(find.widgetWithText(GameOption, 'Matching'));
    await settle(tester);
    expect(find.byType(GameMatchingScreen), findsOneWidget);
  });

  // SC-GAMEPICKER · đổi nguồn qua ScopeSheet: schedule(0)→All(5) ⇒ banner biến mất
  testWidgets('scope sheet: switching source to All enables games',
      (tester) async {
    await pumpApp(tester, seed: (h) => seedNewDeck(h, n: 5)); // due=0, all=5
    await openGamePicker(tester, 'Deck');
    expect(find.byType(MxActionCallout), findsOneWidget); // schedule: 0 due

    await tester.tap(find.byType(ScopeCard));
    await settle(tester);
    await tester.tap(find.text('All cards')); // GameSource.all
    await settle(tester);

    // all = 5 ≥ 4 ⇒ đủ chơi.
    expect(find.byType(MxActionCallout), findsNothing);
    expect(_matchingEnabled(tester), isTrue);
  });
}
