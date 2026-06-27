/// Fixed-dimension scales, mirroring the frozen tokens in
/// `docs/design/MemoX Design System/tokens/{size,icon-size,stroke}.css`.
///
/// Dimensions for fixed-size visual elements (avatars, tiles, illustration
/// boxes), icon glyph sizes, and border/stroke widths. Fluid layout (flex,
/// fractions) stays unitless and is not tokenized here.
library;

/// Element size scale (`--memox-size-*`).
abstract final class MxSizes {
  const MxSizes._();

  static const double size3xs = 4;
  static const double size2xs = 8;
  static const double sizeXs = 16;
  static const double sizeSm = 40;
  static const double sizeMd = 56;
  static const double sizeLg = 74;
  static const double sizeXl = 96;
  static const double size2xl = 120;
  static const double size3xl = 220;
  static const double size4xl = 280;
  static const double size5xl = 320;
}

/// Icon glyph sizes (`--memox-icon-size-*`). Sizes that coincide with the type
/// scale (20, 24) reuse the type tokens in the design kit; here they are
/// distinct constants for icon-only call sites.
abstract final class MxIconSize {
  const MxIconSize._();

  static const double sm = 18;
  static const double md = 22;
  static const double lg = 28;
}

/// Border / stroke widths (`--memox-stroke-*`). Theme-independent — widths do
/// not change between light and dark.
abstract final class MxStroke {
  const MxStroke._();

  /// Default borders and dividers.
  static const double hairline = 1;

  /// Selected / active / state borders.
  static const double emphasis = 2;

  /// Focus and selection rings.
  static const double focus = 3;
}
