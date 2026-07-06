// deck-detail · no-results — golden-parity fixture.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

final StateFixture deckDetailNoResultsFixture = StateFixture(
  overrides: FakeHarness().overrides,
  drive: (tester) async {
    await tester.enterText(find.byType(TextField), 'zzzzz');
  },
);
