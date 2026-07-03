import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// Style for [MxChip] beyond the default outlined chip.
enum MxChipVariant { standard, accent, ghost }

/// The kit's filter / choice chip (`MxChip` · base class `.chip`): outlined by
/// default, tinted when [selected]. A primitive wrapping Material for real focus +
/// tap + toggle semantics; token-driven via [MxTheme]. `accent` / `ghost` are
/// distinct styles that take precedence over [selected].
class MxChip extends StatelessWidget {
  const MxChip({
    required this.label,
    this.onPressed,
    this.icon,
    this.selected = false,
    this.variant = MxChipVariant.standard,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool selected;
  final MxChipVariant variant;

  /// Kit `.chip` height — raw px with no matching token.
  static const double _height = 34;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final resolved = _resolve(mx, scheme);

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: resolved.background,
        shape: StadiumBorder(
          side: resolved.bordered
              ? BorderSide(color: mx.border, width: MxStroke.hairline)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          hoverColor: mx.stateHover,
          child: SizedBox(
            height: _height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: MxSpacing.space4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: MxIconSize.sm, color: resolved.foreground),
                    const SizedBox(width: MxSpacing.space2),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: MxTypography.fontFamily,
                      fontSize: MxTypography.sizeSm,
                      fontWeight: MxTypography.semibold,
                      color: resolved.foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ({Color background, Color foreground, bool bordered}) _resolve(
    MxTheme mx,
    ColorScheme scheme,
  ) {
    return switch (variant) {
      MxChipVariant.accent => (
          background: mx.accentSoft,
          foreground: scheme.onSecondary,
          bordered: false,
        ),
      MxChipVariant.ghost => (
          background: Colors.transparent,
          foreground: mx.textSecondary,
          bordered: true,
        ),
      MxChipVariant.standard when selected => (
          background: mx.primarySoft,
          foreground: mx.onPrimarySoft,
          bordered: false,
        ),
      MxChipVariant.standard => (
          background: mx.surface,
          foreground: mx.textSecondary,
          bordered: true,
        ),
    };
  }
}
