import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_component.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// Colour tone for [MxIconTile] (`primary` is the base soft tint).
enum MxIconTileTone { primary, accent, success, warning, error }

/// Size for [MxIconTile] (`medium` is the base).
enum MxIconTileSize { medium, large }

/// The kit's rounded, tinted tile that frames a single icon — deck/list leading
/// art (`MxIconTile` · base class `.icon-tile`). A composite, token-driven via
/// [MxTheme]. Purely decorative: the meaning comes from adjacent text, so the
/// glyph carries no semantic label. [solid] overrides the tone with a solid
/// primary fill.
class MxIconTile extends StatelessWidget {
  const MxIconTile({
    required this.icon,
    this.tone = MxIconTileTone.primary,
    this.size = MxIconTileSize.medium,
    this.solid = false,
    super.key,
  });

  final IconData icon;
  final MxIconTileTone tone;
  final MxIconTileSize size;
  final bool solid;

  // Kit `.icon-tile` metrics — raw px with no matching token.
  static const double _dimMedium = MxComponentSizes.iconTileMd;
  static const double _dimLarge = MxComponentSizes.iconTileLg;
  static const double _glyphMedium = MxIconSize.lg; // Đ-K-1: 26 -> 28
  static const double _glyphLarge = MxIconSize.xl;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = _colors(mx, scheme);

    final isLarge = size == MxIconTileSize.large;
    final dim = isLarge ? _dimLarge : _dimMedium;
    final glyph = isLarge ? _glyphLarge : _glyphMedium;
    final radius = isLarge
        ? const BorderRadius.all(Radius.circular(MxRadius.lg))
        : MxRadius.tileRadius;

    return Container(
      width: dim,
      height: dim,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, borderRadius: radius),
      child: Icon(icon, size: glyph, color: foreground),
    );
  }

  (Color, Color) _colors(MxTheme mx, ColorScheme scheme) {
    if (solid) return (scheme.primary, scheme.onPrimary);
    return switch (tone) {
      MxIconTileTone.primary => (mx.primarySoft, mx.onPrimarySoft),
      MxIconTileTone.accent => (mx.accentSoft, scheme.onSecondary),
      MxIconTileTone.success => (mx.successSoft, mx.onSuccessSoft),
      MxIconTileTone.warning => (mx.warningSoft, mx.onWarningSoft),
      MxIconTileTone.error => (mx.errorSoft, mx.onErrorSoft),
    };
  }
}
