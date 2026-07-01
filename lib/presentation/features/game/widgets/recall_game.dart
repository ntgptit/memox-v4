import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/game/round.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_text.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_card.dart';

/// Recall: show a term, reveal the meaning, then self-grade. "Forgot" re-queues
/// the card (D-015).
class RecallGame extends StatefulWidget {
  const RecallGame({super.key, required this.round, required this.actions});

  final RoundState round;
  final RoundActions actions;

  @override
  State<RecallGame> createState() => _RecallGameState();
}

class _RecallGameState extends State<RecallGame> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = widget.round.current;
    if (current == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(MxSpacing.space5),
      child: Column(
        children: <Widget>[
          MxCard(
            key: const ValueKey('mx-node:game-recall/term'),
            padding: MxCardPadding.lg,
            child: Center(
              child: MxText(
                current.term,
                role: MxTextRole.displayLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: MxSpacing.space4),
          if (_revealed)
            MxCard(
              key: const ValueKey('mx-node:game-recall/meaning'),
              padding: MxCardPadding.lg,
              child: MxText(current.meaning, role: MxTextRole.bodyLarge),
            ),
          const Spacer(),
          if (!_revealed)
            FilledButton(
              key: const ValueKey('mx-node:game-recall/reveal'),
              onPressed: () => setState(() => _revealed = true),
              child: Text(l10n.gameShow),
            )
          else
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    key: const ValueKey('mx-node:game-recall/forgot'),
                    onPressed: () {
                      widget.actions.markWrong(current.cardId);
                      setState(() => _revealed = false);
                    },
                    child: Text(l10n.gameForgot),
                  ),
                ),
                const SizedBox(width: MxSpacing.space3),
                Expanded(
                  child: FilledButton(
                    key: const ValueKey('mx-node:game-recall/remembered'),
                    onPressed: () {
                      widget.actions.markCorrect(current.cardId);
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
