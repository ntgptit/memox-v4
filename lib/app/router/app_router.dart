import 'package:go_router/go_router.dart';
import 'package:memox_v4/app/router/route_paths.dart';
import 'package:memox_v4/domain/types/game_scope.dart';
import 'package:memox_v4/domain/types/game_type.dart';
import 'package:memox_v4/domain/types/study_entry.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/deck/screens/deck_detail_screen.dart';
import 'package:memox_v4/presentation/features/deck/screens/library_screen.dart';
import 'package:memox_v4/presentation/features/flashcard/screens/flashcard_editor_screen.dart';
import 'package:memox_v4/presentation/features/game/screens/game_picker_screen.dart';
import 'package:memox_v4/presentation/features/game/screens/game_screen.dart';
import 'package:memox_v4/presentation/features/game/viewmodels/game_session_notifier.dart';
import 'package:memox_v4/presentation/features/search/screens/search_screen.dart';
import 'package:memox_v4/presentation/features/study/screens/player_screen.dart';
import 'package:memox_v4/presentation/features/study/screens/review_screen.dart';
import 'package:memox_v4/presentation/features/study/screens/study_session_screen.dart';
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
                builder: (context, state) => const LibraryScreen(),
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
      GoRoute(
        path: RoutePaths.deckDetail,
        builder: (context, state) =>
            DeckDetailScreen(deckId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: RoutePaths.flashcardEditor,
        builder: (context, state) {
          final deckId = int.parse(state.pathParameters['id']!);
          final cardIdRaw = state.uri.queryParameters['cardId'];
          return FlashcardEditorScreen(
            deckId: deckId,
            cardId: cardIdRaw == null ? null : int.tryParse(cardIdRaw),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.gamePlay,
        builder: (context, state) {
          final query = state.uri.queryParameters;
          return GameScreen(
            request: GameRequest(
              nodeId: int.parse(state.pathParameters['nodeId']!),
              type: GameType.values.byName(
                query['type'] ?? GameType.matching.name,
              ),
              scope: GameScope.values.byName(
                query['scope'] ?? GameScope.spaced.name,
              ),
              random: query['random'] != 'false',
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.gamePicker,
        builder: (context, state) => GamePickerScreen(
          nodeId: int.parse(state.pathParameters['nodeId']!),
        ),
      ),
      GoRoute(
        path: RoutePaths.study,
        builder: (context, state) => StudySessionScreen(
          nodeId: int.parse(state.pathParameters['nodeId']!),
          entry: StudyEntry.values.byName(
            state.uri.queryParameters['entry'] ?? StudyEntry.dueReview.name,
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.review,
        builder: (context, state) =>
            ReviewScreen(nodeId: int.parse(state.pathParameters['nodeId']!)),
      ),
      GoRoute(
        path: RoutePaths.player,
        builder: (context, state) =>
            PlayerScreen(nodeId: int.parse(state.pathParameters['nodeId']!)),
      ),
      GoRoute(
        path: RoutePaths.search,
        builder: (context, state) => const SearchScreen(),
      ),
    ],
  );
}
