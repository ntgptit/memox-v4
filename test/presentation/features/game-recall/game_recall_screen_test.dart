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
import 'package:memox_v4/presentation/features/game-recall/providers/recall_providers.dart';
import 'package:memox_v4/presentation/features/game-recall/screens/game_recall_screen.dart';
import 'package:memox_v4/presentation/features/game-recall/widgets/meaning_panel.dart';
import 'package:memox_v4/presentation/features/game-recall/widgets/term_card.dart';

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
          home: const GameRecallScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return harness;
  }

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('before-reveal: term card + hidden meaning + Show ($theme)',
        (tester) async {
      await pump(tester, dark: dark);
      expect(find.byType(TermCard), findsOneWidget);
      final panel = tester.widget<MeaningPanel>(find.byType(MeaningPanel));
      expect(panel.revealed, isFalse);
      expect(find.text('Show'), findsOneWidget);
      expect(find.text('Got it'), findsNothing);
    });
  }

  testWidgets('Show reveals the meaning and the Forgot / Got it grade',
      (tester) async {
    await pump(tester, dark: false);

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    final panel = tester.widget<MeaningPanel>(find.byType(MeaningPanel));
    expect(panel.revealed, isTrue);
    expect(find.text('Forgot'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
    expect(find.text('Show'), findsNothing);
  });

  testWidgets('audio button speaks the current term', (tester) async {
    final harness = await pump(tester, dark: false);

    await tester.tap(find.byIcon(Icons.volume_up));
    await tester.pumpAndSettle();

    expect(harness.audio.lastSpoken, isNotNull);
    expect(harness.audio.lastSpoken, startsWith('term'));
  });

  test('Got it through the whole queue completes the round', () async {
    final harness = FakeHarness(store: _store());
    final container = ProviderContainer(overrides: harness.overrides);
    addTearDown(container.dispose);

    final start = await container.read(recallControllerProvider.future);
    final notifier = container.read(recallControllerProvider.notifier);
    for (var i = 0; i < start.total; i++) {
      notifier.reveal();
      notifier.gotIt();
    }

    final done = container.read(recallControllerProvider).requireValue;
    expect(done.isComplete, isTrue);
    expect(done.reviewed, start.total);
  });

  test('Forgot re-queues the card to the end (round not shrinking)', () async {
    final harness = FakeHarness(store: _store());
    final container = ProviderContainer(overrides: harness.overrides);
    addTearDown(container.dispose);

    final start = await container.read(recallControllerProvider.future);
    final notifier = container.read(recallControllerProvider.notifier);
    final firstTerm = start.current!.term;

    notifier.reveal();
    notifier.forgot();

    final after = container.read(recallControllerProvider).requireValue;
    expect(after.queue.length, start.queue.length); // not removed
    expect(after.revealed, isFalse);
    expect(after.current!.term, isNot(firstTerm)); // moved to the back
    expect(after.queue.last.term, firstTerm);
  });
}
