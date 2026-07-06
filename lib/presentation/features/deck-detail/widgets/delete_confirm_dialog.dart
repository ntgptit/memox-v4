import 'package:flutter/material.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_confirm_dialog.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';

/// Deck-detail delete-a-card confirm (kit `deck-detail/delete-dialog`). Composes
/// the shared [showMxConfirmDialog]; resolves to `true` when the learner
/// confirms. Copy is from ARB.
Future<bool> showDeleteCardDialog(
  BuildContext context, {
  required String term,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showMxConfirmDialog<bool>(
    context: context,
    icon: Icons.delete,
    tone: MxDialogTone.error,
    title: l10n.deckDetailDeleteCardTitle,
    text: l10n.deckDetailDeleteCardText(term),
    actions: [
      MxButton(
        label: l10n.actionCancel,
        variant: MxButtonVariant.ghost,
        block: true,
        onPressed: () => Navigator.of(context).pop(false),
      ),
      MxButton(
        label: l10n.actionDelete,
        danger: true,
        block: true,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    ],
  );
  return confirmed ?? false;
}

/// Deck-detail delete-a-deck confirm (kit `deck-detail/deck-delete-dialog`).
/// Resolves to `true` when the learner confirms. Copy is from ARB.
Future<bool> showDeleteDeckDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showMxConfirmDialog<bool>(
    context: context,
    icon: Icons.delete,
    tone: MxDialogTone.error,
    title: l10n.deckDetailDeleteDeckTitle,
    text: l10n.deckDetailDeleteDeckText,
    actions: [
      MxButton(
        label: l10n.actionCancel,
        variant: MxButtonVariant.ghost,
        block: true,
        onPressed: () => Navigator.of(context).pop(false),
      ),
      MxButton(
        label: l10n.actionDelete,
        danger: true,
        block: true,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    ],
  );
  return confirmed ?? false;
}

/// Deck-detail reset-deck-progress confirm (kit `deck-detail/reset-dialog`).
/// Returns every card in the deck to New (box 0) so the deck re-enters the learn
/// flow — a recoverable action (warning tone, not danger). Resolves to `true`
/// when the learner confirms. Copy is from ARB.
Future<bool> showResetProgressDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showMxConfirmDialog<bool>(
    context: context,
    icon: Icons.restart_alt,
    tone: MxDialogTone.error,
    title: l10n.deckDetailResetProgressTitle,
    text: l10n.deckDetailResetProgressText,
    actions: [
      MxButton(
        label: l10n.actionCancel,
        variant: MxButtonVariant.ghost,
        block: true,
        onPressed: () => Navigator.of(context).pop(false),
      ),
      MxButton(
        label: l10n.actionReset,
        danger: true,
        block: true,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    ],
  );
  return confirmed ?? false;
}
