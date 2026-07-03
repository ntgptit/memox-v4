// Persistence-safety skeleton (DT.0.1 · Policy 2 — cascade delete, D-024).
//
// Locks the contract DT.1 (ON DELETE CASCADE FKs + PRAGMA foreign_keys=ON) and
// DT.4 (deck delete) must satisfy: deleting a deck removes its whole subtree with
// no orphans. Skipped until the Drift DB exists; see
// docs/database/persistence-safety.md.
@Skip('DT.1/DT.4 fill this in once the Drift DB + deck delete exist.')
library;

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cascade delete (Policy 2 · D-024)', () {
    test('deleting a parent deck removes descendant decks', () {
      // GIVEN parent → child deck, WHEN the parent is deleted,
      // THEN the child deck row is gone (self-FK cascade).
    });

    test('deleting a deck removes its cards, meanings, srs_state, review_logs', () {
      // GIVEN a deck with cards (each with meanings + srs_state + review_logs),
      // WHEN the deck is deleted,
      // THEN no orphaned card / card_meaning / srs_state / review_log rows remain.
      // D-024.
    });

    test('foreign keys are enforced (PRAGMA foreign_keys = ON)', () {
      // GIVEN a fresh connection, THEN `PRAGMA foreign_keys` reads 1 — cascades
      // do nothing in SQLite unless this is enabled at open.
    });
  });
}
