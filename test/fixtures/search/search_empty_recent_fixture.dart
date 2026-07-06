// search · empty-recent — golden-parity fixture.
import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// No query yet → recent searches.
final StateFixture searchEmptyRecentFixture = StateFixture(
  overrides: FakeHarness().overrides,
);
