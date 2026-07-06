// flashcard-editor · create — golden-parity fixture.
import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// Blank new-card form (cardId null → the golden's default widget).
final StateFixture flashcardEditorCreateFixture =
    StateFixture(overrides: FakeHarness().overrides);
