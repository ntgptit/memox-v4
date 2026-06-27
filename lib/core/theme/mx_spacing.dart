/// Spacing scale (4px base) + layout rhythm, mirroring the frozen tokens in
/// `docs/design/MemoX Design System/tokens/spacing.css` (`--memox-space-*`).
///
/// Theme-independent. Features use these named steps for padding/gaps — never
/// eyeballed pixel literals (`docs/design/design-language.md`).
abstract final class MxSpacing {
  const MxSpacing._();

  static const double space0 = 0;
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space7 = 32;
  static const double space8 = 40;
  static const double space9 = 48;
  static const double space10 = 64;
  static const double space11 = 80;
  static const double space12 = 96;

  // ── layout rhythm ──────────────────────────────────────────────────────────
  /// Screen edge padding on phones (`--memox-gutter`).
  static const double gutter = 20;
  static const double appBarHeight = 64;
  static const double appBarLargeHeight = 112;
  static const double bottomNavHeight = 72;
  static const double fabSize = 60;

  /// Minimum interactive target — platform a11y floor (`--memox-touch-min`).
  static const double minTouchTarget = 48;
}
