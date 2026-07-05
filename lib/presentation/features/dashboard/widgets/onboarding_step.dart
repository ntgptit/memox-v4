import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';

/// One "How MemoX works" row on the first-run dashboard (kit `dashboard/step-*`):
/// icon tile + title + caption on a small card — the deck-row silhouette without
/// badge/progress, previewing the loaded dashboard's rhythm. Copy is from ARB.
class OnboardingStep extends StatelessWidget {
  const OnboardingStep({
    required this.icon,
    required this.title,
    required this.text,
    this.tone = MxIconTileTone.primary,
    super.key,
  });

  final IconData icon;
  final String title;
  final String text;
  final MxIconTileTone tone;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      padding: MxCardPadding.small,
      child: Row(
        children: [
          MxIconTile(icon: icon, tone: tone),
          const SizedBox(width: MxSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeBase,
                    fontWeight: MxTypography.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: MxSpacing.space1),
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeSm,
                    color: mx.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
