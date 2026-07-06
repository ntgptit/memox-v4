// game-picker · default — golden-parity fixture.
import '../_fixture.dart';
import '_game_picker_harness.dart';

/// Enough words in the library → the five game modes are enabled.
final StateFixture gamePickerDefaultFixture = StateFixture(
  overrides: gamePickerFullOverrides(),
);
