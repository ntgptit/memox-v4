import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';

/// Study-session local (kit `ResumeErrorState`): the full-screen surface when the
/// session can't be built/resumed. Owns its own app bar (no progress bar here).
/// Copy is from ARB.
class ResumeErrorState extends StatelessWidget {
  const ResumeErrorState({this.onRestart, this.onBack, super.key});

  final VoidCallback? onRestart;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: MxAppBar(
        title: l10n.studyResumeTitle,
        leading: MxIconButton(
          icon: Icons.close,
          semanticLabel: l10n.studyClose,
          onPressed: onBack,
        ),
      ),
      children: [
        SizedBox(
          height: MxSizes.size4xl,
          child: MxEmptyState(
            icon: Icons.play_disabled,
            tone: MxIconTileTone.error,
            title: l10n.studyResumeErrorTitle,
            text: l10n.studyResumeErrorText,
            action: SizedBox(
              width: MxSizes.size3xl,
              child: Column(
                children: [
                  MxButton(
                    label: l10n.studyResumeRestart,
                    icon: Icons.refresh,
                    block: true,
                    onPressed: onRestart,
                  ),
                  const SizedBox(height: MxSpacing.space3),
                  MxButton(
                    label: l10n.studyResumeBack,
                    variant: MxButtonVariant.ghost,
                    block: true,
                    onPressed: onBack,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
