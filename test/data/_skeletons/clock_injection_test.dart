// Persistence-safety skeleton (DT.0.1 · Policy 4 — clock injection).
//
// Locks the contract DT.3/DT.4 must satisfy: the data layer reads no
// `DateTime.now()` — "now" and the local-day bucket come from the injected Clock
// (DM.9). Skipped until the Drift DAOs/repos exist; see
// docs/database/persistence-safety.md.
@Skip('DT.3/DT.4 fill this in once the Drift DAOs/repos exist.')
library;

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('clock injection (Policy 4 · D-010/D-021)', () {
    test('the due query honours the injected asOf, not the wall clock', () {
      // GIVEN a card due at instant T, THEN it is due for asOf >= T and not for
      // asOf < T — the query uses the passed instant, never DateTime.now().
    });

    test('the daily-activity bucket is the injected clock local day', () {
      // GIVEN a session started at a fixed instant, THEN its activity lands in the
      // machine-local calendar day of that instant (midnight-of-day key). D-010.
    });

    test('no data-layer source reads DateTime.now()', () {
      // A source-scan guard (DT.4): only SystemClock may call DateTime.now();
      // DAOs/repos must take an injected instant.
    });
  });
}
