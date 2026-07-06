// drawer · remove-language — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// The remove-language screen open.
final StateFixture drawerRemoveLanguageFixture = StateFixture(
  overrides: FakeHarness().overrides,
  drive: (tester) async {
    await tester.tap(find.text('Remove language'));
  },
);
