import 'dart:async';

import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/logging/logger_provider.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/review_grade.dart';
import 'package:memox_v4/domain/entities/study_mode.dart';
import 'package:memox_v4/domain/entities/study_session.dart';
import 'package:memox_v4/domain/usecases/srs/srs_scheduler.dart';
import 'package:memox_v4/domain/usecases/study/build_study_queue.dart';
import 'package:memox_v4/domain/usecases/study/grade_card.dart';
import 'package:memox_v4/domain/usecases/study/graduate_card.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_session_providers.g.dart';

/// The per-day new-card allowance (D-018 default; per-deck config deferred).
const int _newPerDayCap = 20;

/// How many pairs the matching stage groups (the card + peers).
const int _matchGroupSize = 3;

/// How many choices the choice stage offers (the answer + distractors).
const int _choiceCount = 3;

/// The kind of exercise a step presents. The first five are the NewLearn stages
/// (in order); [dueReview] is the "Lặp lại" grading of a scheduled card.
enum StudyStageKind { review, matching, choice, recall, typing, dueReview }

/// A labelled matching tile — matches its counterpart when the [cardId] agrees.
class MatchTile {
  const MatchTile({required this.cardId, required this.text});
  final String cardId;
  final String text;
}

/// One step of the session — a card presented in a particular [kind], with any
/// precomputed exercise payload (choices / matching tiles).
class StudyStep {
  const StudyStep({
    required this.card,
    required this.kind,
    this.choices = const [],
    this.correctChoice = 0,
    this.terms = const [],
    this.meanings = const [],
  });

  final Card card;
  final StudyStageKind kind;
  final List<String> choices;
  final int correctChoice;
  final List<MatchTile> terms;
  final List<MatchTile> meanings;

  String get term => card.term;
  String get meaning => card.meanings.first.text;
}

/// The mutable per-step interaction (reset when the step advances).
class StepState {
  const StepState({
    this.revealed = false,
    this.chosen,
    this.wrongChoice = false,
    this.selectedTermId,
    this.matched = const {},
    this.hintShown = false,
  });

  final bool revealed;
  final int? chosen;
  final bool wrongChoice;
  final String? selectedTermId;
  final Set<String> matched;
  final bool hintShown;

  StepState copyWith({
    bool? revealed,
    int? Function()? chosen,
    bool? wrongChoice,
    String? Function()? selectedTermId,
    Set<String>? matched,
    bool? hintShown,
  }) {
    return StepState(
      revealed: revealed ?? this.revealed,
      chosen: chosen != null ? chosen() : this.chosen,
      wrongChoice: wrongChoice ?? this.wrongChoice,
      selectedTermId:
          selectedTermId != null ? selectedTermId() : this.selectedTermId,
      matched: matched ?? this.matched,
      hintShown: hintShown ?? this.hintShown,
    );
  }
}

/// The session state — the ordered steps, the cursor, the current interaction,
/// and a save-error flag (a grade/graduation write failed and needs a retry).
class StudySessionState {
  const StudySessionState({
    required this.steps,
    required this.index,
    required this.step,
    required this.mode,
    required this.saveError,
  });

  final List<StudyStep> steps;
  final int index;
  final StepState step;
  final StudyMode mode;
  final bool saveError;

  bool get isEmpty => steps.isEmpty;
  bool get isComplete => steps.isNotEmpty && index >= steps.length;
  int get total => steps.length;
  double get progress => steps.isEmpty ? 0 : index / steps.length;
  StudyStep? get current =>
      (index < 0 || index >= steps.length) ? null : steps[index];

  StudySessionState copyWith({
    int? index,
    StepState? step,
    bool? saveError,
  }) {
    return StudySessionState(
      steps: steps,
      index: index ?? this.index,
      step: step ?? this.step,
      mode: mode,
      saveError: saveError ?? this.saveError,
    );
  }
}

/// Drives a study session: builds the due + new queues (DM.5), sequences each due
/// card into a grading step and each new card into the five NewLearn stages, and
/// applies the SRS outcome (`GradeCard` / `GraduateCard`) as the learner works
/// through. Finishing records a counting [StudySession]. An async notifier
/// rendered with `AsyncValue.when`; a failed build is the resume-error surface.
@riverpod
class StudySessionController extends _$StudySessionController {
  DateTime _startedAt = DateTime.fromMicrosecondsSinceEpoch(0);

  @override
  Future<StudySessionState> build() async {
    try {
      final now = ref.read(clockProvider).now();
      _startedAt = now;
      final queue = _buildStudyQueue();

      final due = _value(await queue.due(asOf: now));
      final newCards = _value(
        await queue.newCards(perDayCap: _newPerDayCap, introducedToday: 0),
      );

      final steps = _planSteps(due: due, newCards: newCards);
      final mode = newCards.isNotEmpty ? StudyMode.newLearn : StudyMode.dueReview;
      return StudySessionState(
        steps: steps,
        index: 0,
        step: const StepState(),
        mode: mode,
        saveError: false,
      );
    } on Failure catch (failure, stackTrace) {
      ref.read(loggerProvider).error(
            'study session load failed',
            error: failure,
            stackTrace: stackTrace,
          );
      rethrow;
    }
  }

  // ── NewLearn stage transitions (teaching steps — no per-stage grading) ──────

  /// Stage 1 (review) / stage 4 recall-after-reveal / stage 2 auto-advance:
  /// move to the next step.
  void advance() {
    final data = state.asData?.value;
    if (data == null || data.current == null) return;
    _goNext(data);
  }

  void reveal() {
    final data = state.asData?.value;
    if (data == null || data.current?.kind != StudyStageKind.recall) return;
    if (data.step.revealed) return;
    state = AsyncData(data.copyWith(step: data.step.copyWith(revealed: true)));
  }

  /// Pick a choice in stage 3 / relearn. A correct pick advances; a wrong pick
  /// shows the not-counted relearn note and lets the learner retry.
  void choose(int index) {
    final data = state.asData?.value;
    final step = data?.current;
    if (data == null || step == null || step.kind != StudyStageKind.choice) return;
    if (index == step.correctChoice) {
      _goNext(data);
      return;
    }
    state = AsyncData(
      data.copyWith(
        step: data.step.copyWith(chosen: () => index, wrongChoice: true),
      ),
    );
  }

  /// Select a matching tile (stage 2). Selecting a term then its meaning (same
  /// card) matches the pair; matching every pair advances.
  void selectTerm(String cardId) {
    final data = state.asData?.value;
    if (data == null || data.current?.kind != StudyStageKind.matching) return;
    state = AsyncData(
      data.copyWith(step: data.step.copyWith(selectedTermId: () => cardId)),
    );
  }

  void selectMeaning(String cardId) {
    final data = state.asData?.value;
    final step = data?.current;
    if (data == null || step == null || step.kind != StudyStageKind.matching) return;
    if (data.step.selectedTermId != cardId) {
      state = AsyncData(
        data.copyWith(step: data.step.copyWith(selectedTermId: () => null)),
      );
      return;
    }
    final matched = {...data.step.matched, cardId};
    if (matched.length >= step.terms.length) {
      _goNext(data);
      return;
    }
    state = AsyncData(
      data.copyWith(
        step: data.step.copyWith(matched: matched, selectedTermId: () => null),
      ),
    );
  }

  void showHint() {
    final data = state.asData?.value;
    if (data == null || data.current?.kind != StudyStageKind.typing) return;
    state = AsyncData(data.copyWith(step: data.step.copyWith(hintShown: true)));
  }

  /// Stage 5 (typing): completes the NewLearn flow — graduate the card into the
  /// schedule, then advance. A failed write raises the save-error surface.
  Future<void> checkTyping() async {
    final data = state.asData?.value;
    final step = data?.current;
    if (data == null || step == null || step.kind != StudyStageKind.typing) return;
    final graduated = await GraduateCard(
      reviews: ref.read(reviewRepositoryProvider),
      scheduler: SrsScheduler(ref.read(clockProvider)),
    ).call(step.card.id);
    if (graduated case Err(:final failure)) {
      ref.read(loggerProvider).error('graduate failed', error: failure);
      state = AsyncData(data.copyWith(saveError: true));
      return;
    }
    _goNext(data);
  }

  // ── DueReview grading ───────────────────────────────────────────────────────

  /// Grade the current due card (pass = promote, fail = demote). A failed write
  /// raises the save-error surface.
  Future<void> gradeDue(ReviewGrade grade) async {
    final data = state.asData?.value;
    final step = data?.current;
    if (data == null || step == null || step.kind != StudyStageKind.dueReview) {
      return;
    }
    final graded = await GradeCard(
      reviews: ref.read(reviewRepositoryProvider),
      scheduler: SrsScheduler(ref.read(clockProvider)),
    ).call(cardId: step.card.id, grade: grade);
    if (graded case Err(:final failure)) {
      ref.read(loggerProvider).error('grade failed', error: failure);
      state = AsyncData(data.copyWith(saveError: true));
      return;
    }
    _goNext(data);
  }

  // ── Save-error recovery ─────────────────────────────────────────────────────

  void dismissSaveError() {
    final data = state.asData?.value;
    if (data == null || !data.saveError) return;
    state = AsyncData(data.copyWith(saveError: false));
  }

  /// Retry the write that failed for the current step.
  Future<void> retrySave() async {
    final data = state.asData?.value;
    final step = data?.current;
    if (data == null || step == null || !data.saveError) return;
    state = AsyncData(data.copyWith(saveError: false));
    if (step.kind == StudyStageKind.dueReview) {
      await gradeDue(ReviewGrade.pass);
      return;
    }
    await checkTyping();
  }

  void _goNext(StudySessionState data) {
    final next = data.copyWith(index: data.index + 1, step: const StepState());
    state = AsyncData(next);
    if (next.isComplete) unawaited(_record(next));
  }

  Future<void> _record(StudySessionState data) async {
    final first = data.steps.first.card;
    final now = ref.read(clockProvider).now();
    final minutes = now.difference(_startedAt).inMinutes;
    final words = data.steps.map((s) => s.card.id.value).toSet().length;
    final session = StudySession(
      id: StudySessionId('session-${now.microsecondsSinceEpoch}'),
      deckId: first.deckId,
      mode: data.mode,
      startedAt: _startedAt,
      durationMinutes: minutes < 0 ? 0 : minutes,
      wordsStudied: words,
    );
    final recorded = await ref.read(dailyActivityServiceProvider).record(session);
    if (recorded case Err(:final failure)) {
      ref.read(loggerProvider).error('session record failed', error: failure);
    }
  }

  // Failure is the domain error channel; the build() catch turns it into the
  // resume-error AsyncValue.
  T _value<T>(Result<T> result) => switch (result) {
        Ok<T>(:final value) => value,
        // ignore: only_throw_errors
        Err<T>(:final failure) => throw failure,
      };

  BuildStudyQueue _buildStudyQueue() => BuildStudyQueue(
        reviews: ref.read(reviewRepositoryProvider),
        scheduler: SrsScheduler(ref.read(clockProvider)),
      );

  List<StudyStep> _planSteps({
    required List<Card> due,
    required List<Card> newCards,
  }) {
    final pool = [...due, ...newCards];
    final steps = <StudyStep>[
      for (final card in due) StudyStep(card: card, kind: StudyStageKind.dueReview),
    ];
    for (final card in newCards) {
      steps
        ..add(StudyStep(card: card, kind: StudyStageKind.review))
        ..add(_matchingStep(card, pool))
        ..add(_choiceStep(card, pool))
        ..add(StudyStep(card: card, kind: StudyStageKind.recall))
        ..add(StudyStep(card: card, kind: StudyStageKind.typing));
    }
    return steps;
  }

  StudyStep _choiceStep(Card card, List<Card> pool) {
    final answer = card.meanings.first.text;
    final distractors = <String>[
      for (final other in pool)
        if (other.id != card.id && other.meanings.isNotEmpty)
          other.meanings.first.text,
    ];
    final options = <String>[answer];
    for (final d in distractors) {
      if (options.length >= _choiceCount) break;
      if (!options.contains(d)) options.add(d);
    }
    options.sort(); // stable, id-free ordering
    return StudyStep(
      card: card,
      kind: StudyStageKind.choice,
      choices: options,
      correctChoice: options.indexOf(answer),
    );
  }

  StudyStep _matchingStep(Card card, List<Card> pool) {
    final group = <Card>[card];
    for (final other in pool) {
      if (group.length >= _matchGroupSize) break;
      if (other.id != card.id && other.meanings.isNotEmpty) group.add(other);
    }
    final terms = [
      for (final c in group) MatchTile(cardId: c.id.value, text: c.term),
    ];
    final meanings = [
      for (final c in group.reversed)
        MatchTile(cardId: c.id.value, text: c.meanings.first.text),
    ];
    return StudyStep(
      card: card,
      kind: StudyStageKind.matching,
      terms: terms,
      meanings: meanings,
    );
  }
}
