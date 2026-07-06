// player · speed — golden-parity fixture.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_player_harness.dart';

/// The speed segmented control expanded.
final StateFixture playerSpeedFixture = StateFixture(
  overrides: roundOverrides(),
  drive: (tester) async {
    await tester.tap(find.byIcon(Icons.speed));
  },
);
