import 'package:memox_v4/domain/types/game_scope.dart';
import 'package:memox_v4/domain/types/game_type.dart';

/// Centralized route paths.
///
/// The single source of route path strings — features reference these constants
/// and never hardcode paths (`docs/business/navigation/navigation-flow.md`).
abstract final class RoutePaths {
  const RoutePaths._();

  /// Application root and the Library tab — the deck tree (`library` in
  /// `docs/business/navigation/navigation-flow.md`). W6 replaces its placeholder
  /// body with the real tree.
  static const String root = '/';

  /// Today tab — engagement dashboard (W11).
  static const String today = '/today';

  /// Stats tab — learning statistics (W9).
  static const String statistics = '/statistics';

  /// Profile tab — account & settings entry (W10/W12).
  static const String profile = '/profile';

  /// Deck detail (a node: sub-decks + cards) — `deckDetail` in
  /// `docs/business/navigation/navigation-flow.md`. Path param: deck `id`.
  static const String deckDetail = '/deck/:id';

  /// Builds a concrete [deckDetail] location.
  static String deckDetailLocation(int deckId) => '/deck/$deckId';

  /// Flashcard editor (create/edit) under a deck — `flashcardEditor` in
  /// `docs/business/navigation/navigation-flow.md`. Path params: deck `id`;
  /// optional `cardId` query for edit mode.
  static const String flashcardEditor = '/deck/:id/card';

  /// Builds a concrete [flashcardEditor] location.
  static String flashcardEditorLocation(int deckId, {int? cardId}) {
    final base = '/deck/$deckId/card';
    return cardId == null ? base : '$base?cardId=$cardId';
  }

  /// Game picker at a node — `game` in
  /// `docs/business/navigation/navigation-flow.md`. Path param: `nodeId`.
  static const String gamePicker = '/game/:nodeId';

  static String gamePickerLocation(int nodeId) => '/game/$nodeId';

  /// A running game round. Query: `type`, `scope`, `random`.
  static const String gamePlay = '/game/:nodeId/play';

  static String gamePlayLocation(
    int nodeId,
    GameType type,
    GameScope scope, {
    bool random = true,
  }) =>
      '/game/$nodeId/play?type=${type.name}&scope=${scope.name}&random=$random';
}
