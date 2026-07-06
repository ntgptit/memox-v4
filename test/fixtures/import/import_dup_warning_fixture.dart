// import · dup-warning — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_import_harness.dart';

/// Pasting a term (사과) that already exists in the target deck → the preview's
/// soft-duplicate warning banner.
final StateFixture importDupWarningFixture = StateFixture(
  overrides: importDuplicateOverrides(),
  drive: (tester) async {
    await tester.enterText(find.byType(TextField), '사과\tapple\n감사\tThanks');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  },
);
