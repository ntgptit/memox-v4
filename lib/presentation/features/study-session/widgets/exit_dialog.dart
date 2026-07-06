import 'package:flutter/material.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_confirm_dialog.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';

/// Study-session local (kit `ExitDialog`): the leave-session confirm. Presented
/// via [showMxConfirmDialog]; returns `true` when the learner chooses to leave.
/// Copy is from ARB.
abstract final class ExitDialog {
  static Future<bool?> show(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return showMxConfirmDialog<bool>(
      context: context,
      icon: Icons.logout,
      tone: MxDialogTone.error,
      title: l10n.studyExitTitle,
      text: l10n.studyExitText,
      barrierLabel: l10n.studyExitTitle,
      actions: [
        MxButton(
          label: l10n.studyExitStay,
          variant: MxButtonVariant.ghost,
          block: true,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        MxButton(
          label: l10n.studyExitLeave,
          danger: true,
          block: true,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
