// statistics · scope-switch — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_statistics_harness.dart';

/// The scope toggle switched to "All" (vs the default "This pair") — the kit
/// `scope-switch` state. Drives a tap on the All segment of the seeded loaded
/// screen.
final StateFixture statisticsScopeSwitchFixture = StateFixture(
  overrides: statisticsLoadedOverrides(),
  drive: (tester) async {
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
  },
);
