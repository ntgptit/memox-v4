import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:memox_v4/app/app.dart';
import 'package:memox_v4/core/routes/app_router.dart';
import 'package:memox_v4/core/routes/app_routes.dart';

void main() {
  test('routerProvider yields a GoRouter', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(routerProvider), isA<GoRouter>());
  });

  group('typed route table', () {
    test('deckDetail builds a parametrized location', () {
      expect(Routes.deckDetail('abc'), '/deck/abc');
    });

    test('editCard builds a parametrized location', () {
      expect(Routes.editCard('42'), '/editor/42');
    });

    test('AppTab exposes the five bottom-nav destinations in order', () {
      expect(
        AppTab.values.map((t) => t.path).toList(),
        [Routes.today, Routes.library, Routes.add, Routes.stats, Routes.profile],
      );
    });
  });

  testWidgets('tapping a tab switches the shell branch', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MemoxApp()));
    await tester.pumpAndSettle();

    // Starts on Today.
    expect(find.widgetWithText(AppBar, Routes.today), findsOneWidget);

    // Tap the (unselected) Library destination.
    await tester.tap(find.byIcon(AppTab.library.icon));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, Routes.library), findsOneWidget);
  });
}
