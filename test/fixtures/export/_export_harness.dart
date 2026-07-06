import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:memox_v4/presentation/features/export/providers/export_providers.dart';

import '../../harness/provider_harness.dart';

// "exporting" is a transient in-flight step; the fake file service writes
// synchronously, so a real Export tap jumps straight to "done". We subclass the
// PUBLIC ExportController and pin the step to `exporting` (same pattern as the
// other in-flight/interaction states).
List<Override> exportExportingOverrides() => [
  ...FakeHarness().overrides,
  exportControllerProvider.overrideWith(_ExportingController.new),
];

class _ExportingController extends ExportController {
  @override
  ExportState build() =>
      ExportState.initial.copyWith(step: ExportStep.exporting);
}
