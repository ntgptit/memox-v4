import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/routes/app_routes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/game-recall/providers/recall_providers.dart';
import 'package:memox_v4/presentation/features/game-recall/widgets/meaning_panel.dart';
import 'package:memox_v4/presentation/features/game-recall/widgets/term_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_progress_bar.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

/// Fixed height for the complete / empty / error boxes.
const double _stateBoxHeight = 360;

/// The Recall game (S.16): show a term, recall its meaning, reveal, then
/// self-grade (Got it / Forgot). Reads the round through
/// [recallControllerProvider], rendered with `AsyncValue.when` (before-reveal ·
/// revealed · complete). Forgot re-queues the card. No `setState`. Copy is from ARB.
class GameRecallScreen extends ConsumerWidget {
  const GameRecallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appBar = MxAppBar(
      title: l10n.recallTitle,
      leading: MxIconButton(
        icon: Icons.arrow_back,
        semanticLabel: l10n.recallBack,
        onPressed: () => context.pop(),
      ),
    );
    final async = ref.watch(recallControllerProvider);

    return async.when(
      loading: () => MxScaffold(
        appBar: appBar,
        children: const [
          MxProgressBar(value: 0),
          SizedBox(height: MxSpacing.space5),
          MxSkeleton(height: 200),
        ],
      ),
      error: (_, _) => MxScaffold(
        appBar: appBar,
        children: [
          _StateBox(
            child: MxEmptyState(
              icon: Icons.error_outline,
              tone: MxIconTileTone.error,
              title: l10n.recallErrorTitle,
              text: l10n.recallErrorText,
              action: MxButton(
                label: l10n.actionRetry,
                icon: Icons.refresh,
                onPressed: () => ref.invalidate(recallControllerProvider),
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
    RecallState state,
  ) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(recallControllerProvider.notifier);

    if (state.isEmpty) {
      return MxScaffold(
        appBar: appBar,
        children: [
          _StateBox(
            child: MxEmptyState(
              icon: Icons.style,
              title: l10n.recallEmptyTitle,
              text: l10n.recallEmptyText,
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
              title: l10n.recallCompleteTitle,
              text: l10n.recallCompleteText,
              action: MxButton(
                label: l10n.recallNextRound,
                icon: Icons.arrow_forward,
                onPressed: controller.nextRound,
              ),
            ),
          ),
        ],
      );
    }

    final card = state.current!;
    return MxScaffold(
      appBar: appBar,
      children: [
        MxProgressBar(value: state.progress),
        TermCard(
          term: card.term,
          onAudio: controller.playAudio,
          onEdit: () => context.push(Routes.editCard(card.cardId)),
        ),
        MeaningPanel(meaning: card.meaning, revealed: state.revealed),
        !state.revealed
            ? MxButton(
                label: l10n.recallShow,
                icon: Icons.visibility,
                size: MxButtonSize.large,
                block: true,
                onPressed: controller.reveal,
              )
            : Row(
                children: [
                  Expanded(
                    child: MxButton(
                      label: l10n.recallForgot,
                      variant: MxButtonVariant.outline,
                      onPressed: controller.forgot,
                    ),
                  ),
                  const SizedBox(width: MxSpacing.space3),
                  Expanded(
                    child: MxButton(
                      label: l10n.recallGotIt,
                      onPressed: controller.gotIt,
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}

class _StateBox extends StatelessWidget {
  const _StateBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: _stateBoxHeight, child: child);
}
