// dashboard · goal-met — golden-parity fixture.
import '../_fixture.dart';
import '_dashboard_harness.dart';

/// Today's goal reached → celebration banner + full layout.
final StateFixture dashboardGoalMetFixture = StateFixture(
  overrides: dashboardSeededOverrides(
    dashboardActivity(today: (minutes: 20, words: 0)),
  ),
);
