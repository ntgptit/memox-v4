// deck-detail · deck-delete-confirm — golden-parity fixture.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_deck_detail_harness.dart';

final StateFixture deckDetailDeckDeleteConfirmFixture = StateFixture(
  overrides: deckDetailKitOverrides(),
  drive: (tester) async {
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete deck'));
  },
);
