// study-result · finalizing — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import '../_fixture.dart';
import '_study_result_harness.dart';

/// Writing the session outcome — the finalizing view (spinner + "Saving…").
final StateFixture studyResultFinalizingFixture = StateFixture(
  overrides: studyResultLoadingOverrides(),
);
