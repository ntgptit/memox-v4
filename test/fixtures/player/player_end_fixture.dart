// player · end — golden-parity fixture.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_player_harness.dart';

/// Skipping past the last card → the end screen.
final StateFixture playerEndFixture = StateFixture(
  overrides: roundOverrides(cards: 1),
  drive: (tester) async {
    await tester.tap(find.byIcon(Icons.skip_next));
  },
);
