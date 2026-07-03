import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/presentation/shared/composites/mx_stat_ring.dart';

/// Statistics-local percentage ring (kit `Donut`): a large success-tinted ring
/// with a centered percentage + label. Wraps the shared [MxStatRing]. [percent]
/// is 0..1; [label] copy is from ARB.
class Donut extends StatelessWidget {
  const Donut({required this.percent, required this.label, super.key});

  final double percent;
  final String label;

  static const int _scale = 100;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MxStatRing(
        percent: percent,
        value: '${(percent * _scale).round()}%',
        label: label,
        color: MxTheme.of(context).success,
        size: MxSizes.size2xl,
      ),
    );
  }
}
