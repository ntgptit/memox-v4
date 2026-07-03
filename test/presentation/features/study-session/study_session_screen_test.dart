import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/box_level.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/review_grade.dart';
import 'package:memox_v4/domain/entities/srs_state.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/study-session/providers/study_session_providers.dart';
import 'package:memox_v4/presentation/features/study-session/screens/study_session_screen.dart';
import 'package:memox_v4/presentation/features/study-session/widgets/stage_matching.dart';
import 'package:memox_v4/presentation/features/study-session/widgets/stage_review.dart';

import '../../../harness/provider_harness.dart';

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

/// A store with one brand-new card (drives the NewLearn 5-stage flow).
FakeStore _newStore() {
  final store = FakeStore();
  store.decks['d'] = _deck('d', 'Deck');
  store.cards['c1'] = _card('c1', 'd', '학교', 'school');
  store.srsByCard['c1'] = SrsState.newborn;
  return store;
}

/// A store with one card due for review (drives the due-review grading).
FakeStore _dueStore(DateTime now) {
  final store = FakeStore();
  store.decks['d'] = _deck('d', 'Deck');
  store.cards['c1'] = _card('c1', 'd', '학교', 'school');
  store.srsByCard['c1'] =
      SrsState(box: BoxLevel.firstBox, dueAt: now.subtract(const Duration(hours: 1)));
  return store;
}

void main() {
  Future<FakeHarness> pump(
    WidgetTester tester,
    FakeStore store, {
    required bool dark,
  }) async {
    tester.view.physicalSize = const Size(420, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final harness = FakeHarness(store: store);
    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dark ? AppTheme.dark : AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StudySessionScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return harness;
  }

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('stage 1 review renders the card + Next ($theme)', (tester) async {
      await pump(tester, _newStore(), dark: dark);
      expect(find.text('Stage 1 · Review'), findsOneWidget);
      expect(find.byType(StageReview), findsOneWidget);
      expect(find.text('학교'), findsOneWidget);
      expect(find.text('school'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  }

  testWidgets('Next advances stage 1 → stage 2 matching', (tester) async {
    await pump(tester, _newStore(), dark: false);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Stage 2 · Matching'), findsOneWidget);
    expect(find.byType(StageMatching), findsOneWidget);
  });

  testWidgets('a due card shows the due note and grade controls', (tester) async {
    final harness = FakeHarness(store: _newStore());
    await pump(tester, _dueStore(harness.clock.now()), dark: false);

    expect(find.text('Review · due cards'), findsOneWidget);
    expect(find.text('Relearn'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('an empty session shows the nothing-to-study state', (tester) async {
    final store = FakeStore()..decks['d'] = _deck('d', 'Deck');
    await pump(tester, store, dark: false);
    expect(find.text('Nothing to study'), findsOneWidget);
  });

  test('walking the 5 NewLearn stages graduates the card + completes', () async {
    final store = _newStore();
    final harness = FakeHarness(store: store);
    final container = ProviderContainer(overrides: harness.overrides);
    addTearDown(container.dispose);

    await container.read(studySessionControllerProvider.future);
    final notifier = container.read(studySessionControllerProvider.notifier);

    StudySessionState read() =>
        container.read(studySessionControllerProvider).requireValue;

    expect(read().current!.kind, StudyStageKind.review);
    notifier.advance(); // → matching

    final matching = read().current!;
    expect(matching.kind, StudyStageKind.matching);
    for (final tile in matching.terms) {
      notifier.selectTerm(tile.cardId);
      notifier.selectMeaning(tile.cardId);
    }

    final choice = read().current!;
    expect(choice.kind, StudyStageKind.choice);
    notifier.choose(choice.correctChoice); // → recall

    expect(read().current!.kind, StudyStageKind.recall);
    notifier.reveal();
    notifier.advance(); // → typing

    expect(read().current!.kind, StudyStageKind.typing);
    await notifier.checkTyping(); // graduates → complete

    expect(read().isComplete, isTrue);
    expect(store.srsByCard['c1']!.box, BoxLevel.firstBox); // graduated
  });

  test('grading a due card passes → promotes and advances', () async {
    final harness = FakeHarness(store: _newStore());
    final store = _dueStore(harness.clock.now());
    final container = ProviderContainer(
      overrides: FakeHarness(store: store).overrides,
    );
    addTearDown(container.dispose);

    await container.read(studySessionControllerProvider.future);
    final notifier = container.read(studySessionControllerProvider.notifier);

    final before = store.srsByCard['c1']!.box;
    expect(
      container.read(studySessionControllerProvider).requireValue.current!.kind,
      StudyStageKind.dueReview,
    );

    await notifier.gradeDue(ReviewGrade.pass);

    final after = store.srsByCard['c1']!.box;
    expect(after.value, greaterThan(before.value)); // promoted a box
  });

  test('a wrong choice shows the relearn note and keeps the step', () async {
    final store = _newStore()..cards['c2'] = _card('c2', 'd', '친구', 'friend');
    store.srsByCard['c2'] = SrsState.newborn;
    final container = ProviderContainer(
      overrides: FakeHarness(store: store).overrides,
    );
    addTearDown(container.dispose);

    await container.read(studySessionControllerProvider.future);
    final notifier = container.read(studySessionControllerProvider.notifier);
    notifier.advance(); // review → matching
    final matching =
        container.read(studySessionControllerProvider).requireValue.current!;
    for (final tile in matching.terms) {
      notifier.selectTerm(tile.cardId);
      notifier.selectMeaning(tile.cardId);
    }

    final choice =
        container.read(studySessionControllerProvider).requireValue.current!;
    expect(choice.kind, StudyStageKind.choice);
    final wrong = choice.correctChoice == 0 ? 1 : 0;
    notifier.choose(wrong);

    final state = container.read(studySessionControllerProvider).requireValue;
    expect(state.step.wrongChoice, isTrue);
    expect(state.current!.kind, StudyStageKind.choice); // did not advance
  });
}
