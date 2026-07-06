import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// Fill for [MxFab] (`primary` is the base).
enum MxFabVariant { primary, accent }

/// The kit's floating action button (`MxFab` · base class `.fab`): extended
/// (icon + label) or round (icon-only). A composite wrapping Material for real
/// button semantics + ripple; token-driven via [MxTheme], including the exact
/// `shadow-fab` glow (a plain surface, so no elevation approximation).
///
/// A round FAB has no visible text, so pass [semanticLabel] (from ARB) for
/// screen readers; an extended FAB uses its [label].
class MxFab extends StatelessWidget {
  const MxFab({
    this.icon,
    this.label,
    this.onPressed,
    this.variant = MxFabVariant.primary,
    this.round = false,
    this.semanticLabel,
    super.key,
  });

  final IconData? icon;
  final String? label;
  final VoidCallback? onPressed;
  final MxFabVariant variant;
  final bool round;
  final String? semanticLabel;

  /// Kit `.fab .material-symbols-rounded` glyph = 26px, no matching token.
  static const double _glyphSize = MxIconSize.lg; // Đ-K-1: 26 -> 28

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final label = this.label;
    final (background, foreground) = variant == MxFabVariant.accent
        ? (scheme.secondary, scheme.onSecondary)
        : (scheme.primary, scheme.onPrimary);

    final isRound = round || label == null;
    final shape = isRound
        ? const CircleBorder()
        : const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(MxRadius.xl)),
          );

    final child = isRound
        ? SizedBox(
            width: MxSpacing.fabSize,
            height: MxSpacing.fabSize,
            child: Icon(icon, size: _glyphSize, color: foreground),
          )
        : ConstrainedBox(
            constraints: const BoxConstraints(minWidth: MxSpacing.fabSize),
            child: SizedBox(
              height: MxSpacing.fabSize,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: MxSpacing.space5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: MxSpacing.space2,
                  children: [
                    if (icon != null) Icon(icon, size: _glyphSize, color: foreground),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: MxTypography.fontFamily,
                        fontSize: MxTypography.sizeBase,
                        fontWeight: MxTypography.bold,
                        color: foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

    return Semantics(
      button: true,
      label: label ?? semanticLabel,
      child: DecoratedBox(
        decoration: ShapeDecoration(shape: shape, shadows: mx.shadows.fab),
        child: Material(
          color: background,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(onTap: onPressed, child: child),
        ),
      ),
    );
  }
}
