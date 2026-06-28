import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// Visual treatment for [MxChip].
enum MxChipVariant { accent, ghost }

/// A small selectable tag — the design kit's `MxChip`.
///
/// Purpose:
/// A compact pill for filters, tags, and single-tap toggles.
///
/// Use when:
/// Showing a filter or a selectable label in a row of chips.
///
/// Do not use when:
/// It is a primary action (use MxButton) or a status label (use MxBadge).
///
/// Category:
/// display
///
/// Public API:
/// - label: chip text
/// - icon: optional leading icon
/// - selected: filled selected state
/// - variant: accent (selected = brand) or ghost (outlined)
/// - onTap: tap callback
///
/// States:
/// default, selected
///
/// Variants:
/// accent, ghost
class MxChip extends StatelessWidget {
  const MxChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.variant = MxChipVariant.accent,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final MxChipVariant variant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = MxTheme.of(context).colors;
    final Color background;
    final Color foreground;
    Border? border;
    if (selected) {
      background = colors.primarySoft;
      foreground = colors.onPrimarySoft;
    } else if (variant == MxChipVariant.ghost) {
      background = Colors.transparent;
      foreground = colors.textSecondary;
      border = Border.all(color: colors.borderStrong);
    } else {
      background = colors.surfaceMuted;
      foreground = colors.textSecondary;
    }
    return Material(
      color: background,
      shape: StadiumBorder(side: border?.top ?? BorderSide.none),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MxSpacing.space3,
            vertical: MxSpacing.space2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon case final i?) ...<Widget>[
                Icon(i, size: MxSpacing.space4, color: foreground),
                const SizedBox(width: MxSpacing.space1),
              ],
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
