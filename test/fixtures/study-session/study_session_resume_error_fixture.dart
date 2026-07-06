// study-session · resume-error — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import '../_fixture.dart';
import '_study_session_harness.dart';

/// The session failed to build (resume read failed) → the resume-error surface.
final StateFixture studySessionResumeErrorFixture = StateFixture(
  overrides: studySessionResumeErrorOverrides(),
);
