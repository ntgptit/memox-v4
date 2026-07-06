// study-result · goal-met — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import '../_fixture.dart';
import '_study_result_harness.dart';

/// The day's goal reached this session → celebratory headline.
final StateFixture studyResultGoalMetFixture = StateFixture(
  overrides: studyResultDataOverrides(studyResultGoalMet),
);
