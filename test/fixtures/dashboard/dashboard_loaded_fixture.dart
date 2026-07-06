// dashboard · loaded — golden-parity fixture.
import '../_fixture.dart';
import '_dashboard_harness.dart';

/// Studied today (goal not yet met) with a live streak (met the last two days).
final StateFixture dashboardLoadedFixture = StateFixture(
  overrides: dashboardSeededOverrides(
    dashboardActivity(today: (minutes: 5, words: 3), past: {1: 20, 2: 20}),
  ),
);
