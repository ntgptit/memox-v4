import 'package:go_router/go_router.dart';
import 'package:memox_v4/app/router/route_paths.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/shared/navigation/app_shell.dart';
import 'package:memox_v4/presentation/shared/widgets/mx_placeholder.dart';

/// Builds the application [GoRouter].
///
/// The root hosts a [StatefulShellRoute] with the four primary tabs (Today,
/// Library, Stats, Profile). Routes reference [RoutePaths] constants only. Tab
/// bodies are placeholders until their features land (W6/W9/W10/W11); the center
/// Add action and push routes (deck, study, …) arrive with their features.
abstract final class AppRouter {
  const AppRouter._();

  static GoRouter create() => GoRouter(
    initialLocation: RoutePaths.root,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.today,
                builder: (context, state) =>
                    MxPlaceholder(title: AppLocalizations.of(context).tabToday),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.root,
                builder: (context, state) => MxPlaceholder(
                  title: AppLocalizations.of(context).tabLibrary,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.statistics,
                builder: (context, state) =>
                    MxPlaceholder(title: AppLocalizations.of(context).tabStats),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.profile,
                builder: (context, state) => MxPlaceholder(
                  title: AppLocalizations.of(context).tabProfile,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
