import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// Statistics-local vertical bar chart (kit `Bars`): one bar per value, scaled to
/// the max, with an axis label beneath. Used by the weekly-time + Leitner charts.
/// [color] overrides the bar fill (a token colour). Labels are supplied by the
/// caller.
class Bars extends StatelessWidget {
  const Bars({required this.data, required this.labels, this.color, super.key});

  final List<int> data;
  final List<String> labels;
  final Color? color;

  /// Bar area height (kit `size-2xl`).
  static const double _barAreaHeight = MxSizes.size2xl;

  /// Smallest visible bar fraction, so a zero/tiny value still reads as a bar.
  static const double _minFraction = 0.03;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final fill = color ?? scheme.primary;
    final max = data.isEmpty ? 1 : data.reduce(math.max);
    final safeMax = max <= 0 ? 1 : max;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final (index, value) in data.indexed)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: _barAreaHeight,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      widthFactor: 1,
                      heightFactor:
                          math.max(value / safeMax, _minFraction).clamp(0.0, 1.0),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: MxSpacing.space1,
                        ),
                        decoration: BoxDecoration(
                          color: fill,
                          borderRadius: const BorderRadius.all(Radius.circular(MxRadius.xs)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: MxSpacing.space1),
                Text(
                  index < labels.length ? labels[index] : '',
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeXs,
                    color: mx.textTertiary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
