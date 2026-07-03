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
import 'package:memox_v4/presentation/features/review/providers/review_providers.dart';
import 'package:memox_v4/presentation/features/review/screens/review_screen.dart';
import 'package:memox_v4/presentation/features/review/widgets/meaning_card.dart';
import 'package:memox_v4/presentation/features/review/widgets/term_card.dart';

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

FakeStore _store({int cards = 3}) {
  final store = FakeStore();
  store.decks['d'] = _deck('d', 'Deck');
  for (var i = 1; i <= cards; i++) {
    store.cards['c$i'] = _card('c$i', 'd', 'term$i', 'means$i');
  }
  return store;
}

void main() {
  Future<FakeHarness> pump(
    WidgetTester tester, {
    required bool dark,
    int cards = 3,
  }) async {
    tester.view.physicalSize = const Size(420, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final harness = FakeHarness(store: _store(cards: cards));
    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dark ? AppTheme.dark : AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ReviewScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return harness;
  }

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('browsing: meaning + term + position ($theme)', (tester) async {
      await pump(tester, dark: dark);
      expect(find.byType(MeaningCard), findsOneWidget);
      expect(find.byType(TermCard), findsOneWidget);
      expect(find.text('means1'), findsOneWidget);
      expect(find.text('term1'), findsOneWidget);
      expect(find.text('1/3'), findsOneWidget);
    });
  }

  testWidgets('the edit icon opens the inline editor with Save/Cancel',
      (tester) async {
    await pump(tester, dark: false);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('audio button speaks the current term', (tester) async {
    final harness = await pump(tester, dark: false);

    await tester.tap(find.byIcon(Icons.volume_up));
    await tester.pumpAndSettle();

    expect(harness.audio.lastSpoken, 'term1');
  });

  testWidgets('stepping past the last card reaches the end state',
      (tester) async {
    await pump(tester, dark: false, cards: 1);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    expect(find.text('All reviewed'), findsOneWidget);
    expect(find.text('Study now'), findsOneWidget);
  });

  testWidgets('empty store shows the empty state', (tester) async {
    await pump(tester, dark: false, cards: 0);
    expect(find.text('No cards to review'), findsOneWidget);
  });

  test('next/prev walk the card list and clamp at the ends', () async {
    final harness = FakeHarness(store: _store(cards: 2));
    final container = ProviderContainer(overrides: harness.overrides);
    addTearDown(container.dispose);

    await container.read(reviewControllerProvider.future);
    final notifier = container.read(reviewControllerProvider.notifier);

    notifier.prev(); // clamps at 0
    expect(container.read(reviewControllerProvider).requireValue.index, 0);

    notifier.next();
    notifier.next(); // now at end (index == 2)
    expect(container.read(reviewControllerProvider).requireValue.isEnd, isTrue);

    notifier.next(); // clamps at end
    expect(container.read(reviewControllerProvider).requireValue.index, 2);
  });

  test('saving an inline edit persists the new meaning', () async {
    final harness = FakeHarness(store: _store(cards: 1));
    final container = ProviderContainer(overrides: harness.overrides);
    addTearDown(container.dispose);

    await container.read(reviewControllerProvider.future);
    final notifier = container.read(reviewControllerProvider.notifier);

    notifier.startEdit();
    await notifier.saveEdit('updated meaning');

    final state = container.read(reviewControllerProvider).requireValue;
    expect(state.editing, isFalse);
    expect(state.current!.meanings.first.text, 'updated meaning');
  });
}
