// library · error — golden-parity fixture.
import '../_fixture.dart';
import '_library_harness.dart';

/// The deck read failed → retry surface.
final StateFixture libraryErrorFixture = StateFixture(
  overrides: libraryErrorOverrides(),
);
