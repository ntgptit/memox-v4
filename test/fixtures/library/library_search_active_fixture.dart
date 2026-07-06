// library · search-active — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import 'package:memox_v4/presentation/features/search/screens/search_screen.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

/// From the library, activating search navigates to the Search screen — the
/// Flutter target of the kit `library/search-active` state (rendered via `home`).
final StateFixture librarySearchActiveFixture = StateFixture(
  overrides: FakeHarness().overrides,
  home: const SearchScreen(),
);
