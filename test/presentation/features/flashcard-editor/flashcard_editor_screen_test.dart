import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memox_v4/core/theme/app_theme.dart';
import 'package:memox_v4/data/providers/data_providers.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/flashcard-editor/providers/editor_providers.dart';
import 'package:memox_v4/presentation/features/flashcard-editor/screens/flashcard_editor_screen.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';

import '../../../harness/provider_harness.dart';

void main() {
  Future<FakeHarness> pump(
    WidgetTester tester, {
    required bool dark,
    String? cardId,
  }) async {
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final harness = FakeHarness();
    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dark ? AppTheme.dark : AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FlashcardEditorScreen(cardId: cardId),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return harness;
  }

  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('create: blank form, disabled save ($theme)', (tester) async {
      await pump(tester, dark: dark);

      expect(find.text('New card'), findsOneWidget);
      expect(find.text('Add a secondary-language meaning'), findsOneWidget);
      expect(find.text('Hide card'), findsOneWidget);
      final save = tester.widget<MxButton>(find.widgetWithText(MxButton, 'Save'));
      expect(save.onPressed, isNull);
    });
  }

  testWidgets('edit: prefilled from the loaded card', (tester) async {
    await pump(tester, dark: false, cardId: 'card-1'); // 사과 / quả táo

    expect(find.text('Edit card'), findsOneWidget);
    expect(find.text('사과'), findsOneWidget);
    final save = tester.widget<MxButton>(find.widgetWithText(MxButton, 'Save'));
    expect(save.onPressed, isNotNull);
  });

  testWidgets('validation: emptying a required field shows the error',
      (tester) async {
    await pump(tester, dark: false);

    final termField = find.byType(TextField).first;
    await tester.enterText(termField, 'x');
    await tester.pumpAndSettle();
    await tester.enterText(termField, '');
    await tester.pumpAndSettle();

    expect(find.text('Term is required'), findsOneWidget);
  });

  testWidgets('multi-meaning: the add button reveals a secondary field',
      (tester) async {
    await pump(tester, dark: false);

    expect(find.text('Secondary meaning'), findsNothing);
    await tester.tap(find.text('Add a secondary-language meaning'));
    await tester.pumpAndSettle();

    expect(find.text('Secondary meaning'), findsOneWidget);
  });

  testWidgets('audio: the play button speaks the term', (tester) async {
    final harness = await pump(tester, dark: false, cardId: 'card-1');

    await tester.tap(find.byIcon(Icons.volume_up));
    await tester.pumpAndSettle();

    expect(harness.audio.lastSpoken, '사과');
  });

  test('save creates a card in the first deck', () async {
    final harness = FakeHarness();
    final container = ProviderContainer(overrides: harness.overrides);
    addTearDown(container.dispose);

    await container.read(editorControllerProvider(null).future);
    final notifier = container.read(editorControllerProvider(null).notifier);
    await notifier.setTerm('신규');
    notifier.setMeaning('brand new');

    expect(await notifier.save(), isTrue);
    final cards = await container
        .read(cardRepositoryProvider)
        .watchByDeck(const DeckId('deck-root'))
        .first;
    expect(cards.any((c) => c.term == '신규'), isTrue);
  });
}
