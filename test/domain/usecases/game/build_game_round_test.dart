import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/domain/models/game_card.dart';
import 'package:memox_v4/domain/types/game_scope.dart';
import 'package:memox_v4/domain/usecases/game/build_game_round.dart';

GameRoundCandidate _cand(int id, {int? box, int? dueAt}) => GameRoundCandidate(
  card: GameCard(cardId: id, term: 't$id', meaning: 'm$id'),
  box: box,
  dueAt: dueAt,
);

void main() {
  const builder = BuildGameRoundUseCase();

  test('D-008: a round is capped at the requested count (default 5)', () {
    final candidates = <GameRoundCandidate>[
      for (var i = 0; i < 10; i++) _cand(i),
    ];
    expect(
      builder.call(candidates, scope: GameScope.all, nowMs: 0),
      hasLength(5),
    );
  });

  test('notMastered excludes box-8 cards', () {
    final candidates = <GameRoundCandidate>[
      _cand(1, box: 8),
      _cand(2, box: 3),
      _cand(3),
    ];
    final round = builder.call(
      candidates,
      scope: GameScope.notMastered,
      nowMs: 0,
      count: 10,
    );
    expect(round.map((c) => c.cardId).toList(), <int>[2, 3]);
  });

  test('all keeps every card', () {
    final candidates = <GameRoundCandidate>[_cand(1, box: 8), _cand(2)];
    expect(
      builder.call(candidates, scope: GameScope.all, nowMs: 0, count: 10),
      hasLength(2),
    );
  });

  test('spaced prioritises due cards first', () {
    final candidates = <GameRoundCandidate>[
      _cand(2, box: 5, dueAt: 9999),
      _cand(3),
      _cand(1, box: 3, dueAt: 100),
    ];
    final round = builder.call(
      candidates,
      scope: GameScope.spaced,
      nowMs: 1000,
      count: 10,
    );
    expect(round.first.cardId, 1);
  });

  test('random shuffles deterministically with a seed', () {
    final candidates = <GameRoundCandidate>[
      for (var i = 0; i < 5; i++) _cand(i),
    ];
    final a = builder.call(
      candidates,
      scope: GameScope.all,
      nowMs: 0,
      random: true,
      rng: Random(42),
    );
    final b = builder.call(
      candidates,
      scope: GameScope.all,
      nowMs: 0,
      random: true,
      rng: Random(42),
    );
    expect(a.map((c) => c.cardId).toList(), b.map((c) => c.cardId).toList());
  });
}
