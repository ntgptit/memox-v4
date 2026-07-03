import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';

/// Game-picker local card-source selector (kit `ScopeCard`): opens the source
/// sheet. Shows the current source label. Copy is from ARB.
class ScopeCard extends StatelessWidget {
  const ScopeCard({required this.sourceLabel, this.onPressed, super.key});

  final String sourceLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      padding: MxCardPadding.small,
      onPressed: onPressed,
      semanticLabel: l10n.gamePickerSourceLabel,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const MxIconTile(icon: Icons.tune, tone: MxIconTileTone.success),
          const SizedBox(width: MxSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.gamePickerSourceLabel,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeBase,
                    fontWeight: MxTypography.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: MxSpacing.space1),
                Text(
                  sourceLabel,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeSm,
                    color: mx.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.expand_more, color: mx.textTertiary),
        ],
      ),
    );
  }
}
