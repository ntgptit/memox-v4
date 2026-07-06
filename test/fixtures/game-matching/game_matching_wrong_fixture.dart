// game-matching · wrong — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_game_matching_harness.dart';

/// A wrong pair (means1 ↔ term2).
final StateFixture gameMatchingWrongFixture = StateFixture(
  overrides: gameRoundOverrides(),
  drive: (tester) async {
    await tester.tap(find.text('means1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('term2'));
  },
);
