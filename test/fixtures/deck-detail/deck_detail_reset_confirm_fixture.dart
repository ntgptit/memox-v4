// deck-detail · reset-confirm — golden-parity fixture.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

final StateFixture deckDetailResetConfirmFixture = StateFixture(
  overrides: FakeHarness().overrides,
  drive: (tester) async {
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset progress'));
  },
);
