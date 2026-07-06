// game-matching · selected — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_game_matching_harness.dart';

/// One tile selected, awaiting its pair.
final StateFixture gameMatchingSelectedFixture = StateFixture(
  overrides: gameRoundOverrides(),
  drive: (tester) async {
    await tester.tap(find.text('means1'));
  },
);
