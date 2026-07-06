// game-recall · remembered — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_game_recall_harness.dart';

/// After grading a card "Got it" (advances to the next card).
final StateFixture gameRecallRememberedFixture = StateFixture(
  overrides: gameRoundOverrides(),
  drive: (tester) async {
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Got it'));
  },
);
