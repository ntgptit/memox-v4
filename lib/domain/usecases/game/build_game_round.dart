import 'dart:math';

import 'package:memox_v4/domain/models/game_card.dart';
import 'package:memox_v4/domain/types/game_scope.dart';

/// Default number of cards per round (`settings.game_words_per_round`, D-008).
const int kDefaultGameWordsPerRound = 5;

/// A candidate card plus its schedule (box/due) so a round can honour the scope.
class GameRoundCandidate {
  const GameRoundCandidate({required this.card, this.box, this.dueAt});

  final GameCard card;
  final int? box;
  final int? dueAt;

  bool get isMastered => box != null && box! >= 8;
  bool get isNew => box == null || box == 0;
  bool isDue(int nowMs) =>
      box != null && box! >= 1 && box! < 8 && dueAt != null && dueAt! <= nowMs;
}

/// Builds a game round: filters by scope, optionally shuffles (random), and caps
/// at [count] cards (default 5, D-008). Practice only — reads schedule, never
/// writes it (D-007).
class BuildGameRoundUseCase {
  const BuildGameRoundUseCase();

  List<GameCard> call(
    List<GameRoundCandidate> candidates, {
    required GameScope scope,
    required int nowMs,
    int count = kDefaultGameWordsPerRound,
    bool random = false,
    Random? rng,
  }) {
    final pool = _filter(candidates, scope);
    final ordered = random
        ? (List<GameRoundCandidate>.of(pool)..shuffle(rng ?? Random()))
        : _order(pool, scope, nowMs);
    final limited = ordered.length <= count
        ? ordered
        : ordered.sublist(0, count);
    return <GameCard>[for (final candidate in limited) candidate.card];
  }

  List<GameRoundCandidate> _filter(
    List<GameRoundCandidate> candidates,
    GameScope scope,
  ) => switch (scope) {
    GameScope.all => candidates,
    GameScope.notMastered => <GameRoundCandidate>[
      for (final c in candidates)
        if (!c.isMastered) c,
    ],
    GameScope.spaced => <GameRoundCandidate>[
      for (final c in candidates)
        if (!c.isMastered) c,
    ],
  };

  List<GameRoundCandidate> _order(
    List<GameRoundCandidate> pool,
    GameScope scope,
    int nowMs,
  ) {
    if (scope != GameScope.spaced) return pool;
    int rank(GameRoundCandidate c) => c.isDue(nowMs) ? 0 : (c.isNew ? 1 : 2);
    return List<GameRoundCandidate>.of(pool)
      ..sort((a, b) => rank(a).compareTo(rank(b)));
  }
}
