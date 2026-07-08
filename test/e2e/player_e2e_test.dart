// E2E — player (S.19, auto-play). Tag `e2e`. Map SC-PLAYER-* (docs/scenarios/player.md).
// KHÔNG ghi DB (D-014). Adapter TTS là no-op ⇒ không tự nhảy thẻ; transport thủ công.
// Vào màn: Library → deck → play-sheet → Player (icon play_circle, push).
@Tags(['e2e'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/features/player/screens/player_screen.dart';
import 'package:memox_v4/presentation/features/player/widgets/player_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_menu_item.dart';

import 'support/e2e_harness.dart';

Future<void> openPlayer(WidgetTester tester, String deckName) async {
  await tester.tap(find.text('Library'));
  await settle(tester);
  await tester.tap(find.text(deckName));
  await settle(tester);
  await tester.tap(find.widgetWithIcon(MxMenuItem, Icons.play_circle)); // Player → push
  await settle(tester);
  expect(find.byType(PlayerScreen), findsOneWidget);
}

void main() {
  final now = DateTime.utc(2026, 7, 3, 9);

  // SC-PLAYER · render — thẻ đầu + transport; playing ⇒ icon pause
  testWidgets('renders the first card with transport, auto-playing',
      (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
      await h.seedCard(id: 'c0', deck: 'd1', term: '고양이', meaning: 'cat');
      await h.seedCard(id: 'c1', deck: 'd1', term: '개', meaning: 'dog');
    });
    await openPlayer(tester, 'Deck');

    expect(find.byType(PlayerCard), findsOneWidget);
    expect(find.text('고양이'), findsWidgets);
    expect(find.byIcon(Icons.skip_next), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsOneWidget); // auto-play ⇒ pause icon
  });

  // SC-PLAYER · play/pause đổi trạng thái transport
  testWidgets('play/pause toggles the transport icon', (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
      await h.seedCard(id: 'c0', deck: 'd1', term: '고양이', meaning: 'cat');
      await h.seedCard(id: 'c1', deck: 'd1', term: '개', meaning: 'dog');
    });
    await openPlayer(tester, 'Deck');

    await tester.tap(find.byIcon(Icons.pause)); // FAB đang pause → tạm dừng
    await settle(tester);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  // SC-PLAYER · next qua hết → "All played" + Replay
  testWidgets('advancing past the last card shows All played', (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
      await h.seedCard(id: 'c0', deck: 'd1', term: '고양이', meaning: 'cat');
    });
    await openPlayer(tester, 'Deck');

    await tester.tap(find.byIcon(Icons.skip_next)); // 1 thẻ → next → hết
    await settle(tester);
    expect(find.text('All played'), findsOneWidget);
    expect(find.text('Replay'), findsOneWidget);
  });

  // SC-PLAYER · D-014 — phát KHÔNG đổi srs_state
  testWidgets('playing does not mutate srs_state (D-014)', (tester) async {
    final h = await pumpApp(tester, now: now, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
      await h.seedCard(id: 'c0', deck: 'd1', term: '고양이', meaning: 'cat');
      await h.seedSrs(cardId: 'c0', box: 5, dueAt: now.add(const Duration(days: 30)));
    });
    await openPlayer(tester, 'Deck');
    await tester.tap(find.byIcon(Icons.skip_next));
    await settle(tester);

    final srs = (await h.db.select(h.db.srsStates).get()).single;
    expect(srs.cardId, 'c0');
    expect(srs.box, 5); // không đổi
  });
}
