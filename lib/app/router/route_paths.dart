/// Centralized route paths.
///
/// The single source of route path strings — features reference these constants
/// and never hardcode paths (`docs/business/navigation/navigation-flow.md`).
abstract final class RoutePaths {
  const RoutePaths._();

  /// Application root. The navigation contract designates `/` as the library
  /// tree (W6); until then W1 mounts a foundation placeholder here.
  static const String root = '/';
}
