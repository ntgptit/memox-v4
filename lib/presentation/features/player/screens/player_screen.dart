import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/player/providers/player_providers.dart';
import 'package:memox_v4/presentation/features/player/widgets/dots.dart';
import 'package:memox_v4/presentation/features/player/widgets/player_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_fab.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_segmented_control.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

/// Fixed height for the end / empty / error boxes.
const double _stateBoxHeight = 460;

/// The auto-play Player (S.19): reads every card in the library aloud, one at a
/// time, with transport controls (prev · play/pause · next), a deck-progress dot
/// row, and a playback-speed control. Reads the playthrough through
/// [playerControllerProvider], rendered with `AsyncValue.when` (playing · paused
/// · speed · end). No `setState`. Copy is from ARB.
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appBar = MxAppBar(
      title: l10n.playerTitle,
      leading: MxIconButton(
        icon: Icons.arrow_back,
        semanticLabel: l10n.playerBack,
        onPressed: () => context.pop(),
      ),
    );
    final async = ref.watch(playerControllerProvider);

    return async.when(
      loading: () => MxScaffold(
        appBar: appBar,
        children: const [
          MxSkeleton(height: 8),
          SizedBox(height: MxSpacing.space5),
          MxSkeleton(height: 280),
        ],
      ),
      error: (_, _) => MxScaffold(
        appBar: appBar,
        children: [
          _StateBox(
            child: MxEmptyState(
              icon: Icons.error_outline,
              tone: MxIconTileTone.error,
              title: l10n.playerErrorTitle,
              text: l10n.playerErrorText,
              action: MxButton(
                label: l10n.actionRetry,
                icon: Icons.refresh,
                onPressed: () => ref.invalidate(playerControllerProvider),
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
    PlayerState state,
  ) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(playerControllerProvider.notifier);

    if (state.isEmpty) {
      return MxScaffold(
        appBar: appBar,
        children: [
          _StateBox(
            child: MxEmptyState(
              icon: Icons.library_music,
              title: l10n.playerEmptyTitle,
              text: l10n.playerEmptyText,
            ),
          ),
        ],
      );
    }

    if (state.isEnd) {
      return MxScaffold(
        appBar: appBar,
        children: [
          _StateBox(
            child: MxEmptyState(
              icon: Icons.library_music,
              tone: MxIconTileTone.accent,
              title: l10n.playerEndTitle,
              text: l10n.playerEndText,
              action: SizedBox(
                width: MxSizes.size3xl,
                child: Column(
                  children: [
                    MxButton(
                      label: l10n.playerReplay,
                      icon: Icons.replay,
                      block: true,
                      onPressed: controller.replay,
                    ),
                    const SizedBox(height: MxSpacing.space3),
                    MxButton(
                      label: l10n.playerClose,
                      icon: Icons.close,
                      variant: MxButtonVariant.ghost,
                      block: true,
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Invariant: past the isEmpty / isEnd guards above the index is in range
    // (init at 0, prev clamps at 0), so PlayerState.current is present here.
    final card = state.current!;
    return MxScaffold(
      appBar: appBar,
      children: [
        PlayerDots(active: state.activeDot),
        PlayerCard(term: card.term, meaning: card.meanings.first.text),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MxIconButton(
              icon: Icons.skip_previous,
              semanticLabel: l10n.playerPrev,
              onPressed: controller.prev,
            ),
            const SizedBox(width: MxSpacing.space6),
            MxFab(
              icon: state.playing ? Icons.pause : Icons.play_arrow,
              round: true,
              semanticLabel: state.playing ? l10n.playerPause : l10n.playerPlay,
              onPressed: controller.playPause,
            ),
            const SizedBox(width: MxSpacing.space6),
            MxIconButton(
              icon: Icons.skip_next,
              semanticLabel: l10n.playerNext,
              onPressed: controller.next,
            ),
          ],
        ),
        state.speedOpen
            ? MxSegmentedControl(
                block: true,
                value: state.speed,
                onChanged: controller.setSpeed,
                segments: [
                  for (final rate in playerSpeeds)
                    MxSegment(value: rate, label: l10n.playerSpeedValue(rate)),
                ],
              )
            : Center(
                child: MxButton(
                  label: l10n.playerSpeedValue(state.speed),
                  icon: Icons.speed,
                  variant: MxButtonVariant.ghost,
                  size: MxButtonSize.small,
                  onPressed: controller.toggleSpeedControl,
                ),
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
