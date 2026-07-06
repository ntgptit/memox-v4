// study-session · exit — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_study_session_harness.dart';

/// Leaving mid-session → the confirm-exit dialog. Drives the close (X) tap.
final StateFixture studySessionExitFixture = StateFixture(
  overrides: studySessionStateOverrides(studySessionStage3),
  drive: (tester) async {
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
  },
);
