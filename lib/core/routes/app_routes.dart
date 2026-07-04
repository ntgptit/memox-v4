import 'package:flutter/material.dart';

/// Typed route table — the single source of path strings for the whole app, so
/// navigation never hardcodes a literal path. Parameterized routes are exposed as
/// helper methods (e.g. [deckDetail]) that build the concrete location.
///
/// Covers the 21 active v1 screens (S.01–S.21). `account-sync` (S.22) is deferred
/// for v1, so it has no route yet.
abstract final class Routes {
  // Bottom-nav tab roots (see [AppTab]).
  static const today = '/today'; // S.01 dashboard
  static const library = '/library'; // S.02 library
  static const add = '/add'; // S.12 flashcard-editor (create)
  static const stats = '/stats'; // S.09 statistics
  static const profile = '/profile'; // S.05 settings / account area

  // Full-screen routes above the shell.
  static const search = '/search'; // S.04
  static const drawer = '/drawer'; // S.06
  static const reminder = '/reminder'; // S.07
  static const theme = '/theme'; // S.08
  static const settingsSrs = '/settings/srs'; // S.05 SRS detail sub-page
  static const import_ = '/import'; // S.10
  static const export_ = '/export'; // S.11
  static const games = '/games'; // S.13 game-picker
  static const gameMatching = '/games/matching'; // S.14
  static const gameMc = '/games/mc'; // S.15
  static const gameRecall = '/games/recall'; // S.16
  static const gameTyping = '/games/typing'; // S.17
  static const review = '/review'; // S.18
  static const player = '/player'; // S.19
  static const study = '/study'; // S.20 study-session
  static const studyResult = '/study/result'; // S.21

  // Parameterized routes — path patterns (for GoRoute.path) + builders.
  static const deckDetailPattern = '/deck/:deckId'; // S.03
  static const editCardPattern = '/editor/:cardId'; // S.12 (edit)

  /// Location for a deck's detail screen.
  static String deckDetail(String deckId) => '/deck/$deckId';

  /// Location for editing an existing card.
  static String editCard(String cardId) => '/editor/$cardId';
}

/// The five bottom-nav destinations. Icons only for now — visible labels are
/// deferred to T.4 (l10n) so no user-facing copy is hardcoded here.
enum AppTab {
  today(Routes.today, Icons.today_outlined, Icons.today),
  library(Routes.library, Icons.folder_outlined, Icons.folder),
  add(Routes.add, Icons.add_circle_outline, Icons.add_circle),
  stats(Routes.stats, Icons.bar_chart_outlined, Icons.bar_chart),
  profile(Routes.profile, Icons.person_outline, Icons.person);

  const AppTab(this.path, this.icon, this.selectedIcon);

  final String path;
  final IconData icon;
  final IconData selectedIcon;
}
