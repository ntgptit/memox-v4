import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_radius.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/study-session/widgets/prompt_card.dart';
import 'package:memox_v4/presentation/shared/composites/action_callout.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';

/// Study-session local (kit `StageTyping`): stage 5 — the meaning is prompted;
/// type the term and check. Help reveals a hint. Copy is from ARB.
class StageTyping extends StatelessWidget {
  const StageTyping({
    required this.meaningLabel,
    required this.meaning,
    required this.controller,
    required this.hintShown,
    required this.hint,
    this.onHint,
    this.onCheck,
    super.key,
  });

  final String meaningLabel;
  final String meaning;
  final TextEditingController controller;
  final bool hintShown;
  final String hint;
  final VoidCallback? onHint;
  final VoidCallback? onCheck;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PromptCard(term: meaning, sub: meaningLabel),
        const SizedBox(height: MxSpacing.space4),
        Container(
          constraints: const BoxConstraints(minHeight: MxSizes.sizeMd),
          padding: const EdgeInsets.all(MxSpacing.space4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: mx.surface,
            borderRadius: MxRadius.controlRadius,
            border: Border.all(color: mx.divider, width: MxStroke.hairline),
          ),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            onSubmitted: (_) => onCheck?.call(),
            style: TextStyle(
              fontFamily: MxTypography.fontFamily,
              fontSize: MxTypography.size2xl,
              fontWeight: MxTypography.extrabold,
              color: scheme.onSurface,
            ),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: l10n.studyTypePlaceholder,
              hintStyle: TextStyle(
                fontFamily: MxTypography.fontFamily,
                fontSize: MxTypography.sizeBase,
                fontWeight: MxTypography.semibold,
                color: mx.textTertiary,
              ),
            ),
          ),
        ),
        if (hintShown) ...[
          const SizedBox(height: MxSpacing.space3),
          MxActionCallout(icon: Icons.lightbulb, text: hint),
        ],
        const SizedBox(height: MxSpacing.space4),
        Row(
          children: [
            Expanded(
              child: MxButton(
                label: l10n.studyHelp,
                icon: Icons.lightbulb_outline,
                variant: MxButtonVariant.ghost,
                onPressed: hintShown ? null : onHint,
              ),
            ),
            const SizedBox(width: MxSpacing.space3),
            Expanded(
              child: MxButton(label: l10n.studyCheck, onPressed: onCheck),
            ),
          ],
        ),
      ],
    );
  }
}
