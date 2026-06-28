import 'package:memox_v4/app/di/card_providers.dart';
import 'package:memox_v4/app/di/clock_provider.dart';
import 'package:memox_v4/app/di/srs_providers.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/models/game_card.dart';
import 'package:memox_v4/domain/types/game_scope.dart';
import 'package:memox_v4/domain/types/game_type.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/usecases/game/build_game_round.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_session_notifier.g.dart';

/// Identifies a game round: which node's cards, which game, scope, and options.
class GameRequest {
  const GameRequest({
    required this.nodeId,
    required this.type,
    required this.scope,
    this.random = true,
    this.wordsPerRound = kDefaultGameWordsPerRound,
  });

  final int nodeId;
  final GameType type;
  final GameScope scope;
  final bool random;
  final int wordsPerRound;

  @override
  bool operator ==(Object other) =>
      other is GameRequest &&
      other.nodeId == nodeId &&
      other.type == type &&
      other.scope == scope &&
      other.random == random &&
      other.wordsPerRound == wordsPerRound;

  @override
  int get hashCode => Object.hash(nodeId, type, scope, random, wordsPerRound);
}

/// Round state: the chosen cards, the cards still pending a correct answer, and
/// whether the last answer was wrong. The round completes when [pending] is empty.
class GameSessionState {
  const GameSessionState({
    required this.type,
    required this.cards,
    required this.pending,
    this.lastWrong = false,
  });

  final GameType type;
  final List<GameCard> cards;
  final List<int> pending;
  final bool lastWrong;

  bool get isEmpty => cards.isEmpty;
  bool get isComplete => cards.isNotEmpty && pending.isEmpty;
  int get total => cards.length;
  int get done => total - pending.length;
  double get progress => total == 0 ? 0 : done / total;

  GameCard? get current => pending.isEmpty
      ? null
      : cards.firstWhere((c) => c.cardId == pending.first);

  GameSessionState copyWith({List<int>? pending, bool? lastWrong}) =>
      GameSessionState(
        type: type,
        cards: cards,
        pending: pending ?? this.pending,
        lastWrong: lastWrong ?? this.lastWrong,
      );
}

/// Drives a practice round. Never touches `srs_state` (D-007): wrong answers
/// re-queue the card within the round (D-015), nothing is scheduled.
@riverpod
class GameSessionNotifier extends _$GameSessionNotifier {
  @override
  Future<GameSessionState> build(GameRequest arg) async {
    final cards =
        (await ref
                .read(cardRepositoryProvider)
                .listByDeck(arg.nodeId, includeHidden: false))
            .valueOrNull ??
        const <Card>[];
    final ids = cards.map((c) => c.id).toList(growable: false);
    final infos =
        (await ref.read(srsRepositoryProvider).scheduleInfo(ids)).valueOrNull ??
        const [];
    final byId = {for (final info in infos) info.cardId: info};
    final candidates = <GameRoundCandidate>[
      for (final c in cards)
        GameRoundCandidate(
          card: GameCard(
            cardId: c.id,
            term: c.term,
            meaning: c.meanings.isEmpty ? '' : c.meanings.first.content,
          ),
          box: byId[c.id]?.box,
          dueAt: byId[c.id]?.dueAt,
        ),
    ];
    final selected = const BuildGameRoundUseCase().call(
      candidates,
      scope: arg.scope,
      count: arg.wordsPerRound,
      random: arg.random,
      nowMs: ref.read(clockProvider).now().millisecondsSinceEpoch,
    );
    return GameSessionState(
      type: arg.type,
      cards: selected,
      pending: <int>[for (final c in selected) c.cardId],
    );
  }

  void markCorrect(int cardId) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        pending: <int>[
          for (final id in current.pending)
            if (id != cardId) id,
        ],
        lastWrong: false,
      ),
    );
  }

  /// Marks the card wrong. For sequential games [requeue] moves it to the back of
  /// the queue; for matching the card simply stays (requeue false).
  void markWrong(int cardId, {bool requeue = true}) {
    final current = state.value;
    if (current == null) return;
    if (!requeue) {
      state = AsyncData(current.copyWith(lastWrong: true));
      return;
    }
    state = AsyncData(
      current.copyWith(
        pending: <int>[
          for (final id in current.pending)
            if (id != cardId) id,
          cardId,
        ],
        lastWrong: true,
      ),
    );
  }

  void clearWrong() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(lastWrong: false));
  }
}
