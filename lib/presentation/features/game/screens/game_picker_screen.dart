import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/app/di/card_providers.dart';
import 'package:memox_v4/app/router/route_paths.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/domain/types/game_scope.dart';
import 'package:memox_v4/domain/types/game_type.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/usecases/game/build_game_round.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/settings/viewmodels/settings_notifier.dart';
import 'package:memox_v4/presentation/shared/layouts/responsive.dart';
import 'package:memox_v4/presentation/shared/widgets/buttons/mx_button.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_text.dart';
import 'package:memox_v4/presentation/shared/widgets/states/mx_state_view.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_scaffold.dart';

/// "A game" picker (`docs/design/screens/07-game-picker.md`, D-013): pick one of
/// the four games + a scope, or a not-enough state.
class GamePickerScreen extends ConsumerStatefulWidget {
  const GamePickerScreen({super.key, required this.nodeId});

  final int nodeId;

  @override
  ConsumerState<GamePickerScreen> createState() => _GamePickerScreenState();
}

class _GamePickerScreenState extends ConsumerState<GamePickerScreen> {
  GameScope _scope = GameScope.spaced;
  int? _count;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final cards =
        (await ref
                .read(cardRepositoryProvider)
                .listByDeck(widget.nodeId, includeHidden: false))
            .valueOrNull ??
        const [];
    if (!mounted) return;
    setState(() => _count = cards.length);
  }

  void _play(GameType type) {
    final settings = ref.read(settingsProvider).value;
    unawaited(
      context.push(
        RoutePaths.gamePlayLocation(
          widget.nodeId,
          type,
          _scope,
          random: settings?.gameRandom ?? true,
          wordsPerRound: settings?.gameWordsPerRound,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxScaffold(
      key: const ValueKey('mx-node:game-picker/screen'),
      appBar: MxAppBar(
        key: const ValueKey('mx-node:game-picker/appbar'),
        title: l10n.gameTitle,
      ),
      flush: true,
      body: switch (_count) {
        null => const MxStateView.loading(),
        0 => _notEnough(l10n),
        _ => _picker(l10n),
      },
    );
  }

  Widget _notEnough(AppLocalizations l10n) => MxContentBounds(
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.videogame_asset_outlined,
            size: MxSpacing.space10,
            color: MxTheme.of(context).colors.primary,
          ),
          const SizedBox(height: MxSpacing.space4),
          MxText(l10n.gameNotEnoughTitle),
          const SizedBox(height: MxSpacing.space4),
          MxButton(
            key: const ValueKey('mx-node:game-picker/add-cards'),
            label: l10n.deckAddWord,
            icon: Icons.add,
            onPressed: () =>
                context.push(RoutePaths.flashcardEditorLocation(widget.nodeId)),
          ),
        ],
      ),
    ),
  );

  Widget _picker(AppLocalizations l10n) {
    final wordsPerRound =
        ref.watch(settingsProvider).value?.gameWordsPerRound ??
        kDefaultGameWordsPerRound;
    return ListView(
      padding: const EdgeInsets.all(MxSpacing.space5),
      children: <Widget>[
        MxText.label(l10n.gameScopeLabel),
        const SizedBox(height: MxSpacing.space2),
        DropdownButton<GameScope>(
          key: const ValueKey('mx-node:game-picker/scope'),
          isExpanded: true,
          value: _scope,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _scope = value);
          },
          items: <DropdownMenuItem<GameScope>>[
            DropdownMenuItem<GameScope>(
              value: GameScope.spaced,
              child: Text(l10n.gameScopeSpaced),
            ),
            DropdownMenuItem<GameScope>(
              value: GameScope.all,
              child: Text(l10n.gameScopeAll),
            ),
            DropdownMenuItem<GameScope>(
              value: GameScope.notMastered,
              child: Text(l10n.gameScopeNotMastered),
            ),
          ],
        ),
        const SizedBox(height: MxSpacing.space2),
        MxText(l10n.gameWordsHint(wordsPerRound), role: MxTextRole.bodySmall),
        const SizedBox(height: MxSpacing.space4),
        _gameTile(
          GameType.matching,
          Icons.join_inner,
          l10n.gameMatching,
          l10n.gameMatchingDesc,
        ),
        _gameTile(
          GameType.multipleChoice,
          Icons.quiz_outlined,
          l10n.gameMultipleChoice,
          l10n.gameMultipleChoiceDesc,
        ),
        _gameTile(
          GameType.recall,
          Icons.visibility_outlined,
          l10n.gameRecall,
          l10n.gameRecallDesc,
        ),
        _gameTile(
          GameType.typing,
          Icons.keyboard_outlined,
          l10n.gameTyping,
          l10n.gameTypingDesc,
        ),
      ],
    );
  }

  Widget _gameTile(GameType type, IconData icon, String name, String desc) =>
      ListTile(
        key: Key('gamePick-${type.name}'),
        leading: Icon(icon),
        title: Text(name),
        subtitle: Text(desc),
        onTap: () => _play(type),
      );
}
