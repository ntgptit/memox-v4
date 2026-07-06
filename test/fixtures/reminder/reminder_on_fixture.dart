// reminder · on — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_switch.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// Reminders enabled — toggle the master switch on.
final StateFixture reminderOnFixture = StateFixture(
  overrides: FakeHarness().overrides,
  drive: (tester) async {
    await tester.tap(find.byType(MxSwitch));
  },
);
