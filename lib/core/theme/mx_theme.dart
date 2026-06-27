import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/core/theme/mx_elevation.dart';

/// Carries the design tokens that Material's [ThemeData]/[ColorScheme] cannot
/// express: the full semantic [MxColors] palette (success/warning/info, soft
/// containers, surface tiers, interaction overlays) and the [MxShadows] set.
///
/// Features read these via `MxTheme.of(context)`, so light/dark resolve through
/// the active [Theme] — never a raw `MxColors.light` reference in UI.
///
/// `lerp` switches the bundle discretely at the animation midpoint: the brand
/// hue animation is carried by the [ColorScheme] on [ThemeData]; the semantic
/// accents and shadows here read identically enough mid-transition that a
/// per-field interpolation isn't worth its bulk. Revisit if a visible pop
/// appears during animated theme changes.
@immutable
class MxTheme extends ThemeExtension<MxTheme> {
  const MxTheme({required this.colors, required this.shadows});

  final MxColors colors;
  final MxShadows shadows;

  static const MxTheme light = MxTheme(
    colors: MxColors.light,
    shadows: MxShadows.light,
  );

  static const MxTheme dark = MxTheme(
    colors: MxColors.dark,
    shadows: MxShadows.dark,
  );

  /// The active token bundle. Asserts the extension is registered — every app
  /// theme built by `AppTheme` includes it.
  static MxTheme of(BuildContext context) {
    final ext = Theme.of(context).extension<MxTheme>();
    assert(
      ext != null,
      'MxTheme extension missing — use AppTheme.light/dark()',
    );
    return ext!;
  }

  @override
  MxTheme copyWith({MxColors? colors, MxShadows? shadows}) {
    return MxTheme(
      colors: colors ?? this.colors,
      shadows: shadows ?? this.shadows,
    );
  }

  @override
  MxTheme lerp(covariant ThemeExtension<MxTheme>? other, double t) {
    if (other is! MxTheme) return this;
    return t < 0.5 ? this : other;
  }
}
