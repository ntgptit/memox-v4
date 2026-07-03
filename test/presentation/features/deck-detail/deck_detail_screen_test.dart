import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/data/fakes/fake_store.dart';
import 'package:memox_v4/domain/entities/deck.dart';
import 'package:memox_v4/domain/entities/deck_stats.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/deck-detail/screens/deck_detail_screen.dart';
import 'package:memox_v4/presentation/features/deck-detail/widgets/flashcard_row.dart';
import 'package:memox_v4/presentation/features/deck-detail/widgets/sub_deck_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_fab.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

import '../../../harness/provider_harness.dart';

Deck _deck(String id, String name) =>
    (Deck.create(id: DeckId(id), name: name) as Ok<Deck>).value;

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required bool dark,
    required String deckId,
    FakeStore? store,
    DeckRepository? deckRepository,
    bool settle = true,
  }) async {
    tester.view.physicalSize = const Size(400, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final harness = FakeHarness(store: store, deckRepository: deckRepository);
    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dark ? AppTheme.dark : AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DeckDetailScreen(deckId: deckId),
        ),
      ),
    );
    if (settle) await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('loaded (cards): a leaf deck lists its cards + FAB ($theme)',
        (tester) async {
      await pump(tester, dark: dark, deckId: 'deck-food');

      expect(find.byType(FlashcardRow), findsNWidgets(3)); // seeded cards
      expect(find.byType(MxFab), findsOneWidget);
      expect(find.text('CARDS'), findsOneWidget);
    });

    testWidgets('loaded (sub-decks): a parent deck lists sub-decks ($theme)',
        (tester) async {
      await pump(tester, dark: dark, deckId: 'deck-root');

      expect(find.byType(SubDeckCard), findsOneWidget); // deck-food
      expect(find.text('SUB-DECKS'), findsOneWidget);
    });

    testWidgets('empty: a deck with no sub-decks or cards ($theme)',
        (tester) async {
      final store = FakeStore()..decks['solo'] = _deck('solo', 'Solo');
      await pump(tester, dark: dark, deckId: 'solo', store: store);

      expect(find.text('Empty deck'), findsOneWidget);
      expect(find.byType(FlashcardRow), findsNothing);
    });

    testWidgets('loading: unresolved read shows skeletons ($theme)',
        (tester) async {
      await pump(
        tester,
        dark: dark,
        deckId: 'deck-food',
        deckRepository: _StuckDeckRepository(),
        settle: false,
      );
      await tester.pump();

      expect(find.byType(MxSkeleton), findsWidgets);
      expect(find.byType(FlashcardRow), findsNothing);
    });

    testWidgets('error: an unknown deck id surfaces the error state ($theme)',
        (tester) async {
      await pump(tester, dark: dark, deckId: 'does-not-exist');

      expect(find.text("Couldn't load this deck"), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  }

  testWidgets('search: typing filters the cards; no match shows no-results',
      (tester) async {
    await pump(tester, dark: false, deckId: 'deck-food');

    // 'con' matches the Vietnamese meanings (con mèo / con chó).
    await tester.enterText(find.byType(TextField), 'con');
    await tester.pumpAndSettle();

    expect(find.text('All'), findsOneWidget); // filter chips appear
    expect(find.byType(FlashcardRow), findsNWidgets(2));

    await tester.enterText(find.byType(TextField), 'zzzzz');
    await tester.pumpAndSettle();

    expect(find.text('No cards found'), findsOneWidget);
    expect(find.byType(FlashcardRow), findsNothing);
  });

  testWidgets('card tap opens the card-actions sheet', (tester) async {
    await pump(tester, dark: false, deckId: 'deck-food');

    await tester.tap(find.byType(FlashcardRow).first);
    await tester.pumpAndSettle();

    expect(find.text('Edit card'), findsOneWidget);
    expect(find.text('Delete card'), findsOneWidget);
  });

  testWidgets('overflow opens the deck menu (move / delete)', (tester) async {
    await pump(tester, dark: false, deckId: 'deck-food');

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Move'), findsOneWidget);
    expect(find.text('Delete deck'), findsOneWidget);
  });
}

/// Never completes its lookup → the provider stays loading.
class _StuckDeckRepository implements DeckRepository {
  @override
  Future<Result<Deck>> getById(DeckId id) => Completer<Result<Deck>>().future;
  @override
  Stream<List<Deck>> watchChildren(DeckId? parentId) => const Stream.empty();
  @override
  Future<Result<DeckStats>> statsFor(DeckId id) => throw UnimplementedError();
  @override
  Future<Result<Deck>> save(Deck deck) => throw UnimplementedError();
  @override
  Future<Result<void>> delete(DeckId id) => throw UnimplementedError();
}
