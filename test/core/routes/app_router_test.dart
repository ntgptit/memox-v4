import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:memox_v4/app/app.dart';
import 'package:memox_v4/core/routes/app_router.dart';
import 'package:memox_v4/core/routes/app_routes.dart';
import 'package:memox_v4/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox_v4/presentation/features/library/screens/library_screen.dart';

import '../../harness/provider_harness.dart';

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
    await tester.pumpWidget(
      ProviderScope(overrides: FakeHarness().overrides, child: const MemoxApp()),
    );
    await tester.pumpAndSettle();

    // Starts on Today (the real dashboard).
    expect(find.byType(DashboardScreen), findsOneWidget);

    // Tap the (unselected) Library destination — the real S.02 library screen.
    await tester.tap(find.byIcon(AppTab.library.icon));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsNothing);
    expect(find.byType(LibraryScreen), findsOneWidget);
  });
}
