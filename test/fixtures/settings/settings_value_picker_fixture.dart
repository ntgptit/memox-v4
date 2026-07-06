// settings · value-picker — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// A value-picker sheet open (new-cards-per-day).
final StateFixture settingsValuePickerFixture = StateFixture(
  overrides: FakeHarness().overrides,
  drive: (tester) async {
    await tester.tap(find.text('Game settings'));
  },
);
