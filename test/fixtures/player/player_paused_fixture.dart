// player · paused — golden-parity fixture.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_player_harness.dart';

/// Paused — transport shows the play icon.
final StateFixture playerPausedFixture = StateFixture(
  overrides: roundOverrides(),
  drive: (tester) async {
    await tester.tap(find.byIcon(Icons.pause));
  },
);
