import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/presentation/features/statistics/providers/statistics_providers.dart';

/// Statistics-local study calendar (kit `Heatmap`): a 14×7 grid of day cells,
/// tinted by that day's study minutes. [days] is the daily-minutes series
/// (oldest → newest); columns are weeks. Purely presentational (no weekday
/// alignment in v1 — documented gap).
class Heatmap extends StatelessWidget {
  const Heatmap({required this.days, super.key});

  final List<int> days;

  /// Faint tint for a day with no study.
  static const double _emptyOpacity = 0.08;

  /// Minimum tint for any studied day, so a little study still reads.
  static const double _minStudiedOpacity = 0.25;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final max = days.isEmpty ? 1 : days.reduce(math.max);
    final safeMax = max <= 0 ? 1 : max;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var week = 0; week < statsHeatmapWeeks; week++)
            Padding(
              padding: const EdgeInsets.only(right: MxSpacing.space1),
              child: Column(
                children: [
                  for (var day = 0; day < 7; day++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: MxSpacing.space1),
                      child: _cell(primary, _minutesAt(week * 7 + day), safeMax),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  int _minutesAt(int index) => index < days.length ? days[index] : 0;

  Widget _cell(Color primary, int minutes, int max) {
    final opacity = minutes <= 0
        ? _emptyOpacity
        : (_minStudiedOpacity + (1 - _minStudiedOpacity) * (minutes / max))
            .clamp(0.0, 1.0);
    return Container(
      width: MxSizes.sizeXs,
      height: MxSizes.sizeXs,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: opacity),
        borderRadius: const BorderRadius.all(Radius.circular(MxRadius.xs)),
      ),
    );
  }
}
