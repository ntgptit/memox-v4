import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// The kit's binary on/off toggle (`MxSwitch` · base class `.switch`). A
/// primitive wrapping Material's [Switch] — `role=switch`, toggled semantics,
/// focus, and a real disabled state — styled from tokens via [MxTheme].
///
/// Passing a null [onChanged] disables the control (won't toggle, dimmed to the
/// kit's 0.45). [semanticLabel] is the kit's `ariaLabel`: a switch has no visible
/// text, so callers should pass an accessible name from ARB.
class MxSwitch extends StatelessWidget {
  const MxSwitch({
    required this.value,
    this.onChanged,
    this.semanticLabel,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  /// Kit `.switch` track outline = 1.5px, between the hairline (1) and emphasis
  /// (2) stroke tokens, so the kit value is named here.
  static const double _trackOutlineWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    Color onOff(Set<WidgetState> states, Color on, Color off) =>
        states.contains(WidgetState.selected) ? on : off;

    final control = Switch(
      value: value,
      onChanged: onChanged,
      // 48px tap target regardless of platform default (M3-1); the 52x32
      // visual (kit .switch) is unchanged.
      materialTapTargetSize: MaterialTapTargetSize.padded,
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => onOff(states, scheme.onPrimary, mx.textTertiary),
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => onOff(states, scheme.primary, mx.surfaceSunken),
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => onOff(states, Colors.transparent, mx.border),
      ),
      trackOutlineWidth: const WidgetStatePropertyAll(_trackOutlineWidth),
    );

    final labeled = Semantics(label: semanticLabel, child: control);
    if (onChanged != null) return labeled;
    // Kit `.switch--disabled { opacity: 0.45 }`.
    return Opacity(opacity: 0.45, child: labeled);
  }
}
