import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// The kit's `ProgressBar` helper as a reusable primitive: a rounded determinate
/// bar on a sunken track. Token-driven via [MxTheme]; wraps Material's
/// [LinearProgressIndicator] for built-in progress semantics.
///
/// [value] is a 0..1 fraction (clamped). [color] overrides the primary fill (pass
/// a token colour, e.g. a semantic role). [semanticLabel] names the bar for
/// screen readers.
class MxProgressBar extends StatelessWidget {
  const MxProgressBar({
    required this.value,
    this.color,
    this.height = _defaultHeight,
    this.semanticLabel,
    super.key,
  });

  final double value;
  final Color? color;
  final double height;
  final String? semanticLabel;

  /// Kit `ProgressBar` default height (8px) — no matching size token.
  static const double _defaultHeight = 8;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return LinearProgressIndicator(
      value: value.clamp(0.0, 1.0),
      minHeight: height,
      backgroundColor: mx.surfaceSunken,
      color: color ?? scheme.primary,
      borderRadius: MxRadius.pillRadius,
      semanticsLabel: semanticLabel,
    );
  }
}
