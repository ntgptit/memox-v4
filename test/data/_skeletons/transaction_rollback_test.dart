// Persistence-safety skeleton (DT.0.1 · Policy 1 — atomic multi-table writes).
//
// Locks the contract DT.4 (repository impls + transactions) must satisfy: a
// multi-table write that fails partway rolls back completely — the DB never keeps
// a partial write. Skipped until DT.1 (Drift DB) + DT.4 (transactional repos) land;
// see docs/database/persistence-safety.md.
@Skip('DT.4 fills this in once the Drift DB + transactional repositories exist.')
library;

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('transaction rollback (Policy 1)', () {
    test('a failing second write rolls back the first (cards + card_meanings)', () {
      // GIVEN a save that writes a `cards` row then a `card_meanings` row,
      // WHEN the meaning write throws inside the same transaction,
      // THEN neither row is persisted (row count for the card id is 0). BR-2.
    });

    test('a failed grade leaves srs_state and review_logs unchanged', () {
      // GIVEN GradeCard writes srs_state then review_logs in one transaction,
      // WHEN the log write fails,
      // THEN srs_state keeps its pre-grade box/due_at (no half-applied grade).
      // D-003/D-004/D-005.
    });

    test('a failed import batch persists no rows from the batch', () {
      // GIVEN an N-card import in one transaction,
      // WHEN row k throws,
      // THEN zero of the N cards/meanings are persisted (all-or-nothing). D-025.
    });
  });
}
