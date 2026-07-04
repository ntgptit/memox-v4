import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/dashboard/providers/dashboard_providers.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_badge.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_progress_bar.dart';

/// Dashboard-local due-deck row (kit `dashboard/deck-N`): a tinted icon tile, the
/// deck name + due meta + mastery progress, and a due badge. The whole card is a
/// real accessible button (via [MxCard.onPressed]) navigating to the deck. The
/// [icon] + [tone] are presentational (the deck entity has none, D-… gap) —
/// assigned by the screen. Copy is from ARB.
class ContinueDeckCard extends StatelessWidget {
  const ContinueDeckCard({
    required this.deck,
    required this.icon,
    required this.tone,
    this.onPressed,
    super.key,
  });

  final DashboardDeck deck;
  final IconData icon;
  final MxIconTileTone tone;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      padding: MxCardPadding.small,
      onPressed: onPressed,
      semanticLabel: deck.name,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MxIconTile(icon: icon, tone: tone),
          const SizedBox(width: MxSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  deck.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeBase,
                    fontWeight: MxTypography.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: MxSpacing.space1),
                Text(
                  l10n.dashboardDeckMeta(deck.cardCount, deck.dueCount),
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeSm,
                    color: mx.textSecondary,
                  ),
                ),
                const SizedBox(height: MxSpacing.space2),
                MxProgressBar(value: deck.progress),
              ],
            ),
          ),
          const SizedBox(width: MxSpacing.space3),
          MxBadge(label: deck.dueCount.toString()),
        ],
      ),
    );
  }
}
