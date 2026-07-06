// game-typing · complete — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import '../_fixture.dart';
import '_game_typing_harness.dart';

/// The queue emptied → round-finished summary + Next round.
final StateFixture gameTypingCompleteFixture = StateFixture(
  overrides: typingStateOverrides(typingComplete),
);
