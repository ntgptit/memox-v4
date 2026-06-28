import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/game/viewmodels/game_session_notifier.dart';

/// Recall: show a term, reveal the meaning, then self-grade. "Forgot" re-queues
/// the card (D-015).
class RecallGame extends ConsumerStatefulWidget {
  const RecallGame({super.key, required this.request});

  final GameRequest request;

  @override
  ConsumerState<RecallGame> createState() => _RecallGameState();
}

class _RecallGameState extends ConsumerState<RecallGame> {
  bool _revealed = false;

  GameSessionNotifier get _notifier =>
      ref.read(gameSessionProvider(widget.request).notifier);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(gameSessionProvider(widget.request)).value;
    final current = state?.current;
    if (state == null || current == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(MxSpacing.space5),
      child: Column(
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(MxSpacing.space6),
              child: Center(
                child: Text(current.term, style: theme.textTheme.headlineSmall),
              ),
            ),
          ),
          const SizedBox(height: MxSpacing.space4),
          if (_revealed)
            Text(current.meaning, style: theme.textTheme.bodyLarge),
          const Spacer(),
          if (!_revealed)
            FilledButton(
              key: const Key('recallShow'),
              onPressed: () => setState(() => _revealed = true),
              child: Text(l10n.gameShow),
            )
          else
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    key: const Key('recallForgot'),
                    onPressed: () {
                      _notifier.markWrong(current.cardId);
                      setState(() => _revealed = false);
                    },
                    child: Text(l10n.gameForgot),
                  ),
                ),
                const SizedBox(width: MxSpacing.space3),
                Expanded(
                  child: FilledButton(
                    key: const Key('recallRemembered'),
                    onPressed: () {
                      _notifier.markCorrect(current.cardId);
                      setState(() => _revealed = false);
                    },
                    child: Text(l10n.gameRemembered),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
