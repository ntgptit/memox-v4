// study-result · standard — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import '../_fixture.dart';
import '_study_result_harness.dart';

/// No goal configured, few misses → neutral "session done" summary + Continue.
final StateFixture studyResultStandardFixture = StateFixture(
  overrides: studyResultDataOverrides(studyResultStandard),
);
