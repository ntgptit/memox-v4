// game-mc · wrong — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import '../_fixture.dart';
import '_game_mc_harness.dart';

/// A wrong choice picked → wrong tone on it, correct one revealed, card re-queued.
final StateFixture gameMcWrongFixture = StateFixture(
  overrides: mcStateOverrides(mcWrong),
);
