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
import 'package:memox_v4/presentation/features/player/providers/player_providers.dart';
import 'package:memox_v4/presentation/features/player/screens/player_screen.dart';
import 'package:memox_v4/presentation/features/player/widgets/dots.dart';
import 'package:memox_v4/presentation/features/player/widgets/player_card.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_segmented_control.dart';

import '../../../harness/provider_harness.dart';

Deck _deck(String id, String name) =>
    (Deck.create(id: DeckId(id), name: name) as Ok<Deck>).value;

Card _card(String id, String deckId, String term, String meaning) =>
    (Card.create(
              id: CardId(id),
              deckId: DeckId(deckId),
              term: term,
              meanings: [
                (CardMeaning.create(
                          id: CardMeaningId('m-$id'),
                          language: 'en',
                          text: meaning,
                        )
                        as Ok<CardMeaning>)
                    .value,
              ],
            )
            as Ok<Card>)
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
          home: const PlayerScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return harness;
  }

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('playing: dots + card + transport, pause icon ($theme)', (
      tester,
    ) async {
      await pump(tester, dark: dark);
      expect(find.byType(PlayerDots), findsOneWidget);
      expect(find.byType(PlayerCard), findsOneWidget);
      expect(find.text('term1'), findsOneWidget);
      expect(find.text('means1'), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget); // playing by default
      expect(find.byIcon(Icons.skip_next), findsOneWidget);
    });
  }

  testWidgets('play/pause toggles the transport icon', (tester) async {
    await pump(tester, dark: false);

    await tester.tap(find.byIcon(Icons.pause));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('the speed button expands the segmented control', (tester) async {
    await pump(tester, dark: false);

    await tester.tap(find.byIcon(Icons.speed));
    await tester.pumpAndSettle();

    expect(find.byType(MxSegmentedControl), findsOneWidget);
    expect(find.text('×0.75'), findsOneWidget);
    expect(find.text('×1.5'), findsOneWidget);
  });

  testWidgets('the first card is read aloud on open', (tester) async {
    final harness = await pump(tester, dark: false);
    expect(harness.audio.lastSpoken, 'term1');
  });

  testWidgets('skipping past the last card reaches the end state', (
    tester,
  ) async {
    await pump(tester, dark: false, cards: 1);

    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.pumpAndSettle();

    expect(find.text('All played'), findsOneWidget);
    expect(find.text('Replay'), findsOneWidget);
  });

  testWidgets('empty store shows the empty state', (tester) async {
    await pump(tester, dark: false, cards: 0);
    expect(find.text('No cards to play'), findsOneWidget);
  });

  test('next speaks each card and clamps at the end', () async {
    final harness = FakeHarness(store: _store(cards: 2));
    final container = ProviderContainer(overrides: harness.overrides);
    addTearDown(container.dispose);

    await container.read(playerControllerProvider.future);
    final notifier = container.read(playerControllerProvider.notifier);

    notifier.next();
    expect(harness.audio.lastSpoken, 'term2');

    notifier.next(); // now at end
    expect(container.read(playerControllerProvider).requireValue.isEnd, isTrue);
    expect(
      container.read(playerControllerProvider).requireValue.playing,
      isFalse,
    );
  });

  test('setSpeed records the session rate and collapses the control', () async {
    final harness = FakeHarness(store: _store(cards: 1));
    final container = ProviderContainer(overrides: harness.overrides);
    addTearDown(container.dispose);

    await container.read(playerControllerProvider.future);
    final notifier = container.read(playerControllerProvider.notifier);

    notifier.toggleSpeedControl();
    notifier.setSpeed('1.5');

    final state = container.read(playerControllerProvider).requireValue;
    expect(state.speed, '1.5');
    expect(state.speedOpen, isFalse);
  });
}
