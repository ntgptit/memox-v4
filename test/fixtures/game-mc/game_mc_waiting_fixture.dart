// game-mc · waiting — golden-parity fixture.
import '../_fixture.dart';
import '_game_mc_harness.dart';

/// Prompt term + four meaning choices, none picked.
final StateFixture gameMcWaitingFixture = StateFixture(
  overrides: gameRoundOverrides(),
);
