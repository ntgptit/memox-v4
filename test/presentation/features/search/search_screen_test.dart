import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/domain/entities/card.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/repositories/card_repository.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/search/screens/search_screen.dart';
import 'package:memox_v4/presentation/features/search/widgets/result_row.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_chip.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

import '../../../harness/provider_harness.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required bool dark,
    CardRepository? cardRepository,
  }) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final harness = FakeHarness(cardRepository: cardRepository);
    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dark ? AppTheme.dark : AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SearchScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('empty-recent: no query, no history → hint ($theme)',
        (tester) async {
      await pump(tester, dark: dark);
      expect(find.text('Search your cards'), findsOneWidget);
      expect(find.byType(ResultRow), findsNothing);
    });

    testWidgets('results: a query lists matching cards + chips ($theme)',
        (tester) async {
      await pump(tester, dark: dark);
      // 'con' matches the Vietnamese meanings (con mèo / con chó).
      await tester.enterText(find.byType(TextField), 'con');
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget); // filter chips
      expect(find.byType(ResultRow), findsNWidgets(2));
    });

    testWidgets('no-results: an unmatched query → no matches ($theme)',
        (tester) async {
      await pump(tester, dark: dark);
      await tester.enterText(find.byType(TextField), 'zzzzz');
      await tester.pumpAndSettle();

      expect(find.text('No matches'), findsOneWidget);
      expect(find.byType(ResultRow), findsNothing);
    });
  }

  testWidgets('filtered: a status chip narrows the results', (tester) async {
    await pump(tester, dark: false);
    await tester.enterText(find.byType(TextField), 'con'); // due + new
    await tester.pumpAndSettle();
    expect(find.byType(ResultRow), findsNWidgets(2));

    await tester.tap(find.widgetWithText(MxChip, 'New'));
    await tester.pumpAndSettle();
    expect(find.byType(ResultRow), findsOneWidget); // only the new card
  });

  testWidgets('loading: an in-flight search shows skeletons', (tester) async {
    await pump(tester, dark: false);
    await tester.enterText(find.byType(TextField), 'con');
    await tester.pump(); // one frame — search future still running

    expect(find.byType(MxSkeleton), findsWidgets);
  });

  testWidgets('error: a failed search surfaces the error state', (tester) async {
    await pump(tester, dark: false, cardRepository: _ErroringCardRepository());
    await tester.enterText(find.byType(TextField), 'con');
    await tester.pumpAndSettle();

    expect(find.text('Search failed'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('clearing a search records it as recent', (tester) async {
    await pump(tester, dark: false);
    await tester.enterText(find.byType(TextField), 'con');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close)); // clear
    await tester.pumpAndSettle();

    expect(find.text('RECENT'), findsOneWidget);
    expect(find.text('con'), findsOneWidget);
  });
}

/// Fails the card search → the results provider surfaces an error.
class _ErroringCardRepository implements CardRepository {
  @override
  Future<Result<List<Card>>> search(String query, {DeckId? within}) async =>
      const Err(PersistenceFailure('search failed'));
  @override
  Stream<List<Card>> watchByDeck(DeckId deckId) => const Stream.empty();
  @override
  Future<Result<Card>> getById(CardId id) => throw UnimplementedError();
  @override
  Future<Result<Card>> save(Card card) => throw UnimplementedError();
  @override
  Future<Result<void>> delete(CardId id) => throw UnimplementedError();
  @override
  Future<Result<void>> setHidden(CardId id, {required bool hidden}) =>
      throw UnimplementedError();
}
