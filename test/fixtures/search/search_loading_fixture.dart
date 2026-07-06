// search · loading — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import '../_fixture.dart';
import '_search_harness.dart';

/// A query in flight — the search results provider never resolves, so the screen
/// shows its loading body.
final StateFixture searchLoadingFixture = StateFixture(
  overrides: searchLoadingOverrides(),
);
