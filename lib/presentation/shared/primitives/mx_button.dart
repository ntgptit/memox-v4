import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_component.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// Emphasis levels for [MxButton], mirroring the kit `.btn` modifiers.
enum MxButtonVariant { primary, secondary, outline, ghost, contrast }

/// Sizes, mirroring the kit (`base` = [medium], plus `sm`/`lg`).
enum MxButtonSize { small, medium, large }

/// The kit's text button (`MxButton` · base class `.btn`). A primitive: it wraps
/// Material's accessible button widgets — real focus + Enter/Space, a real
/// disabled state (`onPressed: null` doesn't fire), and a padded ≥48 tap target
/// even for the smaller visual — and is styled entirely from design tokens via
/// [MxTheme]. `danger` composes with any variant (a solid error button, per the
/// kit `.btn.danger` rule). [label] copy is supplied by the caller (from ARB).
class MxButton extends StatelessWidget {
  const MxButton({
    required this.label,
    this.onPressed,
    this.variant = MxButtonVariant.primary,
    this.size = MxButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.block = false,
    this.danger = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final MxButtonVariant variant;
  final MxButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool block;
  final bool danger;

  /// Kit `.btn .material-symbols-rounded { font-size: 20px }` — there is no
  /// matching `MxIconSize` token (18/22/28), so the kit value is named here.
  static const double _iconSize = 20;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final metrics = _metrics(size);
    final palette = _palette(mx, scheme);

    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(0, metrics.height)),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: metrics.paddingX),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: MxRadius.controlRadius),
      ),
      elevation: const WidgetStatePropertyAll(0),
      textStyle: WidgetStatePropertyAll(
        TextStyle(
          fontFamily: MxTypography.fontFamily,
          fontSize: metrics.fontSize,
          fontWeight: MxTypography.bold,
        ),
      ),
    );

    final child = _ButtonContent(
      label: label,
      icon: icon,
      trailingIcon: trailingIcon,
      iconSize: _iconSize,
    );

    final button = switch (palette.kind) {
      // Invariant: every _Kind.filled palette is built with a non-null
      // background (see _palette); the field is nullable only for the
      // outlined / text kinds, which take the other switch arms.
      _Kind.filled => FilledButton(
          onPressed: onPressed,
          style: style.copyWith(
            backgroundColor: _stateColor(palette.background!),
            foregroundColor: _stateColor(palette.foreground),
          ),
          child: child,
        ),
      _Kind.outlined => OutlinedButton(
          onPressed: onPressed,
          style: style.copyWith(
            foregroundColor: _stateColor(palette.foreground),
            side: WidgetStatePropertyAll(palette.side),
          ),
          child: child,
        ),
      _Kind.text => TextButton(
          onPressed: onPressed,
          style: style.copyWith(foregroundColor: _stateColor(palette.foreground)),
          child: child,
        ),
    };

    if (!block) return button;
    return SizedBox(width: double.infinity, child: button);
  }

  /// The kit disables via `opacity: 0.45`; mirror it on the resolved color.
  WidgetStateProperty<Color> _stateColor(Color color) =>
      WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? color.withValues(alpha: MxOpacity.disabled)
            : color,
      );

  ({double height, double paddingX, double fontSize}) _metrics(
    MxButtonSize size,
  ) {
    return switch (size) {
      MxButtonSize.small => (
          height: MxSizes.sizeSm,
          paddingX: MxSpacing.space4,
          fontSize: MxTypography.sizeSm,
        ),
      MxButtonSize.medium => (
          height: MxSpacing.minTouchTarget,
          paddingX: MxSpacing.space6,
          fontSize: MxTypography.sizeBase,
        ),
      MxButtonSize.large => (
          height: MxSizes.sizeMd,
          paddingX: MxSpacing.space7,
          fontSize: MxTypography.sizeMd,
        ),
    };
  }

  _Palette _palette(MxTheme mx, ColorScheme scheme) {
    if (danger) {
      return _Palette(_Kind.filled, background: scheme.error, foreground: scheme.onError);
    }
    return switch (variant) {
      MxButtonVariant.primary =>
        _Palette(_Kind.filled, background: scheme.primary, foreground: scheme.onPrimary),
      MxButtonVariant.secondary =>
        _Palette(_Kind.filled, background: mx.primarySoft, foreground: mx.onPrimarySoft),
      MxButtonVariant.contrast =>
        _Palette(_Kind.filled, background: scheme.onPrimary, foreground: scheme.primary),
      MxButtonVariant.outline => _Palette(
          _Kind.outlined,
          foreground: scheme.onSurface,
          side: BorderSide(color: mx.borderStrong, width: 1.5),
        ),
      MxButtonVariant.ghost => _Palette(_Kind.text, foreground: mx.primaryStrong),
    };
  }
}

enum _Kind { filled, outlined, text }

class _Palette {
  const _Palette(this.kind, {this.background, required this.foreground, this.side});

  final _Kind kind;
  final Color? background;
  final Color foreground;
  final BorderSide? side;
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.trailingIcon,
    required this.iconSize,
  });

  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: iconSize),
          const SizedBox(width: MxSpacing.space2),
        ],
        Text(label),
        if (trailingIcon != null) ...[
          const SizedBox(width: MxSpacing.space2),
          Icon(trailingIcon, size: iconSize),
        ],
      ],
    );
  }
}
