import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/app/di/tts_providers.dart';
import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/data/datasources/local/connection/database_connection.dart';
import 'package:memox_v4/data/datasources/local/drift/app_database.dart';
import 'package:memox_v4/domain/services/tts_service.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/flashcard/screens/flashcard_editor_screen.dart';

class _FakeTts implements TtsService {
  String? spokenText;
  String? spokenLang;

  @override
  Future<void> speak(String text, {String? languageCode}) async {
    spokenText = text;
    spokenLang = languageCode;
  }

  @override
  Future<void> stop() async {}
}

void main() {
  late AppDatabase db;
  late int deckId;
  late _FakeTts fake;

  setUp(() async {
    db = AppDatabase.forTesting(openInMemoryDatabase());
    fake = _FakeTts();
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

  Widget host() => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      ttsServiceProvider.overrideWithValue(fake),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: FlashcardEditorScreen(deckId: deckId, cardId: null),
    ),
  );

  testWidgets('the editor speaks the term in the source language', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('editorTermField')), 'mesa');
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('mx-node:flashcard-editor/audio-play')),
    );
    await tester.pump();

    expect(fake.spokenText, 'mesa');
    expect(fake.spokenLang, 'ko');
  });

  testWidgets('a blank term does not speak', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('mx-node:flashcard-editor/audio-play')),
    );
    await tester.pump();

    expect(fake.spokenText, isNull);
  });
}
