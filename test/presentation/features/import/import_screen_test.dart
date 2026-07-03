import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/import/screens/import_screen.dart';
import 'package:memox_v4/presentation/features/import/widgets/source_card.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';

import '../../../harness/provider_harness.dart';

void main() {
  Future<void> pump(WidgetTester tester, {required bool dark}) async {
    tester.view.physicalSize = const Size(400, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final harness = FakeHarness();
    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dark ? AppTheme.dark : AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ImportScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('source: sources + disabled continue ($theme)', (tester) async {
      await pump(tester, dark: dark);

      expect(find.text('Import cards'), findsOneWidget);
      expect(find.byType(SourceCard), findsNWidgets(3));
      expect(find.text('CHOOSE SOURCE'), findsOneWidget);
      // Continue is disabled with no pasted text.
      final button = tester.widget<MxButton>(
        find.widgetWithText(MxButton, 'Continue'),
      );
      expect(button.onPressed, isNull);
    });
  }

  testWidgets('full flow: paste → mapping → preview → import → done',
      (tester) async {
    await pump(tester, dark: false);

    // Paste two tab-separated cards (tab is the default separator).
    await tester.enterText(find.byType(TextField), '안녕\tHello\n감사\tThanks');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue')); // source → mapping
    await tester.pumpAndSettle();
    expect(find.text('SEPARATOR'), findsOneWidget);

    await tester.tap(find.text('Continue')); // mapping → preview
    await tester.pumpAndSettle();
    expect(find.text('PREVIEW · 2 CARDS'), findsOneWidget);

    await tester.tap(find.text('Import 2 cards')); // commit
    await tester.pumpAndSettle();
    expect(find.text('Imported 2 cards'), findsOneWidget);
  });
}
