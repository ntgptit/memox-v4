// library · pair-picker — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_library_harness.dart';

/// Tapping the context-bar language-pair button opens the PairPickerSheet
/// (seeded with two pairs, one selected).
final StateFixture libraryPairPickerFixture = StateFixture(
  overrides: libraryPairPickerOverrides(),
  drive: (tester) async {
    await tester.tap(find.byIcon(Icons.expand_more).first);
    await tester.pumpAndSettle();
  },
);
