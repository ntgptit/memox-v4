// dashboard · not-studied — golden-parity fixture.
import '../_fixture.dart';
import '_dashboard_harness.dart';

/// Has decks, zero activity today → full layout with 00:00/0 + nudge banner.
final StateFixture dashboardNotStudiedFixture = StateFixture(
  overrides: dashboardSeededOverrides(dashboardActivity()),
);
