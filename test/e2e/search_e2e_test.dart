// E2E — search (S.04, global card search). Tag `e2e`. Map SC-SEARCH-* (docs/scenarios/search.md).
// DB-driven (D-019: khớp term HOẶC nghĩa, chuỗi con). Assert UI + tập kết quả suy từ DB. Vào màn:
// Library → nút search (push Routes.search).
@Tags(['e2e'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/features/flashcard-editor/screens/flashcard_editor_screen.dart';
import 'package:memox_v4/presentation/features/search/screens/search_screen.dart';
import 'package:memox_v4/presentation/features/search/widgets/result_row.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_chip.dart';

import 'support/e2e_harness.dart';

Future<void> openSearch(WidgetTester tester) async {
  await tester.tap(find.text('Library'));
  await settle(tester);
  await tester.tap(find.byIcon(Icons.search)); // context-bar search → push
  await settle(tester);
  expect(find.byType(SearchScreen), findsOneWidget);
}

void main() {
  final now = DateTime.utc(2026, 7, 3, 9);

  // SC-SEARCH · truy vấn rỗng, chưa có recent ⇒ gợi ý "Search your cards"
  testWidgets('empty query shows the search hint', (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
    });
    await openSearch(tester);
    expect(find.text('Search your cards'), findsOneWidget);
  });

  // SC-SEARCH · khớp nghĩa (chuỗi con) → hiện thẻ khớp, ẩn thẻ không khớp (D-019)
  testWidgets('query matches by meaning substring', (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
      await h.seedCard(id: 'c0', deck: 'd1', term: '고양이', meaning: 'cat');
      await h.seedCard(id: 'c1', deck: 'd1', term: '개', meaning: 'dog');
    });
    await openSearch(tester);

    await tester.enterText(find.byType(TextField), 'cat');
    await settle(tester);
    expect(find.byType(ResultRow), findsOneWidget);
    expect(find.text('고양이'), findsOneWidget); // thẻ khớp
    expect(find.text('개'), findsNothing); // thẻ không khớp
  });

  // SC-SEARCH · truy vấn hợp lệ khớp 0 thẻ ⇒ "No matches"
  testWidgets('a valid query with no match shows No matches', (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
      await h.seedCard(id: 'c0', deck: 'd1', term: '고양이', meaning: 'cat');
    });
    await openSearch(tester);

    await tester.enterText(find.byType(TextField), 'zzzzz');
    await settle(tester);
    expect(find.text('No matches'), findsOneWidget);
    expect(find.byType(ResultRow), findsNothing);
  });

  // SC-SEARCH · chip lọc "Due" chỉ giữ thẻ đến hạn (D-028)
  testWidgets('filter chip "Due" keeps only due results', (tester) async {
    await pumpApp(tester, now: now, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
      await h.seedCard(id: 'c0', deck: 'd1', term: 'alpha', meaning: 'apple'); // new
      await h.seedCard(id: 'c1', deck: 'd1', term: 'beta', meaning: 'april'); // due
      await h.seedSrs(cardId: 'c1', box: 1, dueAt: now.subtract(const Duration(hours: 1)));
    });
    await openSearch(tester);

    await tester.enterText(find.byType(TextField), 'ap'); // khớp cả apple/april
    await settle(tester);
    expect(find.text('alpha'), findsOneWidget);
    expect(find.text('beta'), findsOneWidget);

    await tester.tap(find.widgetWithText(MxChip, 'Due'));
    await settle(tester);
    expect(find.text('beta'), findsOneWidget); // due giữ
    expect(find.text('alpha'), findsNothing); // new bị lọc
  });

  // SC-SEARCH · chạm kết quả → mở editor (edit) đúng thẻ
  testWidgets('tapping a result opens the card editor', (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
      await h.seedCard(id: 'c0', deck: 'd1', term: '고양이', meaning: 'cat');
    });
    await openSearch(tester);

    await tester.enterText(find.byType(TextField), 'cat');
    await settle(tester);
    await tester.tap(find.text('고양이'));
    await settle(tester);
    expect(find.byType(FlashcardEditorScreen), findsOneWidget);
  });
}
