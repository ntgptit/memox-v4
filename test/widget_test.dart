import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/app/app.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/presentation/features/dashboard/screens/dashboard_screen.dart';

import 'harness/provider_harness.dart';

/// Bootstrap smoke test: [MemoxApp] boots through the router into the tab shell on
/// the Today branch (the real S.01 dashboard), with the Tier-0 tokens applied as
/// the Material theme. Booted against the fake data layer (DT.5 swaps in Drift).
void main() {
  testWidgets('MemoxApp boots into the tab shell on Today, applies token theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: FakeHarness().overrides, child: const MemoxApp()),
    );
    await tester.pumpAndSettle();

    // The bottom-nav shell is present and the Today dashboard is showing.
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);

    // Scaffold background comes from the light token value (system → light in the
    // test harness), proving the theme is assembled from the token mirrors.
    final ctx = tester.element(find.byType(NavigationBar));
    expect(Theme.of(ctx).scaffoldBackgroundColor, MxColors.light.bg);
  });
}
