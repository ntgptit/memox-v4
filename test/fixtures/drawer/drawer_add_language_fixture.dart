// drawer · add-language — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// The add-language picker open.
final StateFixture drawerAddLanguageFixture = StateFixture(
  overrides: FakeHarness().overrides,
  drive: (tester) async {
    await tester.tap(find.text('Add language'));
  },
);
