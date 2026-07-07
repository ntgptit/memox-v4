// deck-detail · search — golden-parity fixture.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_deck_detail_harness.dart';

final StateFixture deckDetailSearchFixture = StateFixture(
  overrides: deckDetailKitOverrides(),
  drive: (tester) async {
    await tester.enterText(find.byType(TextField), 'study');
  },
);
