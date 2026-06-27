/// App-wide foundation constants.
///
/// Brand identifiers and cross-cutting literals that are not user-facing,
/// localizable copy. Feature- or domain-specific values do not belong here.
abstract final class AppConstants {
  const AppConstants._();

  /// Product/brand name. Not localizable copy — a stable identifier.
  static const String appName = 'MemoX';
}
