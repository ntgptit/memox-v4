import 'package:memox_v4/domain/models/game_card.dart';

/// A round snapshot the game widgets render. Produced by both the game session
/// and the study session, so the four game widgets drive NewLearn stages too.
class RoundState {
  const RoundState({
    required this.cards,
    required this.pending,
    this.lastWrong = false,
  });

  final List<GameCard> cards;
  final List<int> pending;
  final bool lastWrong;

  GameCard? get current => pending.isEmpty
      ? null
      : cards.firstWhere((c) => c.cardId == pending.first);
}

/// Grading actions a game widget invokes — implemented by `GameSessionNotifier`
/// and `StudySessionNotifier`.
abstract interface class RoundActions {
  void markCorrect(int cardId);
  void markWrong(int cardId, {bool requeue});
  void clearWrong();
}
