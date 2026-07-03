// Persistence-safety skeleton (DT.0.1 · Policy 3 — deterministic ordering).
//
// Locks the contract DT.3 (DAO queries) must satisfy: every list query has an
// explicit total ORDER BY with a stable `id` tie-break — reproducible across runs
// and platforms. Skipped until the Drift DAOs exist; see
// docs/database/persistence-safety.md.
@Skip('DT.3 fills this in once the Drift DAOs exist.')
library;

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('deterministic ordering (Policy 3 · D-023)', () {
    test('the same query over the same data returns the same order twice', () {
      // GIVEN a seeded deck list, WHEN queried twice,
      // THEN the id sequences are identical (no reliance on rowid/insertion order).
    });

    test('a tie on the sort key falls back to id', () {
      // GIVEN two rows with equal sort keys (e.g. same created_at),
      // THEN they order by id (a total order, not an arbitrary one). D-023.
    });

    test('the due queue orders by due_at then id', () {
      // GIVEN due cards with distinct/equal due_at, THEN order is (due_at, id).
    });
  });
}
