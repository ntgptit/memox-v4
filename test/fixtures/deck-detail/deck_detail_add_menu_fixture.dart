// deck-detail · add-menu — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';
import 'package:memox_v4/presentation/shared/composites/mx_fab.dart';

import '../_fixture.dart';
import '_deck_detail_harness.dart';

final StateFixture deckDetailAddMenuFixture = StateFixture(
  overrides: deckDetailKitOverrides(),
  drive: (tester) async {
    await tester.tap(find.byType(MxFab));
  },
);
