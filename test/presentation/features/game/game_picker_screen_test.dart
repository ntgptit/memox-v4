import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart'
    show AppDatabase, CardCompanion, DeckCompanion, LanguagePairCompanion;
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/game/screens/game_picker_screen.dart';

void main() {
  late AppDatabase db;
  late int deckId;

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    final pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
    deckId = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairId, name: 'Deck'));
    await db
        .into(db.card)
        .insert(CardCompanion.insert(deckId: deckId, term: 't', createdAt: 1));
  });
  tearDown(() => db.close());

  testWidgets('D-013: the picker offers exactly the four games', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: GamePickerScreen(nodeId: deckId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('gamePick-matching')), findsOneWidget);
    expect(find.byKey(const Key('gamePick-multipleChoice')), findsOneWidget);
    expect(find.byKey(const Key('gamePick-recall')), findsOneWidget);
    expect(find.byKey(const Key('gamePick-typing')), findsOneWidget);
  });
}
