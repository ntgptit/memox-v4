import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/review_grade.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/domain/entities/study_mode.dart';
import 'package:memox_v4/presentation/features/study-session/providers/study_session_providers.dart';

import '../../harness/provider_harness.dart';

final DateTime _now = DateTime.utc(2026, 7, 3, 9);

Deck _deck(String id, String name) =>
    (Deck.create(id: DeckId(id), name: name) as Ok<Deck>).value;

Card _card(String id, String deckId, String term, String meaning) => (Card.create(
      id: CardId(id),
      deckId: DeckId(deckId),
      term: term,
      meanings: [
        (CardMeaning.create(id: CardMeaningId('m-$id'), language: 'en', text: meaning)
                as Ok<CardMeaning>)
            .value,
      ],
    ) as Ok<Card>)
    .value;

/// A new (unseen) card → the new-learn flow starts at stage 1.
List<Override> studySessionNewOverrides() {
  final store = FakeStore();
  store.decks['d'] = _deck('d', 'Deck');
  store.cards['c1'] = _card('c1', 'd', '학교', 'school');
  store.srsByCard['c1'] = SrsState.newborn;
  return FakeHarness(store: store).overrides;
}

/// A card due for review → the due-review grading flow.
List<Override> studySessionDueOverrides() {
  final store = FakeStore();
  store.decks['d'] = _deck('d', 'Deck');
  store.cards['c1'] = _card('c1', 'd', '학교', 'school');
  store.srsByCard['c1'] = SrsState(
    box: BoxLevel.firstBox,
    dueAt: _now.subtract(const Duration(hours: 1)),
  );
  return FakeHarness(store: store).overrides;
}

// ── mid-session states (subclass the PUBLIC controller) ─────────────────────
// Stages 3–5, relearn, resume, resume-error, answer-save-error and exit need a
// SPECIFIC in-session position that a fresh build can't be in without completing
// each prior stage's exercise (whose choice index / card order is derived at
// runtime). Instead we hand the PUBLIC StudySessionController a fixed
// StudySessionState — the same pattern used for study-result / the games.

final Card _c1 = _card('c1', 'd', '학교', 'school');
final Card _c2 = _card('c2', 'd', '사과', 'apple');

/// The five NewLearn stages for [card] (matching tiles are unused by the states
/// we render, so left empty).
List<StudyStep> _newLearnSteps(Card card) => [
  StudyStep(card: card, kind: StudyStageKind.review),
  StudyStep(card: card, kind: StudyStageKind.matching),
  StudyStep(
    card: card,
    kind: StudyStageKind.choice,
    choices: const ['house', 'school', 'water'],
    correctChoice: 1,
  ),
  StudyStep(card: card, kind: StudyStageKind.recall),
  StudyStep(card: card, kind: StudyStageKind.typing),
];

final List<StudyStep> _oneCardPlan = _newLearnSteps(_c1);
final List<StudyStep> _twoCardPlan = [
  ..._newLearnSteps(_c1),
  ..._newLearnSteps(_c2),
];

StudySessionState _session({
  required List<StudyStep> steps,
  required int index,
  StepState step = const StepState(),
  bool saveError = false,
  Set<String> wrong = const {},
  StudyMode mode = StudyMode.newLearn,
}) => StudySessionState(
  steps: steps,
  index: index,
  step: step,
  mode: mode,
  saveError: saveError,
  wrongCardIds: wrong,
);

/// stage3-choice — the pick-the-meaning exercise, nothing chosen yet.
final StudySessionState studySessionStage3 = _session(
  steps: _oneCardPlan,
  index: 2,
);

/// stage4-recall — the reveal-then-self-check exercise, meaning hidden.
final StudySessionState studySessionStage4 = _session(
  steps: _oneCardPlan,
  index: 3,
);

/// stage5-typing — the type-the-term exercise.
final StudySessionState studySessionStage5 = _session(
  steps: _oneCardPlan,
  index: 4,
);

/// relearn — a wrong choice picked in stage 3 → the not-counted relearn note.
final StudySessionState studySessionRelearn = _session(
  steps: _oneCardPlan,
  index: 2,
  step: const StepState(chosen: 0, wrongChoice: true),
  wrong: const {'c1'},
);

/// resume — re-entering a partially-done session (Flutter has no distinct resume
/// surface; it renders the current step with the progress header already
/// advanced — here the 2nd card's stage 1 at 5/10).
final StudySessionState studySessionResume = _session(
  steps: _twoCardPlan,
  index: 5,
);

/// A due-review step, for the answer-save-error path.
final StudySessionState studySessionDueStep = _session(
  steps: [StudyStep(card: _c1, kind: StudyStageKind.dueReview)],
  index: 0,
  mode: StudyMode.dueReview,
);

List<Override> studySessionStateOverrides(StudySessionState state) => [
  ...FakeHarness().overrides,
  studySessionControllerProvider.overrideWith(() => _FixedSession(state)),
];

/// resume-error — the session failed to build → the resume-error surface.
List<Override> studySessionResumeErrorOverrides() => [
  ...FakeHarness().overrides,
  studySessionControllerProvider.overrideWith(_ErrorSession.new),
];

/// answer-save-error — grading the due card fails the write; the fixture drives a
/// grade tap so the false→true saveError transition fires the retry dialog (a
/// fixed saveError:true state wouldn't, since the screen listens for the change).
List<Override> studySessionSaveErrorOverrides() => [
  ...FakeHarness().overrides,
  studySessionControllerProvider.overrideWith(
    () => _SaveErrorSession(studySessionDueStep),
  ),
];

class _FixedSession extends StudySessionController {
  _FixedSession(this._state);

  final StudySessionState _state;

  @override
  Future<StudySessionState> build() async => _state;
}

class _ErrorSession extends StudySessionController {
  @override
  Future<StudySessionState> build() async =>
      // ignore: only_throw_errors -- reason: Failure is MemoX's domain error type; the real controller surfaces it as AsyncValue.error the same way
      throw const PersistenceFailure('resume failed (golden fixture)');
}

/// Returns a fixed due-review state and makes any grade fail the save — so a
/// grade tap flips saveError false→true and raises the retry dialog.
class _SaveErrorSession extends StudySessionController {
  _SaveErrorSession(this._state);

  final StudySessionState _state;

  @override
  Future<StudySessionState> build() async => _state;

  @override
  Future<void> gradeDue(ReviewGrade grade) async {
    final data = state.value;
    if (data == null) return;
    state = AsyncData(data.copyWith(saveError: true));
  }
}
