// library · empty — golden-parity fixture.
import '../_fixture.dart';
import '_library_harness.dart';

/// No decks → create-the-first-deck empty state.
final StateFixture libraryEmptyFixture = StateFixture(
  overrides: libraryEmptyOverrides(),
);
