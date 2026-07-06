// game-matching · complete — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_game_matching_harness.dart';

/// Match all five pairs → round complete.
final StateFixture gameMatchingCompleteFixture = StateFixture(
  overrides: gameRoundOverrides(),
  drive: (tester) async {
    for (var i = 1; i <= 5; i++) {
      await tester.tap(find.text('means$i'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('term$i'));
      await tester.pumpAndSettle();
    }
  },
);
