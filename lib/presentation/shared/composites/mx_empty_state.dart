import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';

/// The kit's `EmptyState` helper as a reusable composite: a centered large icon
/// tile above a title + body, with an optional action. Token-driven via
/// [MxTheme]; composes [MxIconTile]. Copy + action are supplied by the caller
/// (from ARB). Place it inside an [Expanded]/[Center] so it fills the empty area.
class MxEmptyState extends StatelessWidget {
  const MxEmptyState({
    required this.icon,
    required this.title,
    required this.text,
    this.tone = MxIconTileTone.primary,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String text;
  final MxIconTileTone tone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: MxSpacing.space8,
          horizontal: MxSpacing.space4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: MxSpacing.space4,
          children: [
            MxIconTile(icon: icon, tone: tone, size: MxIconTileSize.large),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: MxSizes.size3xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: MxSpacing.space2,
                children: [
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
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: MxTypography.fontFamily,
                      fontSize: MxTypography.sizeBase,
                      height: MxTypography.lineHeightNormal,
                      color: mx.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            ?action,
          ],
        ),
      ),
    );
  }
}
