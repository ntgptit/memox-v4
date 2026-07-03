import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/game-matching/providers/matching_providers.dart';
import 'package:memox_v4/presentation/features/game-matching/widgets/tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_progress_bar.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

/// Fixed height for the complete / empty / error boxes.
const double _stateBoxHeight = 400;

/// The Matching game (S.14): match meanings (left) to terms (right). Reads the
/// round through [matchingControllerProvider], rendered with `AsyncValue.when`.
/// Taps resolve in the controller (playing · selected · wrong · matched ·
/// complete). No `setState`. Copy is from ARB.
class GameMatchingScreen extends ConsumerWidget {
  const GameMatchingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appBar = MxAppBar(
      title: l10n.matchingTitle,
      leading: MxIconButton(
        icon: Icons.arrow_back,
        semanticLabel: l10n.matchingBack,
        onPressed: () => context.pop(),
      ),
    );
    final async = ref.watch(matchingControllerProvider);

    return async.when(
      loading: () => MxScaffold(appBar: appBar, children: const [
        MxProgressBar(value: 0),
        SizedBox(height: MxSpacing.space5),
        MxSkeleton(height: 240),
      ]),
      error: (_, _) => MxScaffold(
        appBar: appBar,
        children: [
          _StateBox(
            child: MxEmptyState(
              icon: Icons.error_outline,
              tone: MxIconTileTone.error,
              title: l10n.matchingErrorTitle,
              text: l10n.matchingErrorText,
              action: MxButton(
                label: l10n.actionRetry,
                icon: Icons.refresh,
                onPressed: () => ref.invalidate(matchingControllerProvider),
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
    MatchingState state,
  ) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(matchingControllerProvider.notifier);

    if (state.total == 0) {
      return MxScaffold(
        appBar: appBar,
        children: [
          _StateBox(
            child: MxEmptyState(
              icon: Icons.style,
              title: l10n.matchingEmptyTitle,
              text: l10n.matchingEmptyText,
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
              title: l10n.matchingCompleteTitle,
              text: l10n.matchingCompleteText(state.matchedCount, state.total),
              action: MxButton(
                label: l10n.matchingNext,
                icon: Icons.arrow_forward,
                onPressed: controller.nextRound,
              ),
            ),
          ),
        ],
      );
    }

    return MxScaffold(
      appBar: appBar,
      children: [
        MxProgressBar(value: state.progress),
        const SizedBox(height: MxSpacing.space2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _column(controller, state, left: true)),
            const SizedBox(width: MxSpacing.space3),
            Expanded(child: _column(controller, state, left: false)),
          ],
        ),
      ],
    );
  }

  Widget _column(
    MatchingController controller,
    MatchingState state,
    {required bool left}) {
    final tiles = left ? state.left : state.right;
    return Column(
      children: [
        for (final (index, tile) in tiles.indexed) ...[
          if (index > 0) const SizedBox(height: MxSpacing.space3),
          MatchTileView(
            text: tile.text,
            tone: _toneFor(state, left: left, index: index),
            onPressed: left
                ? () => controller.selectLeft(index)
                : () => controller.selectRight(index),
          ),
        ],
      ],
    );
  }

  MatchTone _toneFor(MatchingState state, {required bool left, required int index}) {
    final matched = left ? state.matchedLeft : state.matchedRight;
    if (matched.contains(index)) return MatchTone.matched;
    if (left && state.selectedLeft == index) return MatchTone.selected;
    final wrong = left ? state.wrongLeft : state.wrongRight;
    if (wrong == index) return MatchTone.wrong;
    return MatchTone.none;
  }
}

class _StateBox extends StatelessWidget {
  const _StateBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: _stateBoxHeight, child: child);
}
