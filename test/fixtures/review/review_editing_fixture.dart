// review · editing — golden-parity fixture.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_review_harness.dart';

/// Inline editor open (Save / Cancel).
final StateFixture reviewEditingFixture = StateFixture(
  overrides: roundOverrides(),
  drive: (tester) async {
    await tester.tap(find.byIcon(Icons.edit));
  },
);
