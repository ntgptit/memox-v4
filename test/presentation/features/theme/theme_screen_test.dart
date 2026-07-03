import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/domain/entities/theme_settings.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/theme/providers/theme_providers.dart';
import 'package:memox_v4/presentation/features/theme/screens/theme_screen.dart';
import 'package:memox_v4/presentation/features/theme/widgets/preview_card.dart';

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
          home: const ThemeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  ThemeSettings settingsOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(ThemeScreen)))
          .read(themeControllerProvider)
          .requireValue;

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('loaded: preview + three controls ($theme)', (tester) async {
      await pump(tester, dark: dark);

      expect(find.byType(PreviewCard), findsOneWidget);
      expect(find.text('Color mode'), findsOneWidget);
      expect(find.text('Accent color'), findsOneWidget);
      expect(find.text('Text size'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      // Defaults (D-… personalization): system mode, brand accent, medium text.
      expect(settingsOf(tester).mode, ColorMode.system);
    });
  }

  testWidgets('choosing dark mode saves it', (tester) async {
    await pump(tester, dark: false);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(settingsOf(tester).mode, ColorMode.dark);
  });

  testWidgets('choosing a warm accent saves it', (tester) async {
    await pump(tester, dark: false);

    await tester.tap(find.bySemanticsLabel('Warm'));
    await tester.pumpAndSettle();

    expect(settingsOf(tester).accent, AccentColor.warm);
  });

  testWidgets('choosing a large text size saves it', (tester) async {
    await pump(tester, dark: false);

    await tester.tap(find.text('Large'));
    await tester.pumpAndSettle();

    expect(settingsOf(tester).fontScale, FontScale.large);
  });
}
