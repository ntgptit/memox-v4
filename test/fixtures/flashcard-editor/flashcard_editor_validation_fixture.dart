// flashcard-editor · validation — golden-parity fixture.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/features/flashcard-editor/screens/flashcard_editor_screen.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// Emptying the required term field surfaces the validation error.
final StateFixture flashcardEditorValidationFixture = StateFixture(
  overrides: FakeHarness().overrides,
  home: const FlashcardEditorScreen(cardId: 'card-1'),
  drive: (tester) async {
    await tester.enterText(find.byType(TextField).first, '');
  },
);
