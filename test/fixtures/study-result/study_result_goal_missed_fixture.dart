// study-result · goal-missed — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import '../_fixture.dart';
import '_study_result_harness.dart';

/// Goal configured but not yet reached today → keep-going headline.
final StateFixture studyResultGoalMissedFixture = StateFixture(
  overrides: studyResultDataOverrides(studyResultGoalMissed),
);
