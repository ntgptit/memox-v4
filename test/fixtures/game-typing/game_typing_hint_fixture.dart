// game-typing · hint — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_game_typing_harness.dart';

/// The hint note revealed via Help.
final StateFixture gameTypingHintFixture = StateFixture(
  overrides: gameRoundOverrides(),
  drive: (tester) async {
    await tester.tap(find.text('Help'));
  },
);
