// E2E — game-matching (S.14). Tag `e2e`. Map SC-MATCHING-* (docs/scenarios/game-matching.md)
// theo DECISIONS.md. Trò chơi KHÔNG ghi DB (D-013) — assert cơ chế ghép (đúng/sai/hoàn tất)
// + bất biến DB (srs_state không đổi). Cột trái = nghĩa, cột phải = term (xáo trộn); ghép đúng
// khi cùng card. Vào màn: Library → deck → play-sheet → Single game → game-picker → Matching.
@Tags(['e2e'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/features/game-matching/screens/game_matching_screen.dart';
import 'package:memox_v4/presentation/features/game-matching/widgets/tile.dart';
import 'package:memox_v4/presentation/features/game-picker/widgets/game_option.dart';
import 'package:memox_v4/presentation/shared/composites/mx_menu_item.dart';

import 'support/e2e_harness.dart';

/// 4 thẻ đến hạn (đủ để game-picker mở khoá) với term/nghĩa phân biệt.
Future<void> seedMatchable(E2EHarness h, DateTime now) async {
  await h.seedPair();
  await h.seedDeck(id: 'd1', name: 'Deck');
  const cards = [('c0', '고양이', 'cat'), ('c1', '개', 'dog'), ('c2', '물', 'water'), ('c3', '불', 'fire')];
  for (final (id, term, meaning) in cards) {
    await h.seedCard(id: id, deck: 'd1', term: term, meaning: meaning);
    await h.seedSrs(cardId: id, box: 1, dueAt: now.subtract(const Duration(hours: 1)));
  }
}

Future<void> openMatching(WidgetTester tester) async {
  await tester.tap(find.text('Library'));
  await settle(tester);
  await tester.tap(find.text('Deck'));
  await settle(tester);
  await tester.tap(find.widgetWithIcon(MxMenuItem, Icons.sports_esports)); // game-picker
  await settle(tester);
  await tester.tap(find.widgetWithText(GameOption, 'Matching'));
  await settle(tester);
  expect(find.byType(GameMatchingScreen), findsOneWidget);
}

Future<void> matchPair(WidgetTester tester, String meaning, String term) async {
  await tester.tap(find.text(meaning)); // cột trái (nghĩa)
  await settle(tester);
  await tester.tap(find.text(term)); // cột phải (term)
  await settle(tester); // settle advance đồng hồ fake → commit sau flash
}

void main() {
  final now = DateTime.utc(2026, 7, 3, 9);

  // SC-MATCHING · round render — 4 cặp (8 tile) + progress 0/4
  testWidgets('round renders both columns with 0/total progress',
      (tester) async {
    await pumpApp(tester, now: now, seed: (h) => seedMatchable(h, now));
    await openMatching(tester);

    expect(find.byType(MatchTileView), findsNWidgets(8)); // 4 trái + 4 phải
    expect(find.text('0/4'), findsOneWidget);
    expect(find.text('cat'), findsOneWidget); // nghĩa (trái)
    expect(find.text('고양이'), findsOneWidget); // term (phải)
  });

  // SC-MATCHING · ghép đúng hết → "Round complete!"
  testWidgets('matching every pair completes the round', (tester) async {
    await pumpApp(tester, now: now, seed: (h) => seedMatchable(h, now));
    await openMatching(tester);

    await matchPair(tester, 'cat', '고양이');
    await matchPair(tester, 'dog', '개');
    await matchPair(tester, 'water', '물');
    await matchPair(tester, 'fire', '불');

    expect(find.text('Round complete!'), findsOneWidget);
    expect(find.text('4/4'), findsOneWidget);
  });

  // SC-MATCHING · ghép sai → không tính, chưa hoàn tất
  testWidgets('a wrong pair does not advance progress', (tester) async {
    await pumpApp(tester, now: now, seed: (h) => seedMatchable(h, now));
    await openMatching(tester);

    await matchPair(tester, 'cat', '개'); // 'cat' ↔ 'dog' term: sai
    expect(find.text('Round complete!'), findsNothing);
    expect(find.text('0/4'), findsOneWidget); // vẫn 0 cặp
  });

  // SC-MATCHING · D-013 — chơi game KHÔNG đổi srs_state
  testWidgets('playing a match does not mutate srs_state (D-013)',
      (tester) async {
    final h = await pumpApp(tester, now: now, seed: (h) => seedMatchable(h, now));
    await openMatching(tester);
    await matchPair(tester, 'cat', '고양이'); // 1 cặp đúng

    // DB: 4 dòng srs, tất cả vẫn box 1, dueAt nguyên vẹn (game read-only).
    final srs = await h.db.select(h.db.srsStates).get();
    expect(srs.length, 4);
    expect(srs.every((s) => s.box == 1), isTrue);
    expect(srs.every((s) => s.dueAt == now.subtract(const Duration(hours: 1)).microsecondsSinceEpoch), isTrue);
  });
}
