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
import 'package:memox_v4/presentation/features/game-mc/providers/mc_providers.dart';
import 'package:memox_v4/presentation/features/game-mc/screens/game_mc_screen.dart';
import 'package:memox_v4/presentation/features/game-mc/widgets/prompt_card.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_choice_option.dart';

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

FakeStore _store() {
  final store = FakeStore();
  store.decks['d'] = _deck('d', 'Deck');
  for (var i = 1; i <= 5; i++) {
    store.cards['c$i'] = _card('c$i', 'd', 'term$i', 'means$i');
  }
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
          home: const GameMcScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return harness;
  }

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('waiting: prompt + four choices ($theme)', (tester) async {
      await pump(tester, dark: dark);
      expect(find.byType(PromptCard), findsOneWidget);
      expect(find.byType(MxChoiceOption), findsNWidgets(4));
    });
  }

  testWidgets('answering locks the choices and reveals Next', (tester) async {
    await pump(tester, dark: false);

    await tester.tap(find.byType(MxChoiceOption).first);
    await tester.pumpAndSettle();

    expect(find.text('Next'), findsOneWidget);
    final chosen = tester.widget<MxChoiceOption>(find.byType(MxChoiceOption).first);
    expect(chosen.onPressed, isNull); // locked
  });

  testWidgets('audio button speaks the prompt term', (tester) async {
    final harness = await pump(tester, dark: false);

    await tester.tap(find.byIcon(Icons.volume_up));
    await tester.pumpAndSettle();

    expect(harness.audio.lastSpoken, isNotNull);
    expect(harness.audio.lastSpoken, startsWith('term'));
  });

  test('answering every question correctly completes the round', () async {
    final harness = FakeHarness(store: _store());
    final container = ProviderContainer(overrides: harness.overrides);
    addTearDown(container.dispose);

    await container.read(mcControllerProvider.future);
    final notifier = container.read(mcControllerProvider.notifier);
    for (var i = 0; i < 5; i++) {
      final state = container.read(mcControllerProvider).requireValue;
      notifier.answer(state.current.correctIndex);
      notifier.next();
    }

    final done = container.read(mcControllerProvider).requireValue;
    expect(done.isComplete, isTrue);
    expect(done.correctCount, 5);
  });
}
