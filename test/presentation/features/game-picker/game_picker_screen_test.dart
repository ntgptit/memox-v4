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
import 'package:memox_v4/presentation/features/game-picker/screens/game_picker_screen.dart';
import 'package:memox_v4/presentation/features/game-picker/widgets/game_option.dart';

import '../../../harness/provider_harness.dart';

Deck _deck(String id, String name) =>
    (Deck.create(id: DeckId(id), name: name) as Ok<Deck>).value;

Card _card(String id, String deckId, String term) => (Card.create(
      id: CardId(id),
      deckId: DeckId(deckId),
      term: term,
      meanings: [
        (CardMeaning.create(id: CardMeaningId('m-$id'), language: 'en', text: 'means $id')
                as Ok<CardMeaning>)
            .value,
      ],
    ) as Ok<Card>)
    .value;

/// A store with a deck holding 5 cards (enough to play in the All-cards source).
FakeStore _fullStore() {
  final store = FakeStore();
  store.decks['d'] = _deck('d', 'Deck');
  for (var i = 1; i <= 5; i++) {
    store.cards['c$i'] = _card('c$i', 'd', 'term$i');
  }
  return store;
}

void main() {
  Future<void> pump(WidgetTester tester, {required bool dark, FakeStore? store}) async {
    tester.view.physicalSize = const Size(400, 1600);
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
          home: const GamePickerScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('not-enough: too few words disables the games ($theme)',
        (tester) async {
      await pump(tester, dark: dark); // seed has < 4 due cards

      expect(find.text('This set needs at least 4 words to play.'), findsOneWidget);
      final matching =
          tester.widget<GameOption>(find.widgetWithText(GameOption, 'Matching'));
      expect(matching.onPressed, isNull);
    });
  }

  testWidgets('scope sheet opens from the scope card', (tester) async {
    await pump(tester, dark: false);

    await tester.tap(find.text('Card source'));
    await tester.pumpAndSettle();

    expect(find.text('By schedule'), findsWidgets);
    expect(find.text('All cards'), findsOneWidget);
    expect(find.text('Unlearned only'), findsOneWidget);
  });

  testWidgets('choosing All cards with enough words enables the games',
      (tester) async {
    await pump(tester, dark: false, store: _fullStore());

    await tester.tap(find.text('Card source'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All cards'));
    await tester.pumpAndSettle();

    expect(find.text('This set needs at least 4 words to play.'), findsNothing);
    final matching =
        tester.widget<GameOption>(find.widgetWithText(GameOption, 'Matching'));
    expect(matching.onPressed, isNotNull);
  });
}
