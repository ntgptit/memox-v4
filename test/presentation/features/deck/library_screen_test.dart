import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/deck/screens/library_screen.dart';

void main() {
  late AppDatabase db;
  late int pairId;

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    pairId = await db
        .into(db.languagePair)
        .insert(
          LanguagePairCompanion.insert(sourceLang: 'ko', targetLang: 'vi'),
        );
  });
  tearDown(() => db.close());

  Widget host() => ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: LibraryScreen()),
    ),
  );

  testWidgets('empty library offers a create-deck CTA', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('mx-node:library/empty-deck')),
      findsOneWidget,
    );
  });

  testWidgets('a seeded root deck renders as a tile', (tester) async {
    final deckId = await db
        .into(db.deck)
        .insert(DeckCompanion.insert(pairId: pairId, name: 'Verbs'));

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.byKey(Key('deckTile-$deckId')), findsOneWidget);
    expect(find.text('Verbs'), findsOneWidget);
  });
}
