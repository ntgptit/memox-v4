import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/routes/app_routes.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/game-picker/providers/game_picker_providers.dart';
import 'package:memox_v4/presentation/features/game-picker/widgets/game_option.dart';
import 'package:memox_v4/presentation/features/game-picker/widgets/scope_card.dart';
import 'package:memox_v4/presentation/features/game-picker/widgets/scope_sheet.dart';
import 'package:memox_v4/presentation/shared/composites/action_callout.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/composites/mx_sheet.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

/// One playable game (kit `GAMES`).
typedef _Game = ({IconData icon, String route});

/// The Game picker (S.13): choose a card source + a game. Reads DM.5 queue counts
/// + the words-per-round setting through [gamePickerControllerProvider], rendered
/// with `AsyncValue.when`. Games are disabled (not-enough banner) when the source
/// has fewer than [gameMinWords] words. No `setState`. Copy is from ARB.
class GamePickerScreen extends ConsumerWidget {
  const GamePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appBar = MxAppBar(
      title: l10n.gamePickerTitle,
      leading: MxIconButton(
        icon: Icons.arrow_back,
        semanticLabel: l10n.gamePickerBack,
        onPressed: () => context.pop(),
      ),
    );
    final async = ref.watch(gamePickerControllerProvider);

    return async.when(
      loading: () => MxScaffold(appBar: appBar, children: _loadingBody()),
      error: (_, _) => MxScaffold(
        appBar: appBar,
        children: [
          SizedBox(
            height: MxSizes.size4xl,
            child: _ErrorBody(
              onRetry: () => ref.invalidate(gamePickerControllerProvider),
            ),
          ),
        ],
      ),
      data: (data) => _loaded(context, ref, appBar, data),
    );
  }

  Widget _loaded(
    BuildContext context,
    WidgetRef ref,
    MxAppBar appBar,
    GamePickerData data,
  ) {
    final l10n = AppLocalizations.of(context);
    final games = <_Game>[
      (icon: Icons.join_inner, route: Routes.gameMatching),
      (icon: Icons.quiz, route: Routes.gameMc),
      (icon: Icons.psychology, route: Routes.gameRecall),
      (icon: Icons.keyboard, route: Routes.gameTyping),
    ];
    final names = [l10n.gameMatching, l10n.gameMc, l10n.gameRecall, l10n.gameTyping];
    final descs = [
      l10n.gameMatchingDesc,
      l10n.gameMcDesc,
      l10n.gameRecallDesc,
      l10n.gameTypingDesc,
    ];

    return MxScaffold(
      appBar: appBar,
      children: [
        if (!data.canPlay)
          MxActionCallout(
            tone: MxCalloutTone.primary,
            icon: Icons.info_outline,
            text: l10n.gamePickerNotEnough(gameMinWords),
            action: MxButton(
              label: l10n.gamePickerAddWords,
              size: MxButtonSize.small,
              onPressed: () => context.push(Routes.add),
            ),
          ),
        ScopeCard(
          sourceLabel: _sourceLabel(l10n, data.source),
          onPressed: () => _openScopeSheet(context, ref, data.source),
        ),
        for (final (index, game) in games.indexed)
          GameOption(
            icon: game.icon,
            name: names[index],
            description: descs[index],
            onPressed: data.canPlay ? () => context.push(game.route) : null,
          ),
        _Footer(text: l10n.gamePickerFooter(data.wordsPerRound)),
      ],
    );
  }

  void _openScopeSheet(BuildContext context, WidgetRef ref, GameSource selected) {
    final l10n = AppLocalizations.of(context);
    showMxSheet<void>(
      context: context,
      title: l10n.gamePickerSourceLabel,
      child: ScopeSheet(
        selected: selected,
        onSelect: (source) =>
            ref.read(gamePickerControllerProvider.notifier).setSource(source),
      ),
    );
  }

  String _sourceLabel(AppLocalizations l10n, GameSource source) {
    return switch (source) {
      GameSource.schedule => l10n.gamePickerSourceSchedule,
      GameSource.all => l10n.gamePickerSourceAll,
      GameSource.unlearned => l10n.gamePickerSourceUnlearned,
    };
  }

  List<Widget> _loadingBody() {
    return [
      const MxCard(padding: MxCardPadding.small, child: MxSkeleton(height: 40)),
      for (var i = 0; i < 4; i++)
        const MxCard(padding: MxCardPadding.small, child: MxSkeleton(height: 40)),
    ];
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: MxTypography.fontFamily,
          fontSize: MxTypography.sizeSm,
          color: MxTheme.of(context).textTertiary,
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxEmptyState(
      icon: Icons.error_outline,
      tone: MxIconTileTone.error,
      title: l10n.gamePickerErrorTitle,
      text: l10n.gamePickerErrorText,
      action: MxButton(
        label: l10n.actionRetry,
        icon: Icons.refresh,
        onPressed: onRetry,
      ),
    );
  }
}
