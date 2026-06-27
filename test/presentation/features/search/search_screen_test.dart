import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/search/screens/search_screen.dart';

void main() {
  late AppDatabase db;
  late int cardId;

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    final pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
    final deckId = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairId, name: 'Deck'));
    cardId = await db
        .into(db.card)
        .insert(
          CardCompanion.insert(deckId: deckId, term: 'xin', createdAt: 1),
        );
    await db
        .into(db.cardMeaning)
        .insert(
          CardMeaningCompanion.insert(
            cardId: cardId,
            lang: 'vi',
            content: 'please',
          ),
        );
  });
  tearDown(() => db.close());

  Widget host() => ProviderScope(
    overrides: <Override>[databaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SearchScreen(),
    ),
  );

  testWidgets('a matching query lists the card', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('searchField')), 'xin');
    await tester.pumpAndSettle();

    expect(find.byKey(Key('searchResult-$cardId')), findsOneWidget);
  });

  testWidgets('a non-matching query shows the no-results state', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('searchField')), 'zzz');
    await tester.pumpAndSettle();

    expect(find.textContaining('zzz'), findsWidgets);
  });
}
