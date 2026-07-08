// E2E — import (S.10). Tag `e2e`. Map SC-IMPORT-* (docs/scenarios/import.md).
// Wizard source→mapping→preview→done; commit() GHI cards vào deck gốc đầu tiên (D-025).
// Separator mặc định = TAB. Điều hướng: push '/import'.
@Tags(['e2e'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox_v4/presentation/features/import/screens/import_screen.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';

import 'support/e2e_harness.dart';

Future<void> openImport(WidgetTester tester) async {
  GoRouter.of(tester.element(find.byType(DashboardScreen))).push('/import');
  await settle(tester);
  expect(find.byType(ImportScreen), findsOneWidget);
}

void main() {
  // SC-IMPORT · source — Continue vô hiệu khi chưa dán, bật khi có input
  testWidgets('Continue is disabled until text is pasted', (tester) async {
    await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
    });
    await openImport(tester);

    MxButton cont() =>
        tester.widget<MxButton>(find.widgetWithText(MxButton, 'Continue'));
    expect(cont().onPressed, isNull); // input rỗng

    await tester.enterText(find.byType(TextField), '고양이\tcat');
    await settle(tester);
    expect(cont().onPressed, isNotNull);
  });

  // SC-IMPORT · full wizard: dán TSV → Continue → Continue → Import → done + GHI DB
  testWidgets('paste TSV then import writes cards to the first deck',
      (tester) async {
    final h = await pumpApp(tester, seed: (h) async {
      await h.seedPair();
      await h.seedDeck(id: 'd1', name: 'Deck');
    });
    await openImport(tester);

    await tester.enterText(find.byType(TextField), '고양이\tcat\n개\tdog');
    await settle(tester);
    await tester.tap(find.text('Continue')); // source → mapping
    await settle(tester);
    await tester.tap(find.text('Continue')); // mapping → preview
    await settle(tester);
    await tester.tap(find.text('Import 2 cards')); // commit
    await settle(tester);

    expect(find.text('Imported 2 cards'), findsOneWidget);
    // DB: 2 thẻ mới trong deck gốc + nghĩa của chúng.
    final cards = await h.db.select(h.db.cards).get();
    expect(cards.length, 2);
    expect(cards.every((c) => c.deckId == 'd1'), isTrue);
    expect(cards.map((c) => c.term).toSet(), {'고양이', '개'});
    final meanings =
        (await h.db.select(h.db.cardMeanings).get()).map((m) => m.content).toSet();
    expect(meanings, containsAll(<String>['cat', 'dog']));
  });
}
