import 'package:flutter/material.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_confirm_dialog.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';

/// Drawer-local remove-pair confirm (kit `drawer/remove-dialog`). Composes the
/// shared [showMxConfirmDialog]; resolves to `true` when the learner confirms.
/// Copy is from ARB.
Future<bool> showRemoveLanguageDialog(
  BuildContext context, {
  required String pairLabel,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showMxConfirmDialog<bool>(
    context: context,
    icon: Icons.delete,
    tone: MxDialogTone.error,
    title: l10n.drawerRemovePairTitle(pairLabel),
    text: l10n.drawerRemovePairText,
    actions: [
      MxButton(
        label: l10n.actionCancel,
        variant: MxButtonVariant.ghost,
        block: true,
        onPressed: () => Navigator.of(context).pop(false),
      ),
      MxButton(
        label: l10n.drawerRemoveAction,
        danger: true,
        block: true,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    ],
  );
  return confirmed ?? false;
}
