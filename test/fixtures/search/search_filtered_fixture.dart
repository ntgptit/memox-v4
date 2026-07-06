// search · filtered — golden-parity fixture.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_chip.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// Query then a status-chip filter applied.
final StateFixture searchFilteredFixture = StateFixture(
  overrides: FakeHarness().overrides,
  drive: (tester) async {
    await tester.enterText(find.byType(TextField), 'con');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MxChip, 'New'));
  },
);
