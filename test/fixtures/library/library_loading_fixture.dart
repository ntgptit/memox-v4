// library · loading — golden-parity fixture.
import '../_fixture.dart';
import '_library_harness.dart';

/// The deck tree never resolves → skeletons.
final StateFixture libraryLoadingFixture = StateFixture(
  overrides: libraryLoadingOverrides(),
);
