import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/l10n/app_localizations.dart';

/// Pumps [child] inside a themed [MaterialApp] at a fixed surface size for a
/// deterministic golden. Font loading is handled once by
/// `test/flutter_test_config.dart`; this only fixes the theme, size, and pixel
/// ratio so goldens are reproducible.
Future<void> pumpForGolden(
  WidgetTester tester,
  Widget child, {
  required ThemeData theme,
  Size size = const Size(320, 240),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    ),
  );
  await tester.pumpAndSettle();
}
