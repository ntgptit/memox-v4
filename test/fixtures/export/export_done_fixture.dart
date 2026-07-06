// export · done — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// Export finished — tap Export, the done confirmation shows.
final StateFixture exportDoneFixture = StateFixture(
  overrides: FakeHarness().overrides,
  drive: (tester) async {
    await tester.tap(find.text('Export'));
  },
);
