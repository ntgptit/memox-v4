// reminder · time-picker — golden-parity fixture.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_switch.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// Time-picker sheet open — enable reminders, then open the picker.
final StateFixture reminderTimePickerFixture = StateFixture(
  overrides: FakeHarness().overrides,
  drive: (tester) async {
    await tester.tap(find.byType(MxSwitch));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.schedule));
  },
);
