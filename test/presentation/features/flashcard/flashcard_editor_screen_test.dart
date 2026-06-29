import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/flashcard/screens/flashcard_editor_screen.dart';
import 'package:memox_v4/presentation/shared/widgets/buttons/mx_button.dart';

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
  });
  tearDown(() => db.close());

  Widget host({int? cardId}) => ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: FlashcardEditorScreen(deckId: deckId, cardId: cardId),
    ),
  );

  bool saveEnabled(WidgetTester tester) =>
      tester
          .widget<MxButton>(
            find.byKey(const ValueKey('mx-node:flashcard-editor/save')),
          )
          .onPressed !=
      null;

  testWidgets('Save is disabled until a valid term + meaning exist', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    expect(saveEnabled(tester), isFalse);

    await tester.enterText(find.byKey(const Key('editorTermField')), 'mesa');
    await tester.enterText(find.byKey(const Key('editorMeaningField')), 'bàn');
    await tester.pump();

    expect(saveEnabled(tester), isTrue);
  });

  testWidgets('validation error renders on the missing required field', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('editorMeaningField')), 'bàn');
    await tester.pump();

    expect(find.text('Term is required'), findsOneWidget);
    expect(saveEnabled(tester), isFalse);
  });

  testWidgets('D-020: duplicate term warns but still allows adding', (
    tester,
  ) async {
    await db
        .into(db.card)
        .insert(
          CardCompanion.insert(deckId: deckId, term: 'mesa', createdAt: 1),
        );

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('editorTermField')), 'mesa');
    await tester.enterText(find.byKey(const Key('editorMeaningField')), 'bàn');
    await tester.pump();

    await tester.tap(
      find.byKey(const ValueKey('mx-node:flashcard-editor/save')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editorDuplicateBanner')), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('mx-node:flashcard-editor/dup-add')),
    );
    await tester.pumpAndSettle();

    final cards = await db.select(db.card).get();
    expect(cards.where((c) => c.term == 'mesa').length, 2);
  });
}
