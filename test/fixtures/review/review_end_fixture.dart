// review · end — golden-parity fixture.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_review_harness.dart';

/// Stepping past the last card → "All reviewed".
final StateFixture reviewEndFixture = StateFixture(
  overrides: roundOverrides(cards: 1),
  drive: (tester) async {
    await tester.tap(find.byIcon(Icons.chevron_right));
  },
);
