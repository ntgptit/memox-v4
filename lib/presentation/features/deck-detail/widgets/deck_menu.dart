import 'package:flutter/material.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';

/// Deck-detail deck-level actions (kit `deck-detail/deck-sheet`) — the content of
/// an [showMxSheet] titled with the deck name. Move · Delete deck. The kit's
/// Rename (inline text dialog) and Reset progress (no v1 use case) items are
/// omitted (documented gaps). Each item dismisses the sheet before acting.
class DeckMenu extends StatelessWidget {
  const DeckMenu({required this.onMove, required this.onDelete, super.key});

  final VoidCallback onMove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MxListRow(
          icon: Icons.drive_file_move,
          title: l10n.deckDetailDeckMove,
          onPressed: () {
            Navigator.of(context).pop();
            onMove();
          },
        ),
        MxListRow(
          icon: Icons.delete,
          tone: MxIconTileTone.error,
          title: l10n.deckDetailDeckDelete,
          last: true,
          onPressed: () {
            Navigator.of(context).pop();
            onDelete();
          },
        ),
      ],
    );
  }
}
