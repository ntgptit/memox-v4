// export · exporting — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import '../_fixture.dart';
import '_export_harness.dart';

/// The in-flight export step (writing the file / copying) — a transient state
/// pinned via a fixed controller step.
final StateFixture exportExportingFixture = StateFixture(
  overrides: exportExportingOverrides(),
);
