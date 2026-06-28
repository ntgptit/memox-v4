import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final colors = MxTheme.of(context).colors;
    final background = accent ? colors.accent : colors.primary;
    final foreground = accent ? colors.onAccent : colors.onPrimary;
    final extended = label != null && !round;
    if (extended) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: background,
        foregroundColor: foreground,
        icon: Icon(icon),
        label: Text(label!),
      );
    }
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: background,
      foregroundColor: foreground,
      child: Icon(icon),
    );
  }
}
