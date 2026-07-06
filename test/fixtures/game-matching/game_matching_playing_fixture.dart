// game-matching · playing — golden-parity fixture.
import '../_fixture.dart';
import '_game_matching_harness.dart';

/// The grid of meaning + term tiles, nothing selected.
final StateFixture gameMatchingPlayingFixture = StateFixture(
  overrides: gameRoundOverrides(),
);
