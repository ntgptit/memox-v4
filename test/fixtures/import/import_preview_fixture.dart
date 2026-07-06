// import · preview — golden-parity fixture.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

final StateFixture importPreviewFixture = StateFixture(
  overrides: FakeHarness().overrides,
  drive: (tester) async {
    await tester.enterText(find.byType(TextField), '안녕\tHello\n감사\tThanks');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
  },
);
