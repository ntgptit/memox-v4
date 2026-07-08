// E2E — deck-detail (S.03). Tag `e2e`. Map SC-DECKDETAIL-* (docs/scenarios/deck-detail.md)
// theo DECISIONS.md. Assert UI (finder) + DB (query, TỪNG TRƯỜNG). Điều hướng vào màn qua
// hành vi người dùng thật: Library → chạm card → play-sheet → "Browse cards".
@Tags(['e2e'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/features/deck-detail/screens/deck_detail_screen.dart';
import 'package:memox_v4/presentation/features/deck-detail/widgets/flashcard_row.dart';
import 'package:memox_v4/presentation/features/deck-detail/widgets/sub_deck_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_chip.dart';

import 'support/e2e_harness.dart';

/// Mở deck-detail của [deckName] theo đường người dùng: Library → card → Browse.
Future<void> openDeckDetail(WidgetTester tester, String deckName) async {
  await tester.tap(find.text('Library'));
  await settle(tester);
  await tester.tap(find.text(deckName));
  await settle(tester);
  await tester.tap(find.text('Browse cards')); // play-sheet → deck-detail
  await settle(tester);
  expect(find.byType(DeckDetailScreen), findsOneWidget);
}

void main() {
  // SC-DECKDETAIL · loaded — header tên deck + card rows + section "Cards"
  testWidgets('loaded → deck name header, card rows, Cards section',
      (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Korean Basics');
      await h.seedCard(id: 'c1', deck: 'd1', term: '사과', meaning: 'apple');
      await h.seedCard(id: 'c2', deck: 'd1', term: '학교', meaning: 'school');
    });
    await openDeckDetail(tester, 'Korean Basics');

    expect(find.text('Korean Basics'), findsWidgets); // header title
    expect(find.byType(FlashcardRow), findsNWidgets(2));
    expect(find.text('CARDS'), findsOneWidget); // section label (uppercased)
  });

  // SC-DECKDETAIL · empty — deck không thẻ/không sub-deck
  testWidgets('empty deck → MxEmptyState "Empty deck"', (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Hollow');
    });
    await openDeckDetail(tester, 'Hollow');

    expect(find.byType(MxEmptyState), findsOneWidget);
    expect(find.text('Empty deck'), findsOneWidget);
    expect(find.byType(FlashcardRow), findsNothing);
  });

  // SC-DECKDETAIL · sub-decks + cards — hai section + đi vào sub-deck
  testWidgets('parent shows sub-deck + card sections; tap sub-deck descends',
      (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'p', name: 'Parent');
      await h.seedDeck(id: 'ch', name: 'Child', parent: 'p');
      await h.seedCard(id: 'c1', deck: 'p', term: '부모', meaning: 'parent-card');
    });
    await openDeckDetail(tester, 'Parent');

    expect(find.byType(SubDeckCard), findsOneWidget);
    expect(find.byType(FlashcardRow), findsOneWidget);
    expect(find.text('SUB-DECKS'), findsOneWidget); // uppercased section labels
    expect(find.text('CARDS'), findsOneWidget);

    await tester.tap(find.text('Child'));
    await settle(tester);
    // Đã push deck-detail của Child (title Child, không còn section Sub-decks).
    expect(find.text('Child'), findsWidgets);
    expect(find.byType(SubDeckCard), findsNothing);
  });

  // SC-DECKDETAIL · search lọc thẻ theo term/nghĩa
  testWidgets('search filters cards by term', (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Fruit');
      await h.seedCard(id: 'c1', deck: 'd1', term: 'apple', meaning: 'táo');
      await h.seedCard(id: 'c2', deck: 'd1', term: 'banana', meaning: 'chuối');
    });
    await openDeckDetail(tester, 'Fruit');

    await tester.enterText(find.byType(TextField), 'app');
    await settle(tester);
    expect(find.text('apple'), findsOneWidget);
    expect(find.text('banana'), findsNothing);
  });

  // SC-DECKDETAIL · search 0 kết quả → no-results state
  testWidgets('search with no match → "No cards found"', (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Fruit');
      await h.seedCard(id: 'c1', deck: 'd1', term: 'apple', meaning: 'táo');
    });
    await openDeckDetail(tester, 'Fruit');

    await tester.enterText(find.byType(TextField), 'zzz');
    await settle(tester);
    expect(find.text('No cards found'), findsOneWidget);
    expect(find.byType(FlashcardRow), findsNothing);
  });

  // SC-DECKDETAIL · chip lọc "Due" (chỉ hiện khi searching) → chỉ thẻ đến hạn
  testWidgets('filter chip "Due" keeps only due cards', (tester) async {
    final now = DateTime.utc(2026, 7, 3, 9);
    await pumpApp(tester, now: now, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Mix');
      await h.seedCard(id: 'cn', deck: 'd1', term: 'apple', meaning: 'new one');
      await h.seedCard(id: 'cd', deck: 'd1', term: 'apricot', meaning: 'due one');
      await h.seedSrs(cardId: 'cd', box: 1, dueAt: now.subtract(const Duration(hours: 1)));
    });
    await openDeckDetail(tester, 'Mix');

    await tester.enterText(find.byType(TextField), 'ap'); // matches both
    await settle(tester);
    expect(find.text('apple'), findsOneWidget);
    expect(find.text('apricot'), findsOneWidget);

    // "Due" cũng là nhãn badge trạng thái thẻ → chỉ định đúng CHIP.
    await tester.tap(find.widgetWithText(MxChip, 'Due'));
    await settle(tester);
    expect(find.text('apricot'), findsOneWidget); // due kept
    expect(find.text('apple'), findsNothing); // new dropped
  });

  // SC-DECKDETAIL · card-actions → Hide → DB hidden=true
  testWidgets('card actions: Hide sets hidden flag in DB', (tester) async {
    final h = await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
      await h.seedCard(id: 'c1', deck: 'd1', term: 'apple', meaning: 'táo');
    });
    await openDeckDetail(tester, 'Deck');

    await tester.tap(find.text('apple')); // open card actions
    await settle(tester);
    await tester.tap(find.text('Hide card'));
    await settle(tester);

    final card = (await h.db.select(h.db.cards).get()).single;
    expect(card.id, 'c1');
    expect(card.hidden, isTrue);
  });

  // SC-DECKDETAIL · card-actions → Delete → confirm → DB xoá thẻ
  testWidgets('card actions: Delete removes the card from DB', (tester) async {
    final h = await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
      await h.seedCard(id: 'c1', deck: 'd1', term: 'apple', meaning: 'táo');
      await h.seedCard(id: 'c2', deck: 'd1', term: 'banana', meaning: 'chuối');
    });
    await openDeckDetail(tester, 'Deck');

    await tester.tap(find.text('apple'));
    await settle(tester);
    await tester.tap(find.text('Delete card'));
    await settle(tester);
    await tester.tap(find.text('Delete')); // confirm dialog
    await settle(tester);

    final ids = (await h.db.select(h.db.cards).get()).map((c) => c.id).toList();
    expect(ids, ['c2']); // c1 gone, c2 kept
  });

  // SC-DECKDETAIL · Add → New sub-deck → DB deck con (parentId = deck hiện tại)
  testWidgets('add menu: create sub-deck writes child deck to DB',
      (tester) async {
    final h = await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'p', name: 'Parent');
      await h.seedCard(id: 'c1', deck: 'p', term: 'apple', meaning: 'táo');
    });
    await openDeckDetail(tester, 'Parent');

    await tester.tap(find.text('Add word')); // FAB → add menu
    await settle(tester);
    await tester.tap(find.text('New sub-deck'));
    await settle(tester);
    // Deck-detail có sẵn search-dock (1 TextField); nhắm ĐÚNG field của dialog.
    await tester.enterText(
      find.descendant(of: find.byType(Dialog), matching: find.byType(TextField)),
      'Verbs',
    );
    await settle(tester);
    await tester.tap(find.text('Create'));
    await settle(tester);

    final child = (await h.db.select(h.db.decks).get())
        .firstWhere((d) => d.name == 'Verbs');
    expect(child.parentId, 'p');
    expect(child.languagePairId, 'lp');
    expect(child.id, startsWith('deck-'));
  });

  // SC-DECKDETAIL · deck-menu → Delete deck → confirm → DB xoá deck (cascade)
  // Xoá 1 SUB-deck (vào bằng push → có back-stack để pop về deck cha). Xoá deck
  // gốc (vào bằng go) hiện lỗi pop — tách task nav riêng (push not go).
  testWidgets('deck menu: Delete sub-deck removes it (cascade) + pops to parent',
      (tester) async {
    final h = await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'p', name: 'Keeper');
      await h.seedDeck(id: 'ch', name: 'Doomed', parent: 'p');
      await h.seedCard(id: 'c1', deck: 'ch', term: 'apple', meaning: 'táo');
    });
    await openDeckDetail(tester, 'Keeper');
    await tester.tap(find.text('Doomed')); // push vào sub-deck
    await settle(tester);
    expect(find.byType(DeckDetailScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert)); // deck menu
    await settle(tester);
    await tester.tap(find.text('Delete deck'));
    await settle(tester);
    await tester.tap(find.text('Delete')); // confirm
    await settle(tester);

    // DB: sub-deck + thẻ của nó bị xoá cascade; deck cha còn lại.
    final decks = (await h.db.select(h.db.decks).get()).map((d) => d.id).toList();
    expect(decks, ['p']);
    expect(await h.db.select(h.db.cards).get(), isEmpty);
    // UI: pop về deck cha (vẫn ở deck-detail).
    expect(find.byType(DeckDetailScreen), findsOneWidget);
    expect(find.text('Keeper'), findsWidgets);
  });

  // SC-DECKDETAIL · deck-menu → Reset progress → DB srs về box 0, dueAt null
  testWidgets('deck menu: Reset progress resets srs to New', (tester) async {
    final now = DateTime.utc(2026, 7, 3, 9);
    final h = await pumpApp(tester, now: now, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Studied');
      await h.seedCard(id: 'c1', deck: 'd1', term: 'apple', meaning: 'táo');
      await h.seedSrs(cardId: 'c1', box: 3, dueAt: now.add(const Duration(days: 7)));
    });
    await openDeckDetail(tester, 'Studied');

    await tester.tap(find.byIcon(Icons.more_vert));
    await settle(tester);
    await tester.tap(find.text('Reset progress'));
    await settle(tester);
    await tester.tap(find.text('Reset')); // confirm
    await settle(tester);

    final srs = (await h.db.select(h.db.srsStates).get()).single;
    expect(srs.cardId, 'c1');
    expect(srs.box, 0);
    expect(srs.dueAt, isNull);
  });
}
