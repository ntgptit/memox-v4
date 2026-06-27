import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_colors.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/domain/models/deck_node.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';

/// A library/deck row: deck name, recursive "N words" + hidden count, a progress
/// ring, a due badge, and a ⋮ menu. The shared node tile
/// (`docs/design/design-language.md` — `MxNodeTile`).
class MxDeckTile extends StatelessWidget {
  const MxDeckTile({
    super.key,
    required this.node,
    required this.onTap,
    required this.onMenu,
  });

  final DeckNode node;
  final VoidCallback onTap;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = MxTheme.of(context).colors;
    final stats = node.stats;
    return ListTile(
      key: Key('deckTile-${node.deck.id}'),
      onTap: onTap,
      leading: SizedBox(
        width: MxSpacing.space8,
        height: MxSpacing.space8,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            CircularProgressIndicator(
              value: stats.progress,
              backgroundColor: colors.surfaceMuted,
            ),
            Icon(
              Icons.folder_outlined,
              size: MxSpacing.space5,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
      title: Text(node.deck.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Row(
        children: <Widget>[
          Text(l10n.deckWords(stats.words)),
          if (stats.hidden > 0) ...<Widget>[
            const SizedBox(width: MxSpacing.space3),
            Icon(
              Icons.visibility_off_outlined,
              size: MxSpacing.space4,
              color: colors.textTertiary,
            ),
            const SizedBox(width: MxSpacing.space1),
            Text(l10n.deckHiddenCount(stats.hidden)),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (stats.due > 0) _DueBadge(due: stats.due, colors: colors),
          IconButton(
            key: Key('deckMenu-${node.deck.id}'),
            icon: const Icon(Icons.more_vert),
            onPressed: onMenu,
          ),
        ],
      ),
    );
  }
}

class _DueBadge extends StatelessWidget {
  const _DueBadge({required this.due, required this.colors});

  final int due;
  final MxColors colors;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: colors.error,
      borderRadius: MxRadius.pillRadius,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MxSpacing.space2,
        vertical: MxSpacing.space1,
      ),
      child: Text(
        due > 99 ? '99+' : '$due',
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: colors.onError),
      ),
    ),
  );
}
