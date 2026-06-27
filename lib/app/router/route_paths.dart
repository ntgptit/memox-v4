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
}
