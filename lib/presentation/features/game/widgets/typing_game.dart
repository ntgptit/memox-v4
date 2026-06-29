import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/domain/usecases/game/evaluate_typing.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/game/round.dart';

/// Fill in: show a meaning, type the term (tolerant match). Wrong re-queues the
/// card (D-015).
class TypingGame extends StatefulWidget {
  const TypingGame({super.key, required this.round, required this.actions});

  final RoundState round;
  final RoundActions actions;

  @override
  State<TypingGame> createState() => _TypingGameState();
}

class _TypingGameState extends State<TypingGame> {
  final TextEditingController _controller = TextEditingController();
  static const EvaluateTypingUseCase _evaluate = EvaluateTypingUseCase();
  bool _checkedWrong = false;
  bool _showHint = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _reset() {
    _controller.clear();
    setState(() {
      _checkedWrong = false;
      _showHint = false;
    });
  }

  void _check(int cardId, String term) {
    if (_evaluate(_controller.text, term)) {
      widget.actions.markCorrect(cardId);
      _reset();
    } else {
      setState(() => _checkedWrong = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final current = widget.round.current;
    if (current == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(MxSpacing.space5),
      child: Column(
        children: <Widget>[
          Card(
            key: const ValueKey('mx-node:game-typing/meaning'),
            child: Padding(
              padding: const EdgeInsets.all(MxSpacing.space6),
              child: Center(
                child: Text(current.meaning, style: theme.textTheme.titleLarge),
              ),
            ),
          ),
          const SizedBox(height: MxSpacing.space4),
          TextField(
            key: const Key('typingField'),
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(hintText: l10n.gameTypingPlaceholder),
          ),
          if (_showHint && current.term.isNotEmpty) ...<Widget>[
            const SizedBox(height: MxSpacing.space2),
            Text(
              '${current.term.substring(0, 1)}… (${current.term.length})',
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (_checkedWrong) ...<Widget>[
            const SizedBox(height: MxSpacing.space3),
            Text(
              l10n.gameAnswerWas(current.term),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const Spacer(),
          if (!_checkedWrong)
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    key: const ValueKey('mx-node:game-typing/hint'),
                    onPressed: () => setState(() => _showHint = true),
                    child: Text(l10n.gameHelp),
                  ),
                ),
                const SizedBox(width: MxSpacing.space3),
                Expanded(
                  child: FilledButton(
                    key: const ValueKey('mx-node:game-typing/check'),
                    onPressed: () => _check(current.cardId, current.term),
                    child: Text(l10n.gameCheck),
                  ),
                ),
              ],
            )
          else
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    key: const ValueKey('mx-node:game-typing/retry'),
                    onPressed: () {
                      widget.actions.markWrong(current.cardId);
                      _reset();
                    },
                    child: Text(l10n.gameRetry),
                  ),
                ),
                const SizedBox(width: MxSpacing.space3),
                Expanded(
                  child: FilledButton(
                    key: const ValueKey('mx-node:game-typing/accept'),
                    onPressed: () {
                      widget.actions.markCorrect(current.cardId);
                      _reset();
                    },
                    child: Text(l10n.gameAccept),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
