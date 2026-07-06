// study-result · retry-finalize — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import '../_fixture.dart';
import '_study_result_harness.dart';

/// A finalizing pass that follows a Retry → the "Retrying…" finalizing view.
final StateFixture studyResultRetryFinalizeFixture = StateFixture(
  overrides: studyResultLoadingOverrides(retrying: true),
);
