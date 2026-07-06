import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/l10n/app_localizations.dart';

import '../../fixtures/_fixture.dart';

/// The phone frame every screen golden renders at (kit shots are 390×780).
const Size kScreenGoldenSize = Size(390, 780);

/// Pumps a full feature [home] screen for a golden, seeded by [fixture] and
/// themed by [theme] (golden-parity WBS). The fixture owns its COMPLETE provider
/// override list (typically `FakeHarness(...).overrides`), so no base overrides
/// are added here — that avoids duplicate-provider collisions. An un-filled
/// scaffold fixture fails fast via [StateFixture.failIfUnimplemented] before any
/// render, so a missing state can never pass silently.
Future<void> pumpScreenGolden(
  WidgetTester tester, {
  required Widget home,
  required StateFixture fixture,
  required ThemeData theme,
}) async {
  fixture.failIfUnimplemented();

  tester.view.physicalSize = kScreenGoldenSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: fixture.overrides,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();

  final drive = fixture.drive;
  if (drive != null) {
    await drive(tester);
    await tester.pumpAndSettle();
  }
}
