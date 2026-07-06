// dashboard · empty — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import '../_fixture.dart';
import '_dashboard_harness.dart';

/// No decks in the library → first-run onboarding hero + how-it-works.
final StateFixture dashboardEmptyFixture = StateFixture(
  overrides: dashboardEmptyOverrides(),
);
