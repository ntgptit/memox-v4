import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/app/app.dart';
import 'package:memox_v4/core/routes/app_routes.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';

/// Bootstrap smoke test: [MemoxApp] boots through the router into the tab shell on
/// the Today branch, with the Tier-0 tokens applied as the Material theme.
void main() {
  testWidgets('MemoxApp boots into the tab shell on Today, applies token theme', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MemoxApp()));
    await tester.pumpAndSettle();

    // The bottom-nav shell is present and the Today stub is showing.
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.widgetWithText(AppBar, Routes.today), findsOneWidget);

    // Scaffold background comes from the light token value (system → light in the
    // test harness), proving the theme is assembled from the token mirrors.
    final ctx = tester.element(find.byType(NavigationBar));
    expect(Theme.of(ctx).scaffoldBackgroundColor, MxColors.light.bg);
  });
}
