import 'package:flutter/material.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/library/providers/library_providers.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';

/// Library-local per-deck launcher (kit `library/play-sheet`) — the content of an
/// [showMxSheet] whose title is the deck name. Learn · Review · Browse · Game ·
/// Player. Each item dismisses the sheet before navigating. Copy is from ARB.
class PlaySheet extends StatelessWidget {
  const PlaySheet({
    required this.node,
    required this.onLearn,
    required this.onReview,
    required this.onBrowse,
    required this.onGame,
    required this.onPlayer,
    super.key,
  });

  final LibraryNode node;
  final VoidCallback onLearn;
  final VoidCallback onReview;
  final VoidCallback onBrowse;
  final VoidCallback onGame;
  final VoidCallback onPlayer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget item(IconData icon, String label, VoidCallback action,
        {bool last = false}) {
      return MxListRow(
        icon: icon,
        title: label,
        last: last,
        onPressed: () {
          Navigator.of(context).pop();
          action();
        },
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        item(Icons.school, l10n.librarySheetLearn, onLearn),
        item(Icons.replay, l10n.librarySheetReview(node.due), onReview),
        item(Icons.visibility, l10n.librarySheetBrowse, onBrowse),
        item(Icons.sports_esports, l10n.librarySheetGame, onGame),
        item(Icons.play_circle, l10n.librarySheetPlayer, onPlayer, last: true),
      ],
    );
  }
}
