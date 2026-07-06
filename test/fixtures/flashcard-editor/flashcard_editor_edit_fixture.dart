// flashcard-editor · edit — golden-parity fixture.
import 'package:memox_v4/presentation/features/flashcard-editor/screens/flashcard_editor_screen.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// Editing an existing card (card-1 = 사과 / quả táo), prefilled.
final StateFixture flashcardEditorEditFixture = StateFixture(
  overrides: FakeHarness().overrides,
  home: const FlashcardEditorScreen(cardId: 'card-1'),
);
