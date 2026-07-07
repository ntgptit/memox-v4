import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_component.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/deck-detail/providers/deck_detail_providers.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_badge.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_progress_bar.dart';

/// Deck-detail sub-deck row (kit `deck-detail/subdeck-N` · `DeckRow`): a tinted
/// icon tile, the node name + meta + mastery progress, and a due badge. A real
/// accessible button. [tone] is presentational (assigned by the screen). Copy is
/// from ARB (shared library-node keys).
class SubDeckCard extends StatelessWidget {
  const SubDeckCard({
    required this.info,
    required this.tone,
    this.onPressed,
    super.key,
  });

  final SubDeckInfo info;
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
      semanticLabel: info.name,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MxIconTile(
            icon: info.isFolder ? Icons.layers : Icons.style,
            tone: tone,
          ),
          const SizedBox(width: MxSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  info.name,
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
                  _meta(l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: MxTypography.fontFamily,
                    fontSize: MxTypography.sizeSm,
                    color: mx.textSecondary,
                  ),
                ),
                const SizedBox(height: MxSpacing.space2),
                MxProgressBar(value: info.progress),
              ],
            ),
          ),
          const SizedBox(width: MxSpacing.space3),
          // Kit `DeckRow` trailing: a due-count pill when due > 0, otherwise a
          // caught-up/mastered check in a success-soft badge.
          info.due > 0
              ? MxBadge(label: info.due.toString())
              : Container(
                  width: MxComponentSizes.badgeHeight,
                  height: MxComponentSizes.badgeHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: mx.successSoft,
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(Icons.check, size: MxIconSize.sm, color: mx.success),
                ),
        ],
      ),
    );
  }

  String _meta(AppLocalizations l10n) {
    final words = l10n.libraryNodeWords(info.words);
    // Kit meta priority: a folder shows "N decks · N words"; else a fully
    // mastered leaf shows "N words · mastered"; else due; else just words.
    if (info.deckCount > 0) {
      return l10n.libraryNodeMetaDecks(info.deckCount, words);
    }
    if (info.words > 0 && info.progress >= 1) {
      return l10n.libraryNodeMetaMastered(words);
    }
    if (info.due > 0) return l10n.libraryNodeMetaDue(words, info.due);
    return words;
  }
}
