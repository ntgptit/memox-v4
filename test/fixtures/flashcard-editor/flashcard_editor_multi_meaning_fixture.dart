// flashcard-editor · multi-meaning — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/features/flashcard-editor/screens/flashcard_editor_screen.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// The secondary-meaning field revealed via the add button.
final StateFixture flashcardEditorMultiMeaningFixture = StateFixture(
  overrides: FakeHarness().overrides,
  home: const FlashcardEditorScreen(cardId: 'card-1'),
  drive: (tester) async {
    await tester.tap(find.text('Add a secondary-language meaning'));
  },
);
