// game-picker · scope-dropdown — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_game_picker_harness.dart';

/// The card-source scope sheet open.
final StateFixture gamePickerScopeDropdownFixture = StateFixture(
  overrides: gamePickerFullOverrides(),
  drive: (tester) async {
    await tester.tap(find.text('Card source'));
  },
);
