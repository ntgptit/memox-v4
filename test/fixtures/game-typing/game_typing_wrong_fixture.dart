// game-typing · wrong — golden-parity fixture.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_game_typing_harness.dart';

/// A wrong answer submitted → the wrong-answer feedback.
final StateFixture gameTypingWrongFixture = StateFixture(
  overrides: gameRoundOverrides(),
  drive: (tester) async {
    await tester.enterText(find.byType(TextField), 'zzzzz');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Check'));
  },
);
