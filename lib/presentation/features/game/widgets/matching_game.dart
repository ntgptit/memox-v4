import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/domain/models/game_card.dart';
import 'package:memox_v4/presentation/features/game/viewmodels/game_session_notifier.dart';

/// Matching: pair meanings (left) with terms (right); a correct pair disappears,
/// a wrong pair stays (re-learn within the round, D-015 — no re-queue needed as
/// the card is simply not removed).
class MatchingGame extends ConsumerStatefulWidget {
  const MatchingGame({super.key, required this.request});

  final GameRequest request;

  @override
  ConsumerState<MatchingGame> createState() => _MatchingGameState();
}

class _MatchingGameState extends ConsumerState<MatchingGame> {
  List<int> _leftOrder = const <int>[];
  List<int> _rightOrder = const <int>[];
  int? _selectedLeft;
  int? _selectedRight;

  @override
  void initState() {
    super.initState();
    final state = ref
        .read(gameSessionNotifierProvider(widget.request))
        .valueOrNull;
    final ids = state?.cards.map((c) => c.cardId).toList() ?? const <int>[];
    _leftOrder = List<int>.of(ids)..shuffle();
    _rightOrder = List<int>.of(ids)..shuffle();
  }

  GameSessionNotifier get _notifier =>
      ref.read(gameSessionNotifierProvider(widget.request).notifier);

  void _selectLeft(int id) {
    setState(() => _selectedLeft = id);
    _evaluate();
  }

  void _selectRight(int id) {
    setState(() => _selectedRight = id);
    _evaluate();
  }

  void _evaluate() {
    final left = _selectedLeft;
    final right = _selectedRight;
    if (left == null || right == null) return;
    if (left == right) {
      _notifier.markCorrect(left);
    } else {
      _notifier.markWrong(left, requeue: false);
    }
    setState(() {
      _selectedLeft = null;
      _selectedRight = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref
        .watch(gameSessionNotifierProvider(widget.request))
        .valueOrNull;
    if (state == null) return const SizedBox.shrink();
    final pending = state.pending.toSet();
    GameCard cardOf(int id) => state.cards.firstWhere((c) => c.cardId == id);
    final left = <int>[
      for (final id in _leftOrder)
        if (pending.contains(id)) id,
    ];
    final right = <int>[
      for (final id in _rightOrder)
        if (pending.contains(id)) id,
    ];
    return Padding(
      padding: const EdgeInsets.all(MxSpacing.space5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                for (final id in left)
                  _tile(
                    'matchLeft-$id',
                    cardOf(id).meaning,
                    _selectedLeft == id,
                    () => _selectLeft(id),
                  ),
              ],
            ),
          ),
          const SizedBox(width: MxSpacing.space3),
          Expanded(
            child: Column(
              children: <Widget>[
                for (final id in right)
                  _tile(
                    'matchRight-$id',
                    cardOf(id).term,
                    _selectedRight == id,
                    () => _selectRight(id),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    String keyValue,
    String label,
    bool selected,
    VoidCallback onTap,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: MxSpacing.space2),
    child: SizedBox(
      width: double.infinity,
      child: selected
          ? FilledButton(
              key: Key(keyValue),
              onPressed: onTap,
              child: Text(label),
            )
          : OutlinedButton(
              key: Key(keyValue),
              onPressed: onTap,
              child: Text(label),
            ),
    ),
  );
}
