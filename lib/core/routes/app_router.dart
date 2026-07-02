import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/routes/app_routes.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// The app router: a [StatefulShellRoute.indexedStack] hosting the five bottom-nav
/// tabs (state preserved per branch), plus full-screen route stubs for the rest of
/// the v1 screens. Every destination renders a [RouteStub] until Phase S builds the
/// real screens.
///
/// Riverpod owns the router so it can later depend on auth/onboarding state via
/// `ref.watch` without a global singleton.
@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: Routes.today,
    // Unknown / malformed locations render a graceful fallback instead of a
    // red-screen crash — a foundation guarantee (I.9).
    errorBuilder: (context, state) => RouteErrorScreen(state.uri.toString()),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _ShellScaffold(navigationShell: navigationShell),
        branches: [
          _branch(Routes.today, extra: [
            GoRoute(
              path: Routes.deckDetailPattern,
              builder: (context, state) =>
                  RouteStub(Routes.deckDetail(state.pathParameters['deckId'] ?? '')),
            ),
          ]),
          _branch(Routes.library),
          _branch(Routes.add),
          _branch(Routes.stats),
          _branch(Routes.profile),
        ],
      ),
      // Full-screen routes (rendered above the shell — no bottom nav).
      ..._fullScreenRoutes,
    ],
  );
}

/// A shell branch whose root path renders its [RouteStub]; [extra] are nested
/// sub-routes under that root.
StatefulShellBranch _branch(String path, {List<RouteBase> extra = const []}) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        builder: (context, state) => RouteStub(path),
        routes: extra,
      ),
    ],
  );
}

/// The v1 screens with no fixed path parameters, as top-level stub routes.
const _fullScreenPaths = [
  Routes.search,
  Routes.drawer,
  Routes.reminder,
  Routes.theme,
  Routes.import_,
  Routes.export_,
  Routes.games,
  Routes.gameMatching,
  Routes.gameMc,
  Routes.gameRecall,
  Routes.gameTyping,
  Routes.review,
  Routes.player,
  Routes.study,
  Routes.studyResult,
];

/// Every remaining v1 screen as a top-level stub route (above the shell).
final List<GoRoute> _fullScreenRoutes = [
  for (final p in _fullScreenPaths)
    GoRoute(path: p, builder: (context, state) => RouteStub(p)),
  GoRoute(
    path: Routes.editCardPattern,
    builder: (context, state) =>
        RouteStub(Routes.editCard(state.pathParameters['cardId'] ?? '')),
  ),
];

/// Bottom-nav scaffold for the tab shell. Holds no state of its own — the
/// [StatefulNavigationShell] owns the selected branch, so there is no `setState`.
class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        // Labels are deferred to T.4 (l10n); hide them so no copy is hardcoded.
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Re-tapping the active tab returns it to its root.
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          for (final tab in AppTab.values)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              // Technical placeholder (route path), hidden; T.4 localizes.
              label: tab.path,
            ),
        ],
      ),
    );
  }
}

/// Fallback for an unknown or malformed location (go_router `errorBuilder`).
/// Shows the attempted location (technical, not localizable copy) so the app never
/// hard-crashes on a bad route. Localized copy arrives with T.4.
class RouteErrorScreen extends StatelessWidget {
  const RouteErrorScreen(this.location, {super.key});

  final String location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: MxIconSize.lg),
            const SizedBox(height: MxSpacing.space2),
            Text(location, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

/// Placeholder screen for a not-yet-built route. Shows the route's technical path
/// (not localizable copy) — Phase S replaces each with the real screen.
class RouteStub extends StatelessWidget {
  const RouteStub(this.path, {super.key});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(path)),
      body: Center(
        child: Text(path, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
