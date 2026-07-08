// E2E — export (S.11). Tag `e2e`. Map SC-EXPORT-* (docs/scenarios/export.md).
// Config in-memory; run() đọc thẻ của deck gốc đầu tiên → done (exportedCount). Read-only
// (không ghi DB). Điều hướng: push '/export'.
@Tags(['e2e'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox_v4/presentation/features/export/screens/export_screen.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';

import 'support/e2e_harness.dart';

Future<void> openExport(WidgetTester tester) async {
  GoRouter.of(tester.element(find.byType(DashboardScreen))).push('/export');
  await settle(tester);
  expect(find.byType(ExportScreen), findsOneWidget);
}

Future<void> seedDeck(E2EHarness h, {required int cards}) async {
  await h.seedPair();
  await h.seedDeck(id: 'd1', name: 'Deck');
  for (var i = 0; i < cards; i++) {
    await h.seedCard(id: 'c$i', deck: 'd1', term: 't$i', meaning: 'm$i');
  }
}

void main() {
  // SC-EXPORT · render config — Scope / Format / Include-review-state + Export
  testWidgets('renders the config controls', (tester) async {
    await pumpApp(tester, seed: (h) => seedDeck(h, cards: 2));
    await openExport(tester);

    expect(find.text('SCOPE'), findsOneWidget); // MxSectionLabel uppercased
    expect(find.text('FORMAT'), findsOneWidget);
    expect(find.text('Include review state'), findsOneWidget);
    expect(find.widgetWithText(MxButton, 'Export'), findsOneWidget);
  });

  // SC-EXPORT · run → done; exportedCount = số thẻ deck gốc (D-026)
  testWidgets('running the export completes with the deck card count',
      (tester) async {
    await pumpApp(tester, seed: (h) => seedDeck(h, cards: 3));
    await openExport(tester);

    // Định dạng mặc định CSV ghi file (không drive được trong test) → chọn "Copy
    // text" (ghi clipboard, flutter_test hỗ trợ) để chạy tới trạng thái done.
    await tester.tap(find.text('Copy text'));
    await settle(tester);
    await tester.ensureVisible(find.widgetWithText(MxButton, 'Export'));
    await settle(tester);
    await tester.tap(find.widgetWithText(MxButton, 'Export'));
    await settle(tester);

    expect(find.text('Exported 3 cards'), findsOneWidget);
  });
}
