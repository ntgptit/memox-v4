// E2E — review browse (S.18). Tag `e2e`. Map SC-REVIEW-* (docs/scenarios/review.md).
// Browse = lật mọi thẻ (không đổi SrsState, D-007) NHƯNG sửa nghĩa inline thì GHI DB
// (card_meanings). Vào màn: Library → deck → play-sheet → Review (icon replay, push).
@Tags(['e2e'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/features/review/screens/review_screen.dart';
import 'package:memox_v4/presentation/features/review/widgets/meaning_card.dart';
import 'package:memox_v4/presentation/features/review/widgets/term_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_menu_item.dart';

import 'support/e2e_harness.dart';

Future<void> openReview(WidgetTester tester, String deckName) async {
  await tester.tap(find.text('Library'));
  await settle(tester);
  await tester.tap(find.text(deckName));
  await settle(tester);
  await tester.tap(find.widgetWithIcon(MxMenuItem, Icons.replay)); // Review → push
  await settle(tester);
  expect(find.byType(ReviewScreen), findsOneWidget);
}

void main() {
  final now = DateTime.utc(2026, 7, 3, 9);

  // SC-REVIEW · render — thẻ đầu (meaning + term) + progress 1/N
  testWidgets('renders the first card meaning + term with 1/total', (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
      await h.seedCard(id: 'c0', deck: 'd1', term: '고양이', meaning: 'cat');
      await h.seedCard(id: 'c1', deck: 'd1', term: '개', meaning: 'dog');
    });
    await openReview(tester, 'Deck');

    expect(find.byType(MeaningCard), findsOneWidget);
    expect(find.byType(TermCard), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget); // position 1-based
  });

  // SC-REVIEW · next qua hết thẻ → "All reviewed"
  testWidgets('advancing past the last card shows All reviewed', (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
      await h.seedCard(id: 'c0', deck: 'd1', term: '고양이', meaning: 'cat');
      await h.seedCard(id: 'c1', deck: 'd1', term: '개', meaning: 'dog');
    });
    await openReview(tester, 'Deck');

    await tester.tap(find.byIcon(Icons.chevron_right));
    await settle(tester);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await settle(tester);
    expect(find.text('All reviewed'), findsOneWidget);
  });

  // SC-REVIEW · sửa nghĩa inline → GHI card_meanings
  testWidgets('inline meaning edit persists to card_meanings', (tester) async {
    final h = await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
      await h.seedCard(id: 'c0', deck: 'd1', term: '고양이', meaning: 'cat');
    });
    await openReview(tester, 'Deck');

    await tester.tap(find.byIcon(Icons.edit)); // vào chế độ sửa
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'kitten');
    await settle(tester);
    await tester.tap(find.text('Save'));
    await settle(tester);

    final meaning = (await h.db.select(h.db.cardMeanings).get()).single;
    expect(meaning.cardId, 'c0');
    expect(meaning.content, 'kitten');
  });

  // SC-REVIEW · D-007 — browse KHÔNG đổi srs_state
  testWidgets('browsing does not mutate srs_state (D-007)', (tester) async {
    final h = await pumpApp(tester, now: now, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
      await h.seedCard(id: 'c0', deck: 'd1', term: '고양이', meaning: 'cat');
      await h.seedSrs(cardId: 'c0', box: 3, dueAt: now.add(const Duration(days: 7)));
    });
    await openReview(tester, 'Deck');
    await tester.tap(find.byIcon(Icons.chevron_right)); // browse
    await settle(tester);

    final srs = (await h.db.select(h.db.srsStates).get()).single;
    expect(srs.cardId, 'c0');
    expect(srs.box, 3); // không đổi
    expect(srs.dueAt, now.add(const Duration(days: 7)).microsecondsSinceEpoch);
  });
}
