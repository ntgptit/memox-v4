import 'dart:async';

import 'package:memox_v4/app/di/card_providers.dart';
import 'package:memox_v4/app/di/clock_provider.dart';
import 'package:memox_v4/app/di/daily_activity_providers.dart';
import 'package:memox_v4/app/di/deck_providers.dart';
import 'package:memox_v4/app/di/review_outcome_providers.dart';
import 'package:memox_v4/app/di/srs_providers.dart';
import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/domain/models/game_card.dart';
import 'package:memox_v4/domain/repositories/card_repository.dart';
import 'package:memox_v4/domain/repositories/daily_activity_repository.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/domain/repositories/srs_repository.dart';
import 'package:memox_v4/domain/types/last_result.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/types/study_entry.dart';
import 'package:memox_v4/domain/usecases/srs/grade_card.dart';
import 'package:memox_v4/domain/usecases/srs/schedule_new_card.dart';
import 'package:memox_v4/domain/usecases/study/build_study_queue.dart';
import 'package:memox_v4/domain/usecases/study/finalize_study_session.dart';
import 'package:memox_v4/presentation/features/game/round.dart';
import 'package:memox_v4/presentation/features/language_pair/viewmodels/language_pair_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_session_notifier.g.dart';

/// Identifies a scheduled study session: which node, which entry (newLearn or
/// dueReview).
class StudyRequest {
  const StudyRequest({required this.nodeId, required this.entry});

  final int nodeId;
  final StudyEntry entry;

  @override
  bool operator ==(Object other) =>
      other is StudyRequest && other.nodeId == nodeId && other.entry == entry;

  @override
  int get hashCode => Object.hash(nodeId, entry);
}

/// A study session in progress. NewLearn runs 5 stages over the cards; DueReview
/// is a single grading pass. A wrong answer re-queues the card (D-015).
class StudySessionState {
  const StudySessionState({
    required this.entry,
    required this.cards,
    required this.pairId,
    required this.stageIndex,
    required this.pending,
    required this.startMs,
    this.revealed = false,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.finished = false,
  });

  final StudyEntry entry;
  final List<GameCard> cards;
  final int pairId;
  final int stageIndex;
  final List<int> pending;
  final int startMs;
  final bool revealed;
  final int correctCount;
  final int wrongCount;
  final bool finished;

  bool get isEmpty => cards.isEmpty;
  int get stageCount => entry == StudyEntry.newLearn ? 5 : 1;
  int get totalAnswers => correctCount + wrongCount;
  double get accuracy => totalAnswers == 0 ? 0 : correctCount / totalAnswers;

  GameCard? get current => pending.isEmpty
      ? null
      : cards.firstWhere((c) => c.cardId == pending.first);

  double get progress {
    if (cards.isEmpty) return 0;
    final withinStage = (cards.length - pending.length) / cards.length;
    return (stageIndex + withinStage) / stageCount;
  }

  StudySessionState copyWith({
    int? stageIndex,
    List<int>? pending,
    bool? revealed,
    int? correctCount,
    int? wrongCount,
    bool? finished,
  }) => StudySessionState(
    entry: entry,
    cards: cards,
    pairId: pairId,
    startMs: startMs,
    stageIndex: stageIndex ?? this.stageIndex,
    pending: pending ?? this.pending,
    revealed: revealed ?? this.revealed,
    correctCount: correctCount ?? this.correctCount,
    wrongCount: wrongCount ?? this.wrongCount,
    finished: finished ?? this.finished,
  );
}

/// Drives a scheduled session (NewLearn / DueReview). DueReview grades each card
/// into SRS (W3); NewLearn schedules cards into box 1 only after all 5 stages
/// complete (D-002) — quitting before then leaves them new (D-017). Finalize
/// adds activity for these entries only (D-010).
@riverpod
class StudySessionNotifier extends _$StudySessionNotifier
    implements RoundActions {
  DeckRepository get _deck => ref.read(deckRepositoryProvider);
  SrsRepository get _srs => ref.read(srsRepositoryProvider);
  CardRepository get _card => ref.read(cardRepositoryProvider);
  DailyActivityRepository get _daily =>
      ref.read(dailyActivityRepositoryProvider);
  Clock get _clock => ref.read(clockProvider);

  @override
  Future<StudySessionState> build(StudyRequest arg) async {
    final ids =
        (await BuildStudyQueueUseCase(
          _deck,
          _srs,
          _clock,
        ).call(arg.nodeId, arg.entry)).valueOrNull ??
        const <int>[];
    final cards = <GameCard>[];
    for (final id in ids) {
      final card = (await _card.getById(id)).valueOrNull;
      if (card != null) {
        cards.add(
          GameCard(
            cardId: card.id,
            term: card.term,
            meaning: card.meanings.isEmpty ? '' : card.meanings.first.content,
          ),
        );
      }
    }
    final pairId = ref.read(languagePairProvider).value?.active?.id ?? 0;
    return StudySessionState(
      entry: arg.entry,
      cards: cards,
      pairId: pairId,
      stageIndex: 0,
      pending: <int>[for (final c in cards) c.cardId],
      startMs: _clock.now().millisecondsSinceEpoch,
    );
  }

  void reveal() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(revealed: true));
  }

  // ── RoundActions: lets the game widgets drive NewLearn stages ──────────────
  @override
  void markCorrect(int cardId) => unawaited(grade(true));

  @override
  void markWrong(int cardId, {bool requeue = true}) => unawaited(grade(false));

  @override
  void clearWrong() {}

  Future<void> grade(bool correct) async {
    final session = state.value;
    final card = session?.current;
    if (session == null || card == null) return;

    if (session.entry == StudyEntry.dueReview) {
      await GradeCardUseCase(
        _srs,
        _clock,
      ).call(card.cardId, correct ? LastResult.correct : LastResult.wrong);
      await ref
          .read(reviewOutcomeRepositoryProvider)
          .record(
            cardId: card.cardId,
            pairId: session.pairId,
            ts: _clock.now().millisecondsSinceEpoch,
            correct: correct,
            mode: 'dueReview',
          );
    }

    var pending = <int>[
      for (final id in session.pending)
        if (id != card.cardId) id,
    ];
    var correctCount = session.correctCount;
    var wrongCount = session.wrongCount;
    if (correct) {
      correctCount++;
    } else {
      pending = <int>[...pending, card.cardId];
      wrongCount++;
    }

    var stageIndex = session.stageIndex;
    var finished = session.finished;
    if (pending.isEmpty) {
      if (session.entry == StudyEntry.newLearn &&
          stageIndex < session.stageCount - 1) {
        stageIndex++;
        pending = <int>[for (final c in session.cards) c.cardId];
      } else {
        if (session.entry == StudyEntry.newLearn) {
          for (final c in session.cards) {
            await ScheduleNewCardUseCase(_srs, _clock).call(c.cardId);
          }
        }
        await _finalize(session);
        finished = true;
      }
    }

    state = AsyncData(
      session.copyWith(
        pending: pending,
        revealed: false,
        correctCount: correctCount,
        wrongCount: wrongCount,
        stageIndex: stageIndex,
        finished: finished,
      ),
    );
  }

  Future<void> _finalize(StudySessionState session) async {
    final seconds =
        ((_clock.now().millisecondsSinceEpoch - session.startMs) / 1000)
            .round();
    await FinalizeStudySessionUseCase(_daily, _clock).call(
      pairId: session.pairId,
      entry: session.entry,
      seconds: seconds,
      words: session.cards.length,
    );
  }
}
