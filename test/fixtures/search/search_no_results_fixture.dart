// search · no-results — golden-parity fixture.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// A query that matches nothing → the empty-results state.
final StateFixture searchNoResultsFixture = StateFixture(
  overrides: FakeHarness().overrides,
  drive: (tester) async {
    await tester.enterText(find.byType(TextField), 'zzzzz');
  },
);
