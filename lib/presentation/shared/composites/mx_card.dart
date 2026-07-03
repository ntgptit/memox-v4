import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// Surface treatment for [MxCard] (`elevated` is the base).
enum MxCardVariant { elevated, flat, muted, primary, primarySoft }

/// Padding step for [MxCard] (`medium` is the base).
enum MxCardPadding { small, medium, large }

/// The kit's primary content surface (`MxCard` · base class `.card`): a rounded,
/// token-styled container with elevated / flat / muted / primary / primary-soft
/// variants. A composite (composes token styling around arbitrary [child]
/// content); token-driven via [MxTheme].
///
/// Passing [onPressed] makes the card actionable — a real accessible button
/// (focus + Enter/Space + ripple), matching the kit's `interactive` affordance.
class MxCard extends StatelessWidget {
  const MxCard({
    required this.child,
    this.variant = MxCardVariant.elevated,
    this.padding = MxCardPadding.medium,
    this.onPressed,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final MxCardVariant variant;
  final MxCardPadding padding;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final style = _resolve(mx, scheme);

    final content = Padding(
      padding: EdgeInsets.all(_paddingValue),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: style.foreground),
        child: IconTheme.merge(
          data: IconThemeData(color: style.foreground),
          child: child,
        ),
      ),
    );

    final border = style.bordered
        ? Border.all(color: mx.border, width: MxStroke.hairline)
        : null;

    if (onPressed == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: MxRadius.cardRadius,
          boxShadow: style.shadow,
          border: border,
        ),
        child: content,
      );
    }

    return Semantics(
      button: true,
      label: semanticLabel,
      child: DecoratedBox(
        // Shadow + border paint outside the ripple-clipping Material.
        decoration: BoxDecoration(
          borderRadius: MxRadius.cardRadius,
          boxShadow: style.shadow,
          border: border,
        ),
        child: Material(
          color: style.background,
          borderRadius: MxRadius.cardRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(onTap: onPressed, child: content),
        ),
      ),
    );
  }

  double get _paddingValue => switch (padding) {
        MxCardPadding.small => MxSpacing.space4,
        MxCardPadding.medium => MxSpacing.space5,
        MxCardPadding.large => MxSpacing.space6,
      };

  _CardStyle _resolve(MxTheme mx, ColorScheme scheme) {
    return switch (variant) {
      MxCardVariant.elevated => _CardStyle(
          background: mx.surface,
          foreground: scheme.onSurface,
          shadow: mx.shadows.card,
        ),
      MxCardVariant.flat => _CardStyle(
          background: mx.surface,
          foreground: scheme.onSurface,
          bordered: true,
        ),
      MxCardVariant.muted => _CardStyle(
          background: mx.surfaceMuted,
          foreground: scheme.onSurface,
        ),
      MxCardVariant.primary => _CardStyle(
          background: scheme.primary,
          foreground: scheme.onPrimary,
          shadow: mx.shadows.fab,
        ),
      MxCardVariant.primarySoft => _CardStyle(
          background: mx.primarySoft,
          foreground: mx.onPrimarySoft,
        ),
    };
  }
}

class _CardStyle {
  const _CardStyle({
    required this.background,
    required this.foreground,
    this.shadow,
    this.bordered = false,
  });

  final Color background;
  final Color foreground;
  final List<BoxShadow>? shadow;
  final bool bordered;
}
