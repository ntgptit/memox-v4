// settings · group-expanded — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import 'package:memox_v4/presentation/features/settings/screens/srs_settings_screen.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// The kit `settings/group-expanded` is the SRS detail SUB-PAGE (SrsSettingsScreen),
/// reached from the Settings hub — rendered directly via the `home` override.
final StateFixture settingsGroupExpandedFixture = StateFixture(
  overrides: FakeHarness().overrides,
  home: const SrsSettingsScreen(),
);
