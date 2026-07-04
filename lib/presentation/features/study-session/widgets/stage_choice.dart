import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/study-session/widgets/prompt_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_action_callout.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_choice_option.dart';

/// Study-session local (kit `StageChoice`): stage 3 / relearn — a prompt term and
/// meaning choices. A wrong pick shows the not-counted relearn note. Copy is from
/// ARB.
class StageChoice extends StatelessWidget {
  const StageChoice({
    required this.term,
    required this.choices,
    required this.correctChoice,
    required this.chosen,
    required this.wrong,
    this.onChoose,
    super.key,
  });

  final String term;
  final List<String> choices;
  final int correctChoice;
  final int? chosen;
  final bool wrong;
  final ValueChanged<int>? onChoose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (wrong) ...[
          MxActionCallout(icon: Icons.replay, text: l10n.studyRelearnNote),
          const SizedBox(height: MxSpacing.space4),
        ],
        PromptCard(term: term),
        const SizedBox(height: MxSpacing.space4),
        for (final (index, choice) in choices.indexed) ...[
          MxChoiceOption(
            text: choice,
            tone: _tone(index),
            onPressed: onChoose == null ? null : () => onChoose!(index),
          ),
          if (index < choices.length - 1)
            const SizedBox(height: MxSpacing.space3),
        ],
      ],
    );
  }

  MxChoiceTone _tone(int index) {
    if (!wrong) return MxChoiceTone.none;
    if (index == chosen) return MxChoiceTone.wrong;
    return MxChoiceTone.none;
  }
}
