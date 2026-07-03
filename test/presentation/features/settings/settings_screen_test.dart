import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/settings/screens/settings_screen.dart';
import 'package:memox_v4/presentation/features/settings/widgets/profile_card.dart';

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
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('loaded: profile + grouped setting rows ($theme)', (tester) async {
      await pump(tester, dark: dark);

      expect(find.byType(ProfileCard), findsOneWidget);
      expect(find.text('STUDYING'), findsOneWidget);
      expect(find.text('APP'), findsOneWidget);
      expect(find.text('Game settings'), findsOneWidget);
      expect(find.text('5 words per round'), findsOneWidget); // default D-008
      expect(find.text('Reminders'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      // No language pair seeded → "Not set".
      expect(find.text('Not set'), findsOneWidget);
    });
  }

  testWidgets('value-picker: choosing a word count updates the row',
      (tester) async {
    await pump(tester, dark: false);

    await tester.tap(find.text('Game settings'));
    await tester.pumpAndSettle();

    expect(find.text('WORDS PER ROUND'), findsOneWidget); // sheet title (uppercased)
    expect(find.text('10 words'), findsOneWidget);

    await tester.tap(find.text('10 words'));
    await tester.pumpAndSettle();

    expect(find.text('10 words per round'), findsOneWidget); // row updated
    expect(find.text('5 words per round'), findsNothing);
  });
}
