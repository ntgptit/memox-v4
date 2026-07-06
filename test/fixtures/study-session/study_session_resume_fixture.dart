// study-session · resume — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import '../_fixture.dart';
import '_study_session_harness.dart';

/// Re-entering a partially-done session — the current step with progress already
/// advanced (2nd card, 5/10). Flutter has no distinct resume surface.
final StateFixture studySessionResumeFixture = StateFixture(
  overrides: studySessionStateOverrides(studySessionResume),
);
