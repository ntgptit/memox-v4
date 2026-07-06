// study-session · answer-save-error — golden-parity fixture (docs/agent/golden-parity/WBS.md).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_study_session_harness.dart';

/// Grading the due card fails the write → the retry dialog (progress preserved).
/// Drives a grade tap so the false→true saveError transition fires the dialog.
final StateFixture studySessionAnswerSaveErrorFixture = StateFixture(
  overrides: studySessionSaveErrorOverrides(),
  drive: (tester) async {
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();
  },
);
