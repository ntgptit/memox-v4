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
import 'package:memox_v4/presentation/features/game-matching/screens/game_matching_screen.dart';
import 'package:memox_v4/presentation/features/game-matching/widgets/tile.dart';

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
  Future<void> pump(WidgetTester tester, {required bool dark}) async {
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
          home: const GameMatchingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> matchPair(WidgetTester tester, int i) async {
    await tester.tap(find.text('means$i')); // left meaning
    await tester.pumpAndSettle();
    await tester.tap(find.text('term$i')); // matching right term
    await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('playing: two columns of tiles ($theme)', (tester) async {
      await pump(tester, dark: dark);
      expect(find.byType(MatchTileView), findsNWidgets(10)); // 5 + 5
    });
  }

  testWidgets('correct: a matched pair is removed', (tester) async {
    await pump(tester, dark: false);

    await matchPair(tester, 1);

    // The matched tiles are hidden (their text is gone).
    expect(find.text('means1'), findsNothing);
    expect(find.text('term1'), findsNothing);
    // The others remain.
    expect(find.text('means2'), findsOneWidget);
  });

  testWidgets('wrong: a mismatch leaves both tiles in play', (tester) async {
    await pump(tester, dark: false);

    await tester.tap(find.text('means1')); // select left
    await tester.pumpAndSettle();
    await tester.tap(find.text('term2')); // wrong right
    await tester.pumpAndSettle();

    // Nothing matched — both are still present.
    expect(find.text('means1'), findsOneWidget);
    expect(find.text('term2'), findsOneWidget);
  });

  testWidgets('complete: matching every pair shows the complete state',
      (tester) async {
    await pump(tester, dark: false);

    for (var i = 1; i <= 5; i++) {
      await matchPair(tester, i);
    }

    expect(find.text('Round complete!'), findsOneWidget);
    expect(find.text('Next round'), findsOneWidget);
  });
}
