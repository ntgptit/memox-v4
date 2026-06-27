import 'package:flutter/material.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';

/// A chosen node action from the ⋮ menu.
enum DeckAction { rename, move, delete }

/// A move destination: null [parentId] means the top level (root).
class MoveTarget {
  const MoveTarget(this.parentId);

  final int? parentId;
}

/// Bottom-sheet menu for a deck node: rename / move / delete.
Future<DeckAction?> showDeckActions(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<DeckAction>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            key: const Key('deckActionRename'),
            leading: const Icon(Icons.edit_outlined),
            title: Text(l10n.deckRename),
            onTap: () => Navigator.of(ctx).pop(DeckAction.rename),
          ),
          ListTile(
            key: const Key('deckActionMove'),
            leading: const Icon(Icons.drive_file_move_outline),
            title: Text(l10n.deckMove),
            onTap: () => Navigator.of(ctx).pop(DeckAction.move),
          ),
          ListTile(
            key: const Key('deckActionDelete'),
            leading: const Icon(Icons.delete_outline),
            title: Text(l10n.deckDelete),
            onTap: () => Navigator.of(ctx).pop(DeckAction.delete),
          ),
        ],
      ),
    ),
  );
}

/// Prompts for a deck name. `initial` null => create (button "Create"), else
/// rename (button "Rename"). Returns the trimmed name, or null if cancelled/empty.
Future<String?> promptDeckName(
  BuildContext context, {
  required String title,
  String? initial,
}) async {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: initial ?? '');
  String? trimmedOrNull() {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: l10n.deckNameLabel,
          hintText: l10n.deckNameHint,
        ),
        onSubmitted: (_) => Navigator.of(ctx).pop(trimmedOrNull()),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('deckNameSubmit'),
          onPressed: () => Navigator.of(ctx).pop(trimmedOrNull()),
          child: Text(initial == null ? l10n.deckCreate : l10n.deckRename),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}

/// Confirmation for deleting a deck (cascades the subtree — D-024).
Future<bool> confirmDeleteDeck(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.deckDeleteConfirmTitle),
      content: Text(l10n.deckDeleteConfirmBody),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('deckDeleteConfirm'),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l10n.commonDelete),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Picks a move destination: the top level or one of [candidates]. Candidates
/// should already exclude the deck and its subtree (cycle-safe).
Future<MoveTarget?> promptMoveDeck(
  BuildContext context, {
  required List<Deck> candidates,
}) {
  final l10n = AppLocalizations.of(context);
  return showDialog<MoveTarget>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: Text(l10n.deckMoveTitle),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () => Navigator.of(ctx).pop(const MoveTarget(null)),
          child: Text(l10n.deckMoveToRoot),
        ),
        for (final deck in candidates)
          SimpleDialogOption(
            onPressed: () => Navigator.of(ctx).pop(MoveTarget(deck.id)),
            child: Text(deck.name),
          ),
      ],
    ),
  );
}
