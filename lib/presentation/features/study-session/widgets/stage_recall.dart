import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/study-session/widgets/prompt_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';

/// Study-session local (kit `StageRecall`): stage 4 — recall the meaning, tap
/// Show to reveal it, then advance. Copy is from ARB.
class StageRecall extends StatelessWidget {
  const StageRecall({
    required this.term,
    required this.meaning,
    required this.revealed,
    this.onReveal,
    this.onNext,
    super.key,
  });

  final String term;
  final String meaning;
  final bool revealed;
  final VoidCallback? onReveal;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PromptCard(term: term),
        const SizedBox(height: MxSpacing.space4),
        MxCard(
          child: Container(
            constraints: const BoxConstraints(minHeight: MxSizes.sizeXl),
            alignment: Alignment.center,
            child: Text(
              revealed ? meaning : l10n.studyRecallHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: MxTypography.fontFamily,
                fontSize: revealed ? MxTypography.size2xl : MxTypography.sizeBase,
                fontWeight: revealed ? MxTypography.bold : MxTypography.semibold,
                color: revealed ? scheme.onSurface : mx.textTertiary,
              ),
            ),
          ),
        ),
        const SizedBox(height: MxSpacing.space5),
        if (revealed)
          MxButton(
            label: l10n.studyNext,
            icon: Icons.arrow_forward,
            size: MxButtonSize.large,
            block: true,
            onPressed: onNext,
          )
        else
          MxButton(
            label: l10n.studyReveal,
            icon: Icons.visibility,
            size: MxButtonSize.large,
            block: true,
            onPressed: onReveal,
          ),
      ],
    );
  }
}
