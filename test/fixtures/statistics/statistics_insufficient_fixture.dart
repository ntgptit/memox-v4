// statistics · insufficient — golden-parity fixture.
import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// No study activity yet → the insufficient-data prompt.
final StateFixture statisticsInsufficientFixture = StateFixture(
  overrides: FakeHarness().overrides,
);
