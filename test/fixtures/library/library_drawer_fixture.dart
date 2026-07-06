// library · drawer — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import 'package:memox_v4/presentation/features/drawer/screens/drawer_screen.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// Opening the drawer from the library navigates to the Drawer screen — the
/// Flutter target of the kit `library/drawer` state (rendered via `home`).
final StateFixture libraryDrawerFixture = StateFixture(
  overrides: FakeHarness().overrides,
  home: const DrawerScreen(),
);
