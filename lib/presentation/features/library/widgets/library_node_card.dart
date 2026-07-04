import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/library/providers/library_providers.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_badge.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_progress_bar.dart';

/// Library-local deck/folder row (kit `library/node-N`): a tinted icon tile, the
/// node name + meta (words · due/hidden/mastered) + mastery progress, and a due
/// badge. The whole card is a real accessible button. The [tone] is presentational
/// (assigned by the screen). Copy is from ARB.
class LibraryNodeCard extends StatelessWidget {
  const LibraryNodeCard({
    required this.node,
    required this.tone,
    this.onPressed,
    super.key,
  });

  final LibraryNode node;
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
      semanticLabel: node.name,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MxIconTile(
            icon: node.isFolder ? Icons.layers : Icons.style,
            tone: tone,
          ),
          const SizedBox(width: MxSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  node.name,
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
                MxProgressBar(value: node.progress),
              ],
            ),
          ),
          if (node.due > 0) ...[
            const SizedBox(width: MxSpacing.space3),
            MxBadge(label: node.due.toString()),
          ],
        ],
      ),
    );
  }

  String _meta(AppLocalizations l10n) {
    final words = l10n.libraryNodeWords(node.words);
    if (node.due > 0) return l10n.libraryNodeMetaDue(words, node.due);
    if (node.hidden > 0) return l10n.libraryNodeMetaHidden(words, node.hidden);
    if (node.isMastered) return l10n.libraryNodeMetaMastered(words);
    return words;
  }
}
