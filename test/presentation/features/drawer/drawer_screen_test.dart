import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/drawer/screens/drawer_screen.dart';
import 'package:memox_v4/presentation/features/drawer/widgets/drawer_item.dart';
import 'package:memox_v4/presentation/features/drawer/widgets/lang_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';

import '../../../harness/provider_harness.dart';

void main() {
  Future<void> pump(WidgetTester tester, {required bool dark}) async {
    tester.view.physicalSize = const Size(400, 1600);
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
          home: const DrawerScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('menu: nav items + activity header ($theme)', (tester) async {
      await pump(tester, dark: dark);

      expect(find.text('Menu'), findsOneWidget);
      expect(find.byType(DrawerItem), findsNWidgets(8));
      expect(find.text('Add language'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('00:00'), findsOneWidget); // no activity seeded
    });
  }

  testWidgets('add-language: pick both sides, then add → the pair appears',
      (tester) async {
    await pump(tester, dark: false);

    await tester.tap(find.text('Add language'));
    await tester.pumpAndSettle();

    expect(find.text('LEARNING'), findsOneWidget);
    expect(find.text('NATIVE'), findsOneWidget);

    // Pick the learning language.
    await tester.tap(find.byType(LangCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MxListRow, '한국어'));
    await tester.pumpAndSettle();

    // Pick the native language.
    await tester.tap(find.byType(LangCard).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MxListRow, 'English').first);
    await tester.pumpAndSettle();

    // Confirm — lands on remove-language with the new pair.
    await tester.tap(find.text('Add language pair'));
    await tester.pumpAndSettle();

    expect(find.text('한국어 → English'), findsOneWidget);
  });

  testWidgets('remove-language: empty when no pairs exist', (tester) async {
    await pump(tester, dark: false);

    await tester.tap(find.text('Remove language'));
    await tester.pumpAndSettle();

    expect(find.text('No language pairs yet'), findsOneWidget);
  });

  testWidgets('remove-language: deleting a pair clears it', (tester) async {
    await pump(tester, dark: false);

    // Add a pair first.
    await tester.tap(find.text('Add language'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(LangCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MxListRow, '한국어'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(LangCard).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MxListRow, 'English').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add language pair'));
    await tester.pumpAndSettle();
    expect(find.text('한국어 → English'), findsOneWidget);

    // Delete it → confirm.
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(find.text('No language pairs yet'), findsOneWidget);
  });
}
