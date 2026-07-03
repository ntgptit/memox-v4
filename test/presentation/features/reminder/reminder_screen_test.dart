import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/reminder/providers/reminder_providers.dart';
import 'package:memox_v4/presentation/features/reminder/screens/reminder_screen.dart';
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
          home: const ReminderScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(ReminderScreen)));

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('off by default: toggle + time + chips render ($theme)',
        (tester) async {
      await pump(tester, dark: dark);

      expect(find.text('Reminders'), findsOneWidget);
      expect(find.text('Study reminders'), findsOneWidget);
      expect(find.text('13:00'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      // Default is off.
      expect(containerOf(tester).read(reminderControllerProvider).isEnabled, isFalse);
    });
  }

  testWidgets('toggling the switch on enables every weekday', (tester) async {
    await pump(tester, dark: false);

    await tester.tap(find.byType(MxSwitch));
    await tester.pumpAndSettle();

    final reminder = containerOf(tester).read(reminderControllerProvider);
    expect(reminder.isEnabled, isTrue);
    expect(reminder.weekdays.length, 7);
  });

  testWidgets('tapping a weekday chip toggles that day off', (tester) async {
    await pump(tester, dark: false);
    // Turn on first (all days).
    await tester.tap(find.byType(MxSwitch));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mon'));
    await tester.pumpAndSettle();

    final reminder = containerOf(tester).read(reminderControllerProvider);
    expect(reminder.weekdays.contains(DateTime.monday), isFalse);
    expect(reminder.weekdays.length, 6);
  });

  testWidgets('time picker: choosing an hour updates the reminder time',
      (tester) async {
    await pump(tester, dark: false);
    await tester.tap(find.byType(MxSwitch)); // enable → time card active
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.schedule));
    await tester.pumpAndSettle();

    expect(find.text('PICK REMINDER TIME'), findsOneWidget);
    // Hour 01 is visible at the top of the hours column (minutes are 00/15/30/45).
    await tester.tap(find.text('01'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('01:00'), findsOneWidget);
  });
}
