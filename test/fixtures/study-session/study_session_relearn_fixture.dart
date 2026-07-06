// study-session · relearn — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import '../_fixture.dart';
import '_study_session_harness.dart';

/// A wrong choice picked in stage 3 → the "not counted, try again" relearn note.
final StateFixture studySessionRelearnFixture = StateFixture(
  overrides: studySessionStateOverrides(studySessionRelearn),
);
