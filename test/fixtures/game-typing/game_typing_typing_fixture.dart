// game-typing · typing — golden-parity fixture.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_game_typing_harness.dart';

/// The learner has typed into the answer field (Check now enabled).
final StateFixture gameTypingTypingFixture = StateFixture(
  overrides: gameRoundOverrides(),
  drive: (tester) async {
    await tester.enterText(find.byType(TextField), 'te');
  },
);
