// game-recall · revealed — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_game_recall_harness.dart';

/// Meaning revealed with the Forgot / Got it grade.
final StateFixture gameRecallRevealedFixture = StateFixture(
  overrides: gameRoundOverrides(),
  drive: (tester) async {
    await tester.tap(find.text('Show'));
  },
);
