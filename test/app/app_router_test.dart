import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/app/router/app_router.dart';
import 'package:memox_v4/app/router/route_paths.dart';
import 'package:memox_v4/presentation/shared/foundation_screen.dart';

void main() {
  test('root path constant is /', () {
    expect(RoutePaths.root, '/');
  });

  test('router registers the foundation root via the RoutePaths constant', () {
    final router = AppRouter.create();
    final paths = router.configuration.routes
        .whereType<GoRoute>()
        .map((route) => route.path)
        .toList();
    expect(paths, contains(RoutePaths.root));
  });

  testWidgets('starts at the initial route showing FoundationScreen', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: AppRouter.create()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FoundationScreen), findsOneWidget);
  });
}
