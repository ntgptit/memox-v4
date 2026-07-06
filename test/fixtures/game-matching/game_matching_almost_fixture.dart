// game-matching · almost — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import '../_fixture.dart';
import '_game_matching_harness.dart';

/// Near the end of the round — 3 of 4 pairs matched, one still open.
final StateFixture gameMatchingAlmostFixture = StateFixture(
  overrides: matchingStateOverrides(matchingAlmost),
);
