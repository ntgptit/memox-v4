import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// A floating action button — the design kit's `MxFab`.
///
/// Purpose:
/// The primary screen action, parked above the bottom navigation; round or
/// extended (with a label).
///
/// Use when:
/// A screen has one dominant create/add action.
///
/// Do not use when:
/// The action is inline or secondary (use MxButton / MxIconButton).
///
/// Category:
/// navigation
///
/// Public API:
/// - icon: the action icon
/// - label: extended-FAB label (omit for a round FAB)
/// - onPressed: tap callback
/// - accent: use the accent color instead of primary
/// - round: force the round shape even with a label
///
/// States:
/// default, pressed
///
/// Variants:
/// round, extended
class MxFab extends StatelessWidget {
  const MxFab({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.accent = false,
    this.round = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? label;
  final bool accent;
  final bool round;

  /// Extended-FAB corner radius — mirrors the CSS `.fab` `--memox-radius-xl`.
  static const BorderRadius _extendedRadius = BorderRadius.all(
    Radius.circular(MxRadius.xl),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = MxTheme.of(context).colors;
    final background = accent ? colors.accent : colors.primary;
    final foreground = accent ? colors.onAccent : colors.onPrimary;
    final extended = label != null && !round;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, size: MxSpacing.space6, color: foreground),
        if (extended) ...<Widget>[
          const SizedBox(width: MxSpacing.space2),
          Text(
            label!,
            style: theme.textTheme.labelLarge?.copyWith(color: foreground),
          ),
        ],
      ],
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: extended ? _extendedRadius : MxRadius.pillRadius,
        boxShadow: MxTheme.of(context).shadows.fab,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: extended ? _extendedRadius : MxRadius.pillRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          // ConstrainedBox enforces a square minimum; Align with a width/height
          // factor of 1 hugs the content (centered) so the FAB never stretches
          // to fill the bounded constraints the Scaffold gives its FAB slot.
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: MxSpacing.fabSize,
              minHeight: MxSpacing.fabSize,
              maxHeight: MxSpacing.fabSize,
            ),
            child: Align(
              widthFactor: 1,
              heightFactor: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: extended ? MxSpacing.space5 : MxSpacing.space0,
                ),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
