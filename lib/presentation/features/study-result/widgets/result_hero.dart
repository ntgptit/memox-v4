import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';

/// Study-result local (kit `ResultHero`): a large icon tile above a title +
/// subtitle. Shared by the summary and the finalizing view. Copy is from ARB.
class ResultHero extends StatelessWidget {
  const ResultHero({
    required this.icon,
    required this.tone,
    required this.title,
    required this.text,
    super.key,
  });

  final IconData icon;
  final MxIconTileTone tone;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: MxSpacing.space4),
      child: Column(
        children: [
          MxIconTile(icon: icon, tone: tone, size: MxIconTileSize.large),
          const SizedBox(height: MxSpacing.space3),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: MxTypography.fontFamily,
              fontSize: MxTypography.sizeLg,
              fontWeight: MxTypography.extrabold,
              letterSpacing: MxTypography.sizeLg * MxTypography.trackingTight,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: MxSpacing.space1),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: MxSizes.size4xl),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: MxTypography.fontFamily,
                fontSize: MxTypography.sizeBase,
                color: mx.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
