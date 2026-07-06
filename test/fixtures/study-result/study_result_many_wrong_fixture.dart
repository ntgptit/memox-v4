// study-result · many-wrong — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import '../_fixture.dart';
import '_study_result_harness.dart';

/// Many cards missed (≥ threshold) → "review your misses" headline + CTA.
final StateFixture studyResultManyWrongFixture = StateFixture(
  overrides: studyResultDataOverrides(studyResultManyWrong),
);
