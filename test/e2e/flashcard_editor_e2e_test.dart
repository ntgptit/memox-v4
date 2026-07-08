// E2E — flashcard-editor (S.12). Tag `e2e`. Map SC-EDITOR-* (docs/scenarios/flashcard-editor.md)
// theo DECISIONS.md. Assert UI (finder) + DB (query, TỪNG TRƯỜNG). Create mode = tab "Add"
// (thẻ vào deck gốc đầu tiên); edit mode = từ deck-detail → card → "Edit card".
@Tags(['e2e'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/features/flashcard-editor/screens/flashcard_editor_screen.dart';
import 'package:memox_v4/presentation/features/flashcard-editor/widgets/dup_banner.dart';
import 'package:memox_v4/presentation/shared/composites/mx_fab.dart';
import 'package:memox_v4/presentation/shared/composites/mx_menu_item.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_chip.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_switch.dart';

import 'support/e2e_harness.dart';

/// Mở editor tạo-mới qua nút "Add words" của deck-detail RỖNG (push → có back-stack
/// để Save/Cancel pop được). Deck "Deck" phải rỗng (chưa có thẻ). Tab "Add" là
/// branch-root nên Save→pop lỗi (nav bug tách task riêng) — dùng push path.
Future<void> openCreate(WidgetTester tester) async {
  await tester.tap(find.text('Library'));
  await settle(tester);
  await tester.tap(find.text('Deck'));
  await settle(tester);
  await tester.tap(find.text('Browse cards'));
  await settle(tester);
  await tester.tap(find.text('Add words')); // empty-state → push(add)
  await settle(tester);
  expect(find.byType(FlashcardEditorScreen), findsOneWidget);
  expect(find.text('New card'), findsWidgets);
}

bool _saveEnabled(WidgetTester tester) =>
    tester.widget<MxButton>(find.widgetWithText(MxButton, 'Save')).onPressed !=
    null;

Finder get _termField => find.byType(TextField).at(0);
Finder get _meaningField => find.byType(TextField).at(1);

void main() {
  // SC-EDITOR · create boots — New title, Save disabled (canSave false)
  testWidgets('create mode boots empty with Save disabled', (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
    });
    await openCreate(tester);
    expect(_saveEnabled(tester), isFalse);
  });

  // SC-EDITOR · validation — Save chỉ bật khi có cả term + meaning
  testWidgets('Save enables only when term AND meaning are filled',
      (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
    });
    await openCreate(tester);

    await tester.enterText(_termField, '고양이');
    await settle(tester);
    expect(_saveEnabled(tester), isFalse); // meaning còn trống

    await tester.enterText(_meaningField, 'cat');
    await settle(tester);
    expect(_saveEnabled(tester), isTrue);
  });

  // SC-EDITOR · tạo thẻ → DB card + card_meanings (TỪNG TRƯỜNG)
  testWidgets('create writes card + primary meaning to DB', (tester) async {
    final h = await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
    });
    await openCreate(tester);

    await tester.enterText(_termField, '고양이');
    await settle(tester);
    await tester.enterText(_meaningField, 'cat');
    await settle(tester);
    await tester.tap(find.widgetWithText(MxButton, 'Save'));
    await settle(tester);

    final card = (await h.db.select(h.db.cards).get()).single;
    expect(card.deckId, 'd1');
    expect(card.term, '고양이');
    expect(card.hidden, isFalse);
    expect(card.grammaticalGender, isNull);
    final meaning = (await h.db.select(h.db.cardMeanings).get()).single;
    expect(meaning.cardId, card.id);
    expect(meaning.language, 'en');
    expect(meaning.content, 'cat');
  });

  // SC-EDITOR · tạo thẻ với gender + hidden — mọi trường ghi đúng
  testWidgets('create with gender + hidden persists both', (tester) async {
    final h = await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
    });
    await openCreate(tester);

    await tester.enterText(_termField, 'der Hund');
    await settle(tester);
    await tester.enterText(_meaningField, 'the dog');
    await settle(tester);
    await tester.tap(find.widgetWithText(MxChip, 'Masc'));
    await settle(tester);
    await tester.tap(find.byType(MxSwitch)); // hide card
    await settle(tester);
    await tester.tap(find.widgetWithText(MxButton, 'Save'));
    await settle(tester);

    final card = (await h.db.select(h.db.cards).get()).single;
    expect(card.term, 'der Hund');
    expect(card.grammaticalGender, 'masc');
    expect(card.hidden, isTrue);
  });

  // SC-EDITOR · soft-duplicate (D-020) — banner cảnh báo, KHÔNG chặn
  testWidgets('duplicate term shows the soft-dup banner (not blocking)',
      (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
      await h.seedCard(id: 'c1', deck: 'd1', term: '고양이', meaning: 'cat');
    });
    // Deck có thẻ ⇒ deck-detail loaded ⇒ vào editor qua FAB → add-menu (push).
    await tester.tap(find.text('Library'));
    await settle(tester);
    await tester.tap(find.text('Deck'));
    await settle(tester);
    await tester.tap(find.text('Browse cards'));
    await settle(tester);
    await tester.tap(find.byType(MxFab)); // "Add word" FAB → add menu
    await settle(tester);
    await tester.tap(find.widgetWithText(MxMenuItem, 'Add word')); // push(add)
    await settle(tester);
    expect(find.byType(FlashcardEditorScreen), findsOneWidget);

    await tester.enterText(_termField, '고양이'); // trùng thẻ đã có
    await settle(tester);
    expect(find.byType(DupBanner), findsOneWidget);
    await tester.enterText(_meaningField, 'kitty');
    await settle(tester);
    expect(_saveEnabled(tester), isTrue); // soft: vẫn lưu được
  });

  // SC-EDITOR · cancel — không ghi DB
  testWidgets('cancel discards without writing to DB', (tester) async {
    final h = await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
    });
    await openCreate(tester);

    await tester.enterText(_termField, '고양이');
    await settle(tester);
    await tester.enterText(_meaningField, 'cat');
    await settle(tester);
    await tester.tap(find.widgetWithText(MxButton, 'Cancel'));
    await settle(tester);

    expect(await h.db.select(h.db.cards).get(), isEmpty);
  });

  // SC-EDITOR · edit mode — mở từ deck-detail, prefilled, sửa → DB cập nhật
  testWidgets('edit mode: opens prefilled, edit persists to DB', (tester) async {
    final h = await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
      await h.seedCard(id: 'c1', deck: 'd1', term: '고양이', meaning: 'cat');
    });
    // Library → Deck → Browse → card → Edit card.
    await tester.tap(find.text('Library'));
    await settle(tester);
    await tester.tap(find.text('Deck'));
    await settle(tester);
    await tester.tap(find.text('Browse cards'));
    await settle(tester);
    await tester.tap(find.text('고양이')); // card actions
    await settle(tester);
    await tester.tap(find.text('Edit card'));
    await settle(tester);

    expect(find.byType(FlashcardEditorScreen), findsOneWidget);
    expect(find.text('Edit card'), findsWidgets); // title
    expect(find.text('고양이'), findsWidgets); // prefilled term

    await tester.enterText(_meaningField, 'kitten'); // đổi nghĩa
    await settle(tester);
    await tester.tap(find.widgetWithText(MxButton, 'Save'));
    await settle(tester);

    // DB: cùng card id, nghĩa đã đổi.
    final card = (await h.db.select(h.db.cards).get()).single;
    expect(card.id, 'c1');
    expect(card.term, '고양이');
    final meanings = await h.db.select(h.db.cardMeanings).get();
    expect(meanings.any((m) => m.content == 'kitten'), isTrue);
    expect(meanings.any((m) => m.content == 'cat'), isFalse);
  });
}
