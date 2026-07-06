// deck-detail · card-actions — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/features/deck-detail/widgets/flashcard_row.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

final StateFixture deckDetailCardActionsFixture = StateFixture(
  overrides: FakeHarness().overrides,
  drive: (tester) async {
    await tester.tap(find.byType(FlashcardRow).first);
  },
);
