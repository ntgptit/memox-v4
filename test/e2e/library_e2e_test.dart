// E2E — Library (thư viện bộ thẻ). Tag `e2e`. Map SC-LIBRARY-* (docs/scenarios/library.md)
// theo DECISIONS.md. Assert UI (finder) + DB (query, TỪNG TRƯỜNG). Hành vi chưa được kit
// định nghĩa (vd play-sheet due=0 ẩn "Review", D-016) được tách task riêng — KHÔNG skip đỏ,
// KHÔNG lock hành vi lỗi: T.2 chỉ assert phần đã chốt (play-sheet due>0).
@Tags(['e2e'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/features/library/screens/library_screen.dart';
import 'package:memox_v4/presentation/features/library/widgets/library_node_card.dart';
import 'package:memox_v4/presentation/features/library/widgets/overflow_menu_sheet.dart';
import 'package:memox_v4/presentation/features/library/widgets/pair_picker_sheet.dart';
import 'package:memox_v4/presentation/features/library/widgets/play_sheet.dart';
import 'package:memox_v4/presentation/features/search/screens/search_screen.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_menu_item.dart';

import 'support/e2e_harness.dart';

/// Từ Today (màn boot) chuyển sang tab Library qua bottom-nav.
Future<void> openLibrary(WidgetTester tester) async {
  await tester.tap(find.text('Library'));
  await settle(tester);
  expect(find.byType(LibraryScreen), findsOneWidget);
}

void main() {
  // SC-LIBRARY-02 / -70 · empty (chưa có bộ thẻ)
  testWidgets('empty → MxEmptyState, no cards, DB decks empty', (tester) async {
    final h = await pumpApp(tester, seed: (h) => h.seedPair());
    await openLibrary(tester);

    expect(find.byType(MxEmptyState), findsOneWidget);
    expect(find.byType(LibraryNodeCard), findsNothing);
    expect(await h.db.select(h.db.decks).get(), isEmpty);
  });

  // SC-LIBRARY-01 / -25 / -71 · loaded (1 bộ thẻ) — card render + nguồn DB
  testWidgets('loaded → node card shows deck name; DB deck row intact',
      (tester) async {
    final h = await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Korean Basics');
      await h.seedCard(id: 'c1', deck: 'd1', term: '사과', meaning: 'quả táo');
    });
    await openLibrary(tester);

    expect(find.byType(LibraryNodeCard), findsOneWidget);
    expect(find.text('Korean Basics'), findsOneWidget);
    // DB: assert từng trường của deck row.
    final deck = (await h.db.select(h.db.decks).get()).single;
    expect(deck.id, 'd1');
    expect(deck.name, 'Korean Basics');
    expect(deck.parentId, isNull);
    expect(deck.languagePairId, 'lp');
  });

  // SC-LIBRARY-07 / -42..45 · sort A→Z (mặc định) → Z→A đảo thứ tự
  testWidgets('sort: default A→Z then Z–A reorders the list', (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'dz', name: 'Zeta');
      await h.seedDeck(id: 'da', name: 'Alpha');
    });
    await openLibrary(tester);

    // Mặc định alphaAsc: 'Alpha' nằm trên 'Zeta'.
    expect(tester.getTopLeft(find.text('Alpha')).dy,
        lessThan(tester.getTopLeft(find.text('Zeta')).dy));

    // Mở sort-sheet → chọn "Alphabetical Z–A".
    await tester.tap(find.byIcon(Icons.swap_vert));
    await settle(tester);
    await tester.tap(find.text('Alphabetical Z–A'));
    await settle(tester);

    // alphaDesc: 'Zeta' nằm trên 'Alpha'.
    expect(tester.getTopLeft(find.text('Zeta')).dy,
        lessThan(tester.getTopLeft(find.text('Alpha')).dy));
  });

  // SC-LIBRARY-93 · tạo bộ thẻ từ empty → loaded + DB round-trip (từng trường)
  testWidgets('create deck: empty → dialog → loaded; DB row every field',
      (tester) async {
    final h = await pumpApp(tester, seed: (h) => h.seedPair());
    await openLibrary(tester);
    expect(find.byType(MxEmptyState), findsOneWidget);

    await tester.tap(find.text('Create deck')); // empty-state button
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'My New Deck');
    await settle(tester);
    await tester.tap(find.text('Create')); // dialog confirm
    await settle(tester);

    expect(find.byType(MxEmptyState), findsNothing);
    expect(find.text('My New Deck'), findsOneWidget);
    // DB: đúng 1 deck; assert MỌI trường.
    final micros = h.now.microsecondsSinceEpoch;
    final deck = (await h.db.select(h.db.decks).get()).single;
    expect(deck.id, 'deck-$micros');
    expect(deck.name, 'My New Deck');
    expect(deck.parentId, isNull);
    expect(deck.languagePairId, 'lp'); // = cặp active (repo._activePairId)
    expect(deck.createdAt, micros); // = clock đã override
  });

  // SC-LIBRARY-06 / -40 / -91 · pair-picker chọn cặp B → is_active hoán đổi
  testWidgets('pair picker: select other pair flips is_active in DB',
      (tester) async {
    final h = await pumpApp(tester, seed: (h) async {
      await h.seedPair(id: 'lpA', learning: 'ko', native: 'vi', active: true);
      await h.seedPair(id: 'lpB', learning: 'ja', native: 'en', active: false);
    });
    await openLibrary(tester);

    await tester.tap(find.text('ko'), warnIfMissed: false); // pair pill (active A)
    await settle(tester);
    expect(find.byType(PairPickerSheet), findsOneWidget);
    await tester.tap(find.text('ja → en')); // pick B
    await settle(tester);

    // DB: đúng 1 active; assert TỪNG row.
    final pairs = {
      for (final p in await h.db.select(h.db.languagePairs).get()) p.id: p,
    };
    expect(pairs['lpA']!.isActive, isFalse);
    expect(pairs['lpA']!.learningLanguage, 'ko');
    expect(pairs['lpB']!.isActive, isTrue);
    expect(pairs['lpB']!.learningLanguage, 'ja');
  });

  // SC-LIBRARY-74 · bộ thẻ có thẻ ẩn (D-006) — meta "N words · N hidden"
  testWidgets('hidden card: node meta shows hidden count; DB hidden flag',
      (tester) async {
    final h = await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Mixed');
      await h.seedCard(id: 'cv', deck: 'd1', term: '보임', meaning: 'visible');
      await h.seedCard(id: 'ch', deck: 'd1', term: '숨김', meaning: 'hidden', hidden: true);
    });
    await openLibrary(tester);

    // node.words = số thẻ hiển thị (1); hidden = 1 → "1 word · 1 hidden".
    expect(find.text('1 word · 1 hidden'), findsOneWidget);
    // DB: 2 thẻ, đúng 1 ẩn — assert cột hidden từng thẻ.
    final cards = {
      for (final c in await h.db.select(h.db.cards).get()) c.id: c,
    };
    expect(cards['cv']!.hidden, isFalse);
    expect(cards['ch']!.hidden, isTrue);
  });

  // SC-LIBRARY-08 · overflow-menu (3 mục Import / Export / Settings)
  testWidgets('overflow menu opens with Import / Export / Settings',
      (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Korean Basics');
    });
    await openLibrary(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await settle(tester);
    expect(find.byType(OverflowMenuSheet), findsOneWidget);
    expect(find.text('Import cards'), findsOneWidget);
    expect(find.text('Export cards'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  // SC-LIBRARY-09 / -49 · chạm card → play-sheet (biến thể due>0, đã chốt)
  testWidgets('tap deck card opens play-sheet; due>0 shows Review',
      (tester) async {
    final now = DateTime.utc(2026, 7, 3, 9);
    await pumpApp(tester, now: now, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Korean Basics');
      await h.seedCard(id: 'c1', deck: 'd1', term: '사과', meaning: 'quả táo');
      await h.seedSrs(cardId: 'c1', box: 1, dueAt: now.subtract(const Duration(hours: 1)));
    });
    await openLibrary(tester);

    await tester.tap(find.text('Korean Basics'));
    await settle(tester);
    expect(find.byType(PlaySheet), findsOneWidget);
    // due>0 ⇒ Review (icon replay) hiện; các mục còn lại luôn có.
    expect(find.widgetWithIcon(MxMenuItem, Icons.replay), findsOneWidget);
    expect(find.widgetWithIcon(MxMenuItem, Icons.school), findsOneWidget); // Learn
    expect(find.widgetWithIcon(MxMenuItem, Icons.visibility), findsOneWidget); // Browse
    expect(find.widgetWithIcon(MxMenuItem, Icons.play_circle), findsOneWidget); // Player
  });

  // SC-LIBRARY-22 · search-btn → điều hướng sang màn Search (DEC: search là màn riêng)
  testWidgets('search button navigates to the Search screen', (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Korean Basics');
    });
    await openLibrary(tester);

    await tester.tap(find.byIcon(Icons.search));
    await settle(tester);
    expect(find.byType(SearchScreen), findsOneWidget);
  });
}
