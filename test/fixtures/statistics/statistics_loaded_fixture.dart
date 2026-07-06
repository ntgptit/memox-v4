// statistics · loaded — golden-parity fixture.
import '../_fixture.dart';
import '_statistics_harness.dart';

/// Activity present → heatmap, box distribution, forecast, accuracy.
final StateFixture statisticsLoadedFixture = StateFixture(
  overrides: statisticsLoadedOverrides(),
);
