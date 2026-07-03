import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/routes/app_routes.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/dashboard/screens/dashboard_screen.dart';
import 'package:memox_v4/presentation/features/deck-detail/screens/deck_detail_screen.dart';
import 'package:memox_v4/presentation/features/drawer/screens/drawer_screen.dart';
import 'package:memox_v4/presentation/features/export/screens/export_screen.dart';
import 'package:memox_v4/presentation/features/flashcard-editor/screens/flashcard_editor_screen.dart';
import 'package:memox_v4/presentation/features/game-matching/screens/game_matching_screen.dart';
import 'package:memox_v4/presentation/features/game-mc/screens/game_mc_screen.dart';
import 'package:memox_v4/presentation/features/game-picker/screens/game_picker_screen.dart';
import 'package:memox_v4/presentation/features/game-recall/screens/game_recall_screen.dart';
import 'package:memox_v4/presentation/features/game-typing/screens/game_typing_screen.dart';
import 'package:memox_v4/presentation/features/import/screens/import_screen.dart';
import 'package:memox_v4/presentation/features/library/screens/library_screen.dart';
import 'package:memox_v4/presentation/features/player/screens/player_screen.dart';
import 'package:memox_v4/presentation/features/reminder/screens/reminder_screen.dart';
import 'package:memox_v4/presentation/features/review/screens/review_screen.dart';
import 'package:memox_v4/presentation/features/search/screens/search_screen.dart';
import 'package:memox_v4/presentation/features/settings/screens/settings_screen.dart';
import 'package:memox_v4/presentation/features/statistics/screens/statistics_screen.dart';
import 'package:memox_v4/presentation/features/study-session/screens/study_session_screen.dart';
import 'package:memox_v4/presentation/features/theme/screens/theme_screen.dart';
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
          // The Today tab hosts the real S.01 dashboard; deck-detail (S.03) stays
          // a stub under it until built.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.today,
                builder: (context, state) => const DashboardScreen(),
                routes: [
                  GoRoute(
                    path: Routes.deckDetailPattern,
                    builder: (context, state) => DeckDetailScreen(
                        deckId: state.pathParameters['deckId'] ?? ''),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.library,
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.add,
                builder: (context, state) => const FlashcardEditorScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.stats,
                builder: (context, state) => const StatisticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      // Full-screen routes (rendered above the shell — no bottom nav).
      ..._fullScreenRoutes,
    ],
  );
}


/// The v1 screens with no fixed path parameters, as top-level stub routes.
const _fullScreenPaths = [
  Routes.studyResult,
];

/// Every remaining v1 screen as a top-level stub route (above the shell).
final List<GoRoute> _fullScreenRoutes = [
  GoRoute(path: Routes.search, builder: (context, state) => const SearchScreen()),
  GoRoute(path: Routes.drawer, builder: (context, state) => const DrawerScreen()),
  GoRoute(
    path: Routes.reminder,
    builder: (context, state) => const ReminderScreen(),
  ),
  GoRoute(path: Routes.theme, builder: (context, state) => const ThemeScreen()),
  GoRoute(path: Routes.import_, builder: (context, state) => const ImportScreen()),
  GoRoute(path: Routes.export_, builder: (context, state) => const ExportScreen()),
  GoRoute(path: Routes.games, builder: (context, state) => const GamePickerScreen()),
  GoRoute(
    path: Routes.gameMatching,
    builder: (context, state) => const GameMatchingScreen(),
  ),
  GoRoute(path: Routes.gameMc, builder: (context, state) => const GameMcScreen()),
  GoRoute(
    path: Routes.gameRecall,
    builder: (context, state) => const GameRecallScreen(),
  ),
  GoRoute(
    path: Routes.gameTyping,
    builder: (context, state) => const GameTypingScreen(),
  ),
  GoRoute(
    path: Routes.review,
    builder: (context, state) => const ReviewScreen(),
  ),
  GoRoute(
    path: Routes.player,
    builder: (context, state) => const PlayerScreen(),
  ),
  GoRoute(
    path: Routes.study,
    builder: (context, state) => const StudySessionScreen(),
  ),
  for (final p in _fullScreenPaths)
    GoRoute(path: p, builder: (context, state) => RouteStub(p)),
  GoRoute(
    path: Routes.editCardPattern,
    builder: (context, state) =>
        FlashcardEditorScreen(cardId: state.pathParameters['cardId']),
  ),
];

/// Bottom-nav scaffold for the tab shell. Holds no state of its own — the
/// [StatefulNavigationShell] owns the selected branch, so there is no `setState`.
class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
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
              label: _navLabel(tab, l10n),
            ),
        ],
      ),
    );
  }

  static String _navLabel(AppTab tab, AppLocalizations l10n) => switch (tab) {
        AppTab.today => l10n.navToday,
        AppTab.library => l10n.navLibrary,
        AppTab.add => l10n.navAdd,
        AppTab.stats => l10n.navStats,
        AppTab.profile => l10n.navProfile,
      };
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.routeNotFoundTitle)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: MxIconSize.lg),
            const SizedBox(height: MxSpacing.space2),
            Text(l10n.routeNotFoundTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: MxSpacing.space1),
            Text(location, style: theme.textTheme.bodySmall),
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
