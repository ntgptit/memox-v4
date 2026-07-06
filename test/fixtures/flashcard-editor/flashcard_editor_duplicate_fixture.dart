// flashcard-editor · duplicate — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/features/flashcard-editor/screens/flashcard_editor_screen.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// Editing card-1 and retyping a sibling's term (고양이 = card-2, same deck)
/// trips the soft-duplicate detector → the DupBanner warning (D-020).
final StateFixture flashcardEditorDuplicateFixture = StateFixture(
  overrides: FakeHarness().overrides,
  home: const FlashcardEditorScreen(cardId: 'card-1'),
  drive: (tester) async {
    await tester.enterText(find.byType(TextField).first, '고양이');
    await tester.pumpAndSettle();
  },
);
