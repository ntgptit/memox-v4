// study-result · finalize-error — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import '../_fixture.dart';
import '_study_result_harness.dart';

/// The finalize write failed → the retry / later error surface.
final StateFixture studyResultFinalizeErrorFixture = StateFixture(
  overrides: studyResultErrorOverrides(),
);
