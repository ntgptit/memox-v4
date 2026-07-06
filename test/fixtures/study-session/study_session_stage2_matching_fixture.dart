// study-session · stage2-matching — golden-parity fixture.
import 'package:flutter_test/flutter_test.dart';

import '../_fixture.dart';
import '_study_session_harness.dart';

/// Advance stage 1 → stage 2 (matching) with Next.
final StateFixture studySessionStage2MatchingFixture = StateFixture(
  overrides: studySessionNewOverrides(),
  drive: (tester) async {
    await tester.tap(find.text('Next'));
  },
);
