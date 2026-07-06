// dashboard · loading — golden-parity fixture.
import '../_fixture.dart';
import '_dashboard_harness.dart';

/// Activity read never resolves → the dashboard stays in its loading skeleton.
final StateFixture dashboardLoadingFixture = StateFixture(
  overrides: dashboardLoadingOverrides(),
);
