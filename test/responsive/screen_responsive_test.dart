import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/app/app.dart';
import 'package:memox_v4/presentation/shared/composites/mx_bottom_nav.dart';

import '../harness/provider_harness.dart';

/// V.6 — a real-screen responsive sweep: the running app (dashboard on the Today
/// tab, over the fake data layer) renders without overflow from the narrowest
/// supported phone to a desktop width.
Future<void> _pumpApp(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(overrides: FakeHarness().overrides, child: const MemoxApp()),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final width in const [320.0, 360.0, 390.0, 430.0, 768.0, 1024.0, 1440.0]) {
    testWidgets('the app renders without overflow at ${width.toInt()}px',
        (tester) async {
      await _pumpApp(tester, width);
      expect(tester.takeException(), isNull);
      // The bottom nav is present at every width (the shell never collapses).
      expect(find.byType(MxBottomNav), findsOneWidget);
    });
  }
}
