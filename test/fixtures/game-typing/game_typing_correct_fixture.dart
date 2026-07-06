// game-typing · correct — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import '../_fixture.dart';
import '_game_typing_harness.dart';

/// The exact answer submitted → correct feedback + Next.
final StateFixture gameTypingCorrectFixture = StateFixture(
  overrides: typingStateOverrides(typingCorrect),
);
