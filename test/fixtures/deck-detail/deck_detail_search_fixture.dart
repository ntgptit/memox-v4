// deck-detail · search — golden-parity fixture.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

final StateFixture deckDetailSearchFixture = StateFixture(
  overrides: FakeHarness().overrides,
  drive: (tester) async {
    await tester.enterText(find.byType(TextField), 'con');
  },
);
