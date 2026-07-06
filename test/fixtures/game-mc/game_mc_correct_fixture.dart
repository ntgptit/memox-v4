// game-mc · correct — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import '../_fixture.dart';
import '_game_mc_harness.dart';

/// The correct choice picked → correct tone revealed + Next.
final StateFixture gameMcCorrectFixture = StateFixture(
  overrides: mcStateOverrides(mcCorrect),
);
