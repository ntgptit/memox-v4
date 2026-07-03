import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/export/screens/export_screen.dart';
import 'package:memox_v4/presentation/features/export/widgets/format_list.dart';

import '../../../harness/provider_harness.dart';

void main() {
  Future<FakeHarness> pump(WidgetTester tester, {required bool dark}) async {
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
          home: const ExportScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return harness;
  }

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('config: scope, format, separator, toggle ($theme)',
        (tester) async {
      await pump(tester, dark: dark);

      expect(find.text('Export cards'), findsOneWidget);
      expect(find.text('SCOPE'), findsOneWidget);
      expect(find.text('FORMAT'), findsOneWidget);
      expect(find.byType(FormatList), findsOneWidget);
      expect(find.text('Include review state'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);
    });
  }

  testWidgets('exporting the subtree writes a file and shows done',
      (tester) async {
    final harness = await pump(tester, dark: false);

    // Export the whole subtree (root + sub-deck = 3 seeded cards).
    await tester.tap(find.text('Incl. sub-decks'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();

    expect(find.text('Exported 3 cards'), findsOneWidget);
    // CSV format wrote the encoded content to a file.
    expect(harness.files.lastWritten, isNotNull);
    expect(harness.files.lastWritten, contains('사과'));
  });
}
