import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/deck-detail/providers/deck_detail_providers.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';
import 'package:memox_v4/presentation/shared/composites/mx_sheet.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';

/// Opens the kit `Move to` sheet (DeckDetail.jsx `move`) for [data]'s deck: a
/// radio list of valid parents — Library (root) + every OTHER root deck — plus
/// the current deck and its sub-decks shown MUTED as context (a deck can't move
/// into itself or a descendant). [onMove] receives the chosen parent (null =
/// library root) when the user confirms with the primary Move button.
void showMoveSheet({
  required BuildContext context,
  required WidgetRef ref,
  required DeckDetailData data,
  required ValueChanged<DeckId?> onMove,
}) {
  final l10n = AppLocalizations.of(context);
  final roots = ref.read(rootDecksProvider).value ?? const [];
  final destinations = <MoveDestination>[
    MoveDestination(icon: Icons.home, label: l10n.deckDetailMoveRoot),
    for (final root in roots)
      if (root.id.value != data.deckId.value)
        MoveDestination(icon: Icons.layers, label: root.name, targetId: root.id),
    MoveDestination(
      icon: Icons.layers,
      label: l10n.deckDetailMoveCurrent(data.deckName),
      muted: true,
    ),
    for (final sub in data.subDecks)
      MoveDestination(
        icon: Icons.style,
        label: l10n.deckDetailMoveSubdeck(sub.name),
        muted: true,
      ),
  ];
  showMxSheet<void>(
    context: context,
    title: l10n.deckDetailMoveTitle,
    child: _MoveSheet(destinations: destinations, onMove: onMove),
  );
}

/// A single row in the [_MoveSheet] — a valid parent ([targetId] = null means the
/// library root), or a MUTED context row (the current deck / its sub-decks, which
/// can't be a destination).
class MoveDestination {
  const MoveDestination({
    required this.icon,
    required this.label,
    this.targetId,
    this.muted = false,
  });

  final IconData icon;
  final String label;
  final DeckId? targetId;
  final bool muted;
}

/// The kit's `Move to` sheet body: a radio list of destinations + a primary
/// `Move` button (select-then-confirm). Rows are [MxListRow] (icon tile + title +
/// trailing radio); muted rows carry no radio and aren't selectable. The picked
/// row lives in [moveSelectionProvider] (Riverpod owns the transient state).
class _MoveSheet extends ConsumerWidget {
  const _MoveSheet({required this.destinations, required this.onMove});

  final List<MoveDestination> destinations;
  final ValueChanged<DeckId?> onMove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mx = MxTheme.of(context);
    final selected = ref.watch(moveSelectionProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < destinations.length; i++)
          _row(ref, destinations[i], i, selected == i, mx),
        const SizedBox(height: MxSpacing.space2),
        MxButton(
          label: l10n.actionMove,
          block: true,
          onPressed: () {
            final index = ref.read(moveSelectionProvider);
            if (index == null) return;
            Navigator.of(context).pop();
            onMove(destinations[index].targetId);
          },
        ),
      ],
    );
  }

  Widget _row(WidgetRef ref, MoveDestination d, int index, bool isSelected,
      MxTheme mx) {
    if (d.muted) {
      return MxListRow(icon: d.icon, title: d.label, muted: true);
    }
    return MxListRow(
      icon: d.icon,
      title: d.label,
      trailing: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        size: MxIconSize.md,
        color: isSelected ? mx.primaryStrong : mx.textTertiary,
      ),
      onPressed: () => ref.read(moveSelectionProvider.notifier).select(index),
    );
  }
}
