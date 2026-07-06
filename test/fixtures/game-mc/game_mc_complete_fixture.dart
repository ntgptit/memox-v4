// game-mc · complete — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import '../_fixture.dart';
import '_game_mc_harness.dart';

/// Past the last question → round-finished summary + Next round.
final StateFixture gameMcCompleteFixture = StateFixture(
  overrides: mcStateOverrides(mcComplete),
);
