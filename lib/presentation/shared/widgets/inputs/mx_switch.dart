import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// An on/off toggle — the design kit's `MxSwitch`.
///
/// Purpose:
/// A brand-colored boolean toggle for settings and inline options.
///
/// Use when:
/// A single setting is on or off.
///
/// Do not use when:
/// There are more than two choices (use MxSegmentedControl).
///
/// Category:
/// input
///
/// Public API:
/// - value: current on/off state
/// - onChanged: change callback (null or disabled turns it off)
/// - disabled: non-interactive
///
/// States:
/// off, on, disabled
class MxSwitch extends StatelessWidget {
  const MxSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.disabled = false,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final colors = MxTheme.of(context).colors;
    return Switch(
      value: value,
      onChanged: disabled ? null : onChanged,
      activeThumbColor: colors.onPrimary,
      activeTrackColor: colors.primary,
      inactiveThumbColor: colors.surface,
      inactiveTrackColor: colors.surfaceSunken,
      trackOutlineColor: WidgetStatePropertyAll<Color>(colors.border),
    );
  }
}
