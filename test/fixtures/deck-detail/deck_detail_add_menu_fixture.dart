// deck-detail · add-menu — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/shared/composites/mx_fab.dart';

import '../../harness/provider_harness.dart';
import '../_fixture.dart';

final StateFixture deckDetailAddMenuFixture = StateFixture(
  overrides: FakeHarness().overrides,
  drive: (tester) async {
    await tester.tap(find.byType(MxFab));
  },
);
