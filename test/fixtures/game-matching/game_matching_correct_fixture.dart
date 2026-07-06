// game-matching · correct — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_game_matching_harness.dart';

/// A correct pair matched (means1 ↔ term1).
final StateFixture gameMatchingCorrectFixture = StateFixture(
  overrides: gameRoundOverrides(),
  drive: (tester) async {
    await tester.tap(find.text('means1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('term1'));
  },
);
