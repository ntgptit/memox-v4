import 'package:go_router/go_router.dart';
import 'package:memox_v4/app/router/route_paths.dart';
import 'package:memox_v4/presentation/shared/foundation_screen.dart';

/// Builds the application [GoRouter].
///
/// Routes reference [RoutePaths] constants only. Business routes (W2–W14) are
/// added with their features; W1 wires the root alone.
abstract final class AppRouter {
  const AppRouter._();

  /// Creates the router with the foundation root route.
  static GoRouter create() {
    return GoRouter(
      initialLocation: RoutePaths.root,
      routes: <RouteBase>[
        GoRoute(
          path: RoutePaths.root,
          builder: (context, state) => const FoundationScreen(),
        ),
      ],
    );
  }
}
