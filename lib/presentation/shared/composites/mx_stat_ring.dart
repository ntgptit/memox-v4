import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// The kit's `Ring` + `Stat` helpers combined into one reusable composite: a
/// circular progress ring around a centered value and an optional [label]
/// beneath it (kit: the goal ring is percent-only; the statistics donut adds
/// "accuracy"). Token-driven via [MxTheme]. [percent] is a 0..1 fraction;
/// [color] tints both the ring arc and the value. Copy ([value], [label]) is
/// supplied by the caller (from ARB).
class MxStatRing extends StatelessWidget {
  const MxStatRing({
    required this.percent,
    required this.value,
    this.label,
    this.color,
    this.size = _defaultSize,
    this.strokeWidth = _defaultStroke,
    super.key,
  });

  final double percent;
  final String value;
  final String? label;
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
    final label = this.label;

    return Semantics(
      // a11y label = the caller's already-localized value + label, space-joined
      // (no literal copy of our own — the two are supplied from ARB).
      label: [value, ?label].join(' '),
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
                // No empty label line — it would push the value off-center
                // (kit: the goal ring centers the bare percent).
                if (label != null && label.isNotEmpty) ...[
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
