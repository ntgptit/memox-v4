// statistics · loading — golden-parity fixture.
import '../_fixture.dart';
import '_statistics_harness.dart';

/// The deck tree never resolves → loading skeletons.
final StateFixture statisticsLoadingFixture = StateFixture(
  overrides: statisticsLoadingOverrides(),
);
