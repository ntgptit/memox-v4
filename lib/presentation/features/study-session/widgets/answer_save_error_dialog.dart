import 'package:flutter/material.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/confirm_dialog.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';

/// The action the learner chose on the answer-save-error dialog.
enum AnswerSaveErrorChoice { back, retry }

/// Study-session local (kit `AnswerSaveErrorDialog`): shown when a grade /
/// graduation write fails, so the review schedule stays correct. Presented via
/// [showMxConfirmDialog]. Copy is from ARB.
abstract final class AnswerSaveErrorDialog {
  static Future<AnswerSaveErrorChoice?> show(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return showMxConfirmDialog<AnswerSaveErrorChoice>(
      context: context,
      icon: Icons.sync_problem,
      tone: MxDialogTone.error,
      title: l10n.studySaveErrorTitle,
      text: l10n.studySaveErrorText,
      barrierLabel: l10n.studySaveErrorTitle,
      actions: [
        MxButton(
          label: l10n.studySaveErrorBack,
          variant: MxButtonVariant.ghost,
          block: true,
          onPressed: () =>
              Navigator.of(context).pop(AnswerSaveErrorChoice.back),
        ),
        MxButton(
          label: l10n.studySaveErrorRetry,
          icon: Icons.refresh,
          block: true,
          onPressed: () =>
              Navigator.of(context).pop(AnswerSaveErrorChoice.retry),
        ),
      ],
    );
  }
}
