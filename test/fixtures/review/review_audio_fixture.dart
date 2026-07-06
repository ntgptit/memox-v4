// review · audio — golden-parity fixture.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_review_harness.dart';

/// After tapping the audio button.
final StateFixture reviewAudioFixture = StateFixture(
  overrides: roundOverrides(),
  drive: (tester) async {
    await tester.tap(find.byIcon(Icons.volume_up));
  },
);
