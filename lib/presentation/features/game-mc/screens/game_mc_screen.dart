import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/routes/app_routes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/game-mc/providers/mc_providers.dart';
import 'package:memox_v4/presentation/features/game-mc/widgets/prompt_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_choice_option.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_progress_bar.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

/// Fixed height for the complete / empty / error boxes.
const double _stateBoxHeight = 400;

/// The Multiple-choice game (S.15): a prompt term + four meaning choices. Reads
/// the round through [mcControllerProvider], rendered with `AsyncValue.when`.
/// Answering locks the choices (correct/wrong tones) and reveals Next. No
/// `setState`. Copy is from ARB.
class GameMcScreen extends ConsumerWidget {
  const GameMcScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appBar = MxAppBar(
      title: l10n.mcTitle,
      leading: MxIconButton(
        icon: Icons.arrow_back,
        semanticLabel: l10n.mcBack,
        onPressed: () => context.pop(),
      ),
    );
    final async = ref.watch(mcControllerProvider);

    return async.when(
      loading: () => MxScaffold(appBar: appBar, children: const [
        MxProgressBar(value: 0),
        SizedBox(height: MxSpacing.space5),
        MxSkeleton(height: 200),
      ]),
      error: (_, _) => MxScaffold(
        appBar: appBar,
        children: [
          _StateBox(
            child: MxEmptyState(
              icon: Icons.error_outline,
              tone: MxIconTileTone.error,
              title: l10n.mcErrorTitle,
              text: l10n.mcErrorText,
              action: MxButton(
                label: l10n.actionRetry,
                icon: Icons.refresh,
                onPressed: () => ref.invalidate(mcControllerProvider),
              ),
            ),
          ),
        ],
      ),
      data: (state) => _content(context, ref, appBar, state),
    );
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    MxAppBar appBar,
    McState state,
  ) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(mcControllerProvider.notifier);

    if (state.isEmpty) {
      return MxScaffold(
        appBar: appBar,
        children: [
          _StateBox(
            child: MxEmptyState(
              icon: Icons.style,
              title: l10n.mcEmptyTitle,
              text: l10n.mcEmptyText,
            ),
          ),
        ],
      );
    }

    if (state.isComplete) {
      return MxScaffold(
        appBar: appBar,
        children: [
          const MxProgressBar(value: 1),
          _StateBox(
            child: MxEmptyState(
              icon: Icons.celebration,
              tone: MxIconTileTone.success,
              title: l10n.mcCompleteTitle,
              text: l10n.mcCompleteText(state.correctCount, state.total),
              action: MxButton(
                label: l10n.mcNextRound,
                icon: Icons.arrow_forward,
                onPressed: controller.nextRound,
              ),
            ),
          ),
        ],
      );
    }

    final question = state.current;
    final answered = state.chosen != null;

    return MxScaffold(
      appBar: appBar,
      children: [
        MxProgressBar(value: state.progress),
        PromptCard(
          term: question.prompt,
          onAudio: controller.playAudio,
          onEdit: () => context.push(Routes.editCard(question.cardId)),
        ),
        for (final (index, choice) in question.choices.indexed)
          MxChoiceOption(
            text: choice,
            tone: _toneFor(state, index),
            onPressed: answered ? null : () => controller.answer(index),
          ),
        if (answered)
          MxButton(
            label: l10n.mcNext,
            icon: Icons.arrow_forward,
            block: true,
            onPressed: controller.next,
          ),
      ],
    );
  }

  MxChoiceTone _toneFor(McState state, int index) {
    if (state.chosen == null) return MxChoiceTone.none;
    if (index == state.current.correctIndex) return MxChoiceTone.correct;
    if (index == state.chosen) return MxChoiceTone.wrong;
    return MxChoiceTone.none;
  }
}

class _StateBox extends StatelessWidget {
  const _StateBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: _stateBoxHeight, child: child);
}
