// flashcard-editor · audio — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import 'package:memox_v4/presentation/features/flashcard-editor/screens/flashcard_editor_screen.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// The TTS pronounce control. In Flutter the "Audio: Auto" row + play button is a
/// permanent part of the editor form (not a data-gated state), so this renders
/// the populated edit form where the control sits alongside real content.
final StateFixture flashcardEditorAudioFixture = StateFixture(
  overrides: FakeHarness().overrides,
  home: const FlashcardEditorScreen(cardId: 'card-1'),
);
