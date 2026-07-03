import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/card_meaning.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/game-typing/providers/typing_providers.dart';
import 'package:memox_v4/presentation/features/game-typing/screens/game_typing_screen.dart';
import 'package:memox_v4/presentation/features/game-typing/widgets/char_compare.dart';
import 'package:memox_v4/presentation/features/game-typing/widgets/input_box.dart';

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

/// A single-card store so the term ('친구') is deterministic for typing.
FakeStore _store() {
  final store = FakeStore();
  store.decks['d'] = _deck('d', 'Deck');
  store.cards['c1'] = _card('c1', 'd', '친구', 'friend');
  return store;
}

void main() {
  Future<FakeHarness> pump(WidgetTester tester, {required bool dark}) async {
    tester.view.physicalSize = const Size(420, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final harness = FakeHarness(store: _store());
    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dark ? AppTheme.dark : AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const GameTypingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return harness;
  }

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('waiting: meaning + input + Help/Check, Check disabled ($theme)',
        (tester) async {
      await pump(tester, dark: dark);
      expect(find.text('friend'), findsOneWidget);
      expect(find.byType(InputBox), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Help'), findsOneWidget);
      expect(find.text('Check'), findsOneWidget);

      final check = tester.widget<InputBox>(find.byType(InputBox));
      expect(check.tone, InputBoxTone.neutral);
    });
  }

  testWidgets('Help reveals the hint note', (tester) async {
    await pump(tester, dark: false);
    await tester.tap(find.text('Help'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Hint:'), findsOneWidget);
  });

  testWidgets('a correct answer tints the input and reveals Next', (tester) async {
    await pump(tester, dark: false);

    await tester.enterText(find.byType(TextField), '친구');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();

    expect(find.text('Next'), findsOneWidget);
    final box = tester.widget<InputBox>(find.byType(InputBox));
    expect(box.tone, InputBoxTone.correct);
  });

  testWidgets('a wrong answer shows the diff, answer, and Correct/Retry',
      (tester) async {
    await pump(tester, dark: false);

    await tester.enterText(find.byType(TextField), '친고');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();

    expect(find.byType(CharCompare), findsOneWidget);
    expect(find.text('Correct'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    final box = tester.widget<InputBox>(find.byType(InputBox));
    expect(box.tone, InputBoxTone.wrong);
  });

  test('check → next through the queue completes the round', () async {
    final store = FakeStore();
    store.decks['d'] = _deck('d', 'Deck');
    store.cards['c1'] = _card('c1', 'd', 'aaa', 'one');
    store.cards['c2'] = _card('c2', 'd', 'bbb', 'two');
    final harness = FakeHarness(store: store);
    final container = ProviderContainer(overrides: harness.overrides);
    addTearDown(container.dispose);

    final start = await container.read(typingControllerProvider.future);
    final notifier = container.read(typingControllerProvider.notifier);
    for (var i = 0; i < start.total; i++) {
      final term = container.read(typingControllerProvider).requireValue.current!.term;
      notifier.check(term);
      notifier.next();
    }

    final done = container.read(typingControllerProvider).requireValue;
    expect(done.isComplete, isTrue);
    expect(done.reviewed, start.total);
  });

  test('retry after a wrong grade re-opens the same card for input', () async {
    final harness = FakeHarness(store: _store());
    final container = ProviderContainer(overrides: harness.overrides);
    addTearDown(container.dispose);

    await container.read(typingControllerProvider.future);
    final notifier = container.read(typingControllerProvider.notifier);
    final term = container.read(typingControllerProvider).requireValue.current!.term;

    notifier.check('wrong-answer');
    expect(
      container.read(typingControllerProvider).requireValue.outcome,
      TypingOutcome.wrong,
    );

    notifier.retry();
    final after = container.read(typingControllerProvider).requireValue;
    expect(after.outcome, TypingOutcome.none);
    expect(after.current!.term, term); // same card, not advanced
    expect(after.reviewed, 0);
  });
}
