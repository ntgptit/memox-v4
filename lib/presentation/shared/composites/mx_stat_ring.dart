import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// The kit's `Ring` + `Stat` helpers combined into one reusable composite: a
/// circular progress ring around a centered value + label. Token-driven via
/// [MxTheme]. [percent] is a 0..1 fraction; [color] tints both the ring arc and
/// the value. Copy ([value], [label]) is supplied by the caller (from ARB).
class MxStatRing extends StatelessWidget {
  const MxStatRing({
    required this.percent,
    required this.value,
    required this.label,
    this.color,
    this.size = _defaultSize,
    this.strokeWidth = _defaultStroke,
    super.key,
  });

  final double percent;
  final String value;
  final String label;
  final Color? color;
  final double size;
  final double strokeWidth;

  // Kit `Ring` defaults: size lg (74), inset space-2 (8).
  static const double _defaultSize = MxSizes.sizeLg;
  static const double _defaultStroke = MxSpacing.space2;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ringColor = color ?? scheme.primary;

    return Semantics(
      label: '$value $label',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: percent.clamp(0.0, 1.0),
                strokeWidth: strokeWidth,
                color: ringColor,
                backgroundColor: mx.surfaceSunken,
              ),
            ),
            Container(
              width: size - strokeWidth * 2,
              height: size - strokeWidth * 2,
              decoration: BoxDecoration(color: mx.surface, shape: BoxShape.circle),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxIconSize.md,
                    fontWeight: MxTypography.extrabold,
                    color: color ?? scheme.onSurface,
                  ),
                ),
                const SizedBox(height: MxSpacing.space1),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeXs,
                    color: mx.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
