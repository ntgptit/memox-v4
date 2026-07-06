// game-recall · before-reveal — golden-parity fixture.
import '../_fixture.dart';
import '_game_recall_harness.dart';

/// Term shown, meaning hidden, Show button.
final StateFixture gameRecallBeforeRevealFixture = StateFixture(
  overrides: gameRoundOverrides(),
);
