import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// Semantic tone for [MxBadge] (`neutral` is the base primary badge).
enum MxBadgeTone { neutral, success, warning, error }

/// The kit's small count / status badge (`MxBadge` · base class `.badge`).
/// Solid by default, or a lighter [soft] tint; [dot] renders a bare status dot
/// (no content). Token-driven via [MxTheme]; a primitive (pure presentation).
class MxBadge extends StatelessWidget {
  const MxBadge({
    this.label,
    this.tone = MxBadgeTone.neutral,
    this.soft = false,
    this.dot = false,
    super.key,
  });

  /// Count/status text (the kit `children`). Ignored when [dot] is set.
  final String? label;
  final MxBadgeTone tone;
  final bool soft;
  final bool dot;

  // Kit `.badge` metrics — raw px with no matching token.
  static const double _height = 20;
  static const double _minWidth = 20;
  static const double _dotSize = 10;
  static const double _paddingX = 6;
  // 12px floor (M3-2 / audit G7) — mirrors kit `.badge` font-size-xs.
  static const double _fontSize = MxTypography.sizeXs;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = _colors(mx, scheme);

    if (dot) {
      return Container(
        width: _dotSize,
        height: _dotSize,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      );
    }

    return Container(
      height: _height,
      constraints: const BoxConstraints(minWidth: _minWidth),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: _paddingX),
      decoration: BoxDecoration(
        color: background,
        borderRadius: MxRadius.pillRadius,
      ),
      child: Text(
        label ?? '',
        style: TextStyle(
          fontFamily: MxTypography.fontFamily,
          fontSize: _fontSize,
          fontWeight: MxTypography.bold,
          height: 1,
          color: foreground,
        ),
      ),
    );
  }

  (Color, Color) _colors(MxTheme mx, ColorScheme scheme) {
    return switch ((tone, soft)) {
      (MxBadgeTone.neutral, false) => (scheme.primary, scheme.onPrimary),
      (MxBadgeTone.neutral, true) => (mx.primarySoft, mx.onPrimarySoft),
      (MxBadgeTone.success, false) => (mx.success, mx.onSuccess),
      (MxBadgeTone.success, true) => (mx.successSoft, mx.onSuccessSoft),
      (MxBadgeTone.warning, false) => (mx.warning, mx.onWarning),
      (MxBadgeTone.warning, true) => (mx.warningSoft, mx.onWarningSoft),
      (MxBadgeTone.error, false) => (scheme.error, scheme.onError),
      (MxBadgeTone.error, true) => (mx.errorSoft, mx.onErrorSoft),
    };
  }
}
