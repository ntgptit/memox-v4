import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';

/// Player-local (kit `player/card`): the current term + meaning being read
/// aloud, separated by a short rule.
class PlayerCard extends StatelessWidget {
  const PlayerCard({required this.term, required this.meaning, super.key});

  final String term;
  final String meaning;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      child: Container(
        constraints: const BoxConstraints(minHeight: MxSizes.size4xl),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              term,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: MxTypography.fontFamily,
                fontSize: MxTypography.size4xl,
                fontWeight: MxTypography.extrabold,
                letterSpacing: MxTypography.size4xl * MxTypography.trackingTight,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: MxSpacing.space4),
            Container(
              width: MxSizes.sizeMd,
              height: MxSizes.size3xs,
              decoration: BoxDecoration(
                color: mx.divider,
                borderRadius:
                    const BorderRadius.all(Radius.circular(MxRadius.xs)),
              ),
            ),
            const SizedBox(height: MxSpacing.space4),
            Text(
              meaning,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: MxTypography.fontFamily,
                fontSize: MxTypography.size2xl,
                fontWeight: MxTypography.bold,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
