// game-recall · forgot — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_game_recall_harness.dart';

/// After grading a card "Forgot" (re-queues it).
final StateFixture gameRecallForgotFixture = StateFixture(
  overrides: gameRoundOverrides(),
  drive: (tester) async {
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forgot'));
  },
);
