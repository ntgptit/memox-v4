// deck-detail · card-actions — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/features/deck-detail/widgets/flashcard_row.dart';

import '../_fixture.dart';
import '_deck_detail_harness.dart';

final StateFixture deckDetailCardActionsFixture = StateFixture(
  overrides: deckDetailKitOverrides(),
  drive: (tester) async {
    await tester.tap(find.byType(FlashcardRow).first);
  },
);
