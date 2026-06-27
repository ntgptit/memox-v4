import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/app/router/app_router.dart';
import 'package:memox_v4/app/router/route_paths.dart';

/// Flattens every [GoRoute] path in the router tree, descending into shell
/// branches.
Iterable<String> _paths(List<RouteBase> routes) sync* {
  for (final route in routes) {
    if (route is GoRoute) {
      yield route.path;
      yield* _paths(route.routes);
    } else if (route is StatefulShellRoute) {
      for (final branch in route.branches) {
        yield* _paths(branch.routes);
      }
    } else if (route is ShellRoute) {
      yield* _paths(route.routes);
    }
  }
}

void main() {
  test('root path constant is /', () {
    expect(RoutePaths.root, '/');
  });

  test('shell registers the four tab routes via RoutePaths constants', () {
    final router = AppRouter.create();
    final paths = _paths(router.configuration.routes).toSet();
    expect(
      paths,
      containsAll(<String>[
        RoutePaths.root,
        RoutePaths.today,
        RoutePaths.statistics,
        RoutePaths.profile,
      ]),
    );
  });
}
