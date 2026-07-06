import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_component.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// Emphasis for [MxIconButton], mirroring the kit `.icon-btn` modifiers
/// (`plain` is the base).
enum MxIconButtonVariant { plain, filled, primary }

/// Sizes, mirroring the kit (`base` = [medium], plus `sm`).
enum MxIconButtonSize { medium, small }

/// The kit's icon-only round button for app-bar / toolbar actions
/// (`MxIconButton` · base class `.icon-btn`). A primitive wrapping Material's
/// accessible [IconButton]: real focus + Enter/Space, a real disabled state, and
/// a padded ≥48 tap target even at the small visual size.
///
/// [semanticLabel] is **required** (the kit's `ariaLabel`): an icon-only control
/// must never fall back to the raw glyph name for screen readers. Callers pass a
/// human label from ARB ("Back", "Close", "More options", "Play audio", …). It is
/// surfaced as both the tooltip and the button's semantics label.
class MxIconButton extends StatelessWidget {
  const MxIconButton({
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.variant = MxIconButtonVariant.plain,
    this.size = MxIconButtonSize.medium,
    super.key,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final MxIconButtonVariant variant;
  final MxIconButtonSize size;

  /// Kit `.icon-btn` glyph = 24px (36px variant = 20px). No matching
  /// `MxIconSize` token (18/22/28), so the kit values are named here.
  static const double _glyphMedium = 24;
  static const double _glyphSmall = 20;
  static const double _dimSmall = MxComponentSizes.iconBtnSm;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    final isSmall = size == MxIconButtonSize.small;
    final dim = isSmall ? _dimSmall : MxSpacing.minTouchTarget;
    final glyph = isSmall ? _glyphSmall : _glyphMedium;
    final palette = _palette(mx, scheme);

    return IconButton(
      icon: Icon(icon),
      iconSize: glyph,
      tooltip: semanticLabel,
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(palette.background),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? palette.foreground.withValues(alpha: MxOpacity.disabled)
              : palette.foreground,
        ),
        overlayColor: WidgetStatePropertyAll(mx.stateHover),
        shape: const WidgetStatePropertyAll(CircleBorder()),
        elevation: const WidgetStatePropertyAll(0),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        minimumSize: WidgetStatePropertyAll(Size(dim, dim)),
        fixedSize: WidgetStatePropertyAll(Size(dim, dim)),
      ),
    );
  }

  ({Color background, Color foreground}) _palette(
    MxTheme mx,
    ColorScheme scheme,
  ) {
    return switch (variant) {
      MxIconButtonVariant.plain =>
        (background: Colors.transparent, foreground: scheme.onSurface),
      MxIconButtonVariant.filled =>
        (background: mx.surface, foreground: scheme.onSurface),
      MxIconButtonVariant.primary =>
        (background: mx.primarySoft, foreground: mx.onPrimarySoft),
    };
  }
}
