// library · overflow-menu — golden-parity fixture.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// The overflow menu sheet open.
final StateFixture libraryOverflowMenuFixture = StateFixture(
  overrides: FakeHarness().overrides,
  drive: (tester) async {
    await tester.tap(find.byIcon(Icons.more_vert));
  },
);
