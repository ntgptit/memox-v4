// dashboard · streak-reset — golden-parity fixture.
import '../_fixture.dart';
import '_dashboard_harness.dart';

/// A little activity today, nothing met recently → current streak is 0.
final StateFixture dashboardStreakResetFixture = StateFixture(
  overrides: dashboardSeededOverrides(
    dashboardActivity(today: (minutes: 5, words: 0)),
  ),
);
