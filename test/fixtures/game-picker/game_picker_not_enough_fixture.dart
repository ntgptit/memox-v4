// game-picker · not-enough — golden-parity fixture.
import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// The default seed has < 4 due cards → games disabled, not-enough callout.
final StateFixture gamePickerNotEnoughFixture = StateFixture(
  overrides: FakeHarness().overrides,
);
