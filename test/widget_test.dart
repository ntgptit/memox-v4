import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:memox_v4/app/app.dart';
import 'package:memox_v4/core/constants/app_constants.dart';
import 'package:memox_v4/core/routes/app_router.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';

/// Bootstrap smoke tests: [MemoxApp] boots through the router to its home and
/// applies the Tier-0 tokens as the Material theme.
void main() {
  testWidgets('MemoxApp boots, routes to home, applies token theme', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MemoxApp()));
    await tester.pumpAndSettle();

    // Router reached the placeholder home (brand name only, no localizable copy).
    expect(find.text(AppConstants.appName), findsOneWidget);

    // Scaffold background is driven by the light token value (system → light in
    // the test harness), proving the theme is assembled from the token mirrors.
    final ctx = tester.element(find.byType(Scaffold));
    expect(Theme.of(ctx).scaffoldBackgroundColor, MxColors.light.bg);
  });

  test('routerProvider yields a GoRouter', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(routerProvider), isA<GoRouter>());
  });
}
