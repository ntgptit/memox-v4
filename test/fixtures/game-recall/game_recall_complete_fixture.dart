// game-recall · complete — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_game_recall_harness.dart';

/// Grade every card "Got it" to finish the round → completion screen.
final StateFixture gameRecallCompleteFixture = StateFixture(
  overrides: gameRoundOverrides(),
  drive: (tester) async {
    while (find.text('Show').evaluate().isNotEmpty) {
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();
    }
  },
);
