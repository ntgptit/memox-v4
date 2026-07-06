# Golden-Parity Loop — Blocker & Decision Notes

> Autonomous /loop execution log for `docs/agent/golden-parity/WBS.md`.
> The loop appends here whenever it hits something it cannot resolve on its own,
> makes a non-obvious assumption, or defers work. Surfaced to the user at loop end.
> Format: `## <date> · <phase> · <topic>` then What / Why / Assumed-or-deferred.

## Known constraints (recorded at loop start — 2026-07-06)

- **G.2/G.3 blocked on the visual-parity exporter.** The kit↔Flutter pixel diff
  needs fresh `shots/` from `tool/ui_kit_shots` (visual-parity WBS), which does
  not exist. The loop covers G.0 + G.1 (Flutter-side goldens, standalone value)
  and STOPS at the VP boundary — it does not build the exporter (out of this WBS).
- **Golden baselines must come from CI ubuntu.** This machine is Windows; the loop
  builds the golden machinery + fixtures and verifies rendering locally, but does
  NOT commit Windows-generated baseline PNGs as canonical (WBS §0 S3).

## 2026-07-06 · G.0 · golden-test generation deferred to next chunk
- **What:** chunk 1 emits fixtures + barrels + registry + coverage `--check`, but
  NOT the per-screen golden test files (`test/golden/screens/<screen>/`).
- **Why:** rendering a screen golden needs a screen→widget map (import + class per
  screen, e.g. dashboard→DashboardScreen). That map is the next chunk's first task
  (derive by convention `lib/presentation/features/<screen>/screens/<screen>_screen.dart`
  + a small exceptions list). Kept out of chunk 1 to ship the coverage core clean.
- **Assumed/deferred:** fail-by-default is live at the FIXTURE layer (StateFixture.
  unimplemented → fail()); golden tests that consume it arrive next chunk.

## 2026-07-06 · G.0 · marker word "TODO" avoided
- **What:** stubs use `// FILL(golden-parity):` not `// TODO`, and the sentinel
  message says "UNIMPLEMENTED" not "TODO".
- **Why:** the memox-v4 code guard rule `common.no_todo_without_ticket` fails on any
  bare TODO; 114 stubs would each trip it. FILL/UNIMPLEMENTED convey the same intent
  and keep the gate green.

## 2026-07-06 · G.0 · chunk 2a = golden-test machinery (Dashboard fill → 2b)
- **What:** scaffolder now also emits per-screen golden tests (@Tags golden-parity,
  loop state×theme → pumpScreenGolden → matchesGoldenFile). dart_test.yaml defines
  the tag; the gate runs `flutter test --exclude-tags golden-parity` so fail-stubs
  don't block (Đ-G-5). scaffold --check also asserts each screen has a golden test.
- **Screen→widget:** pure convention (`<Pascal>Screen`, zero-arg const) for 20/21;
  only deck-detail needs an arg — `DeckDetailScreen(deckId: 'deck-root')` (deckId is
  a String, not DeckId — corrected). No other exceptions.
- **Confirmed:** running the golden-parity tag fails-fast with the UNIMPLEMENTED
  sentinel (mechanism proven). Fixed a `$sentinel` interpolation bug in _fixture.dart.
- **Deferred to 2b:** filling Dashboard's 6 real fixtures + diff.mjs calibration.
