import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/settings/screens/srs_settings_screen.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_switch.dart';

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
          home: const SrsSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('shows the fixed schedule + notifications rows ($theme)',
        (tester) async {
      await pump(tester, dark: dark);

      expect(find.text('SCHEDULE'), findsOneWidget);
      expect(find.text('NOTIFICATIONS'), findsOneWidget);
      expect(find.text('Leitner boxes'), findsOneWidget);
      // Box count + intervals are rendered from the domain constants.
      expect(find.text('8'), findsOneWidget); // BoxLevel.max
      expect(find.text('1 · 3 · 7 · 14 · 30 · 60 · 120'), findsOneWidget);
      expect(find.text('Due notifications'), findsOneWidget);
    });
  }

  testWidgets('due-notifications toggle flips on and persists', (tester) async {
    await pump(tester, dark: false);

    // Opt-in default: off.
    expect(tester.widget<MxSwitch>(find.byType(MxSwitch)).value, isFalse);

    await tester.tap(find.byType(MxSwitch));
    await tester.pumpAndSettle();

    // The controller saved the preference and the re-read reflects it.
    expect(tester.widget<MxSwitch>(find.byType(MxSwitch)).value, isTrue);
  });
}
