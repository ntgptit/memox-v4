# Gaps-remediation WBS — close the state-parity + fidelity gaps

> Follows the [state-parity audit](../props-parity/state-parity-audit.md). Closes
> the 5 state gaps + 6 behaviour-fidelity notes it found. **Feature work** (not
> mechanical): each unit may touch data/domain/provider/UI + tests. One unit = one
> branch = one PR, verify green (`node tool/verify/run.mjs`). Ordered easy→hard
> (UI-only first, data-layer last) so momentum builds and risk is back-loaded.

**⚠ v1-reversal flag** = the item was a *documented, intentional* v1 scope-out;
implementing it widens v1 scope (authorized by the "thực hiện toàn bộ" request).
Design decisions I make per unit are recorded in the PR + here.

## Queue

| | ID | Unit | Layer | Reverses v1? | Notes |
|---|---|---|---|---|---|
| [ ] | G.01 | settings/group-expanded — SRS detail sub-page | UI + route | deferred UI | Leitner-box list + intervals + due-notifications switch; drill-in from the SRS row |
| [ ] | G.02 | statistics/scope-switch — This pair / All | provider + UI | ⚠ yes | segmented control; scope the stats read by active pair vs all pairs |
| [ ] | G.03 | deck-detail/reset-confirm — reset card progress | domain + UI | ⚠ yes ("no v1 use case") | card-actions "Reset progress" → confirm → box→0, due→now |
| [ ] | G.04 | player/speed→TTS — apply playback rate | service | fidelity | pass `speed` into the TTS `setSpeechRate` |
| [ ] | G.05 | library/sort — date-created + last-studied | provider + drift | fidelity | add 2 orderings to SortSheet + query |
| [ ] | G.06 | game-matching/correct-flash | provider + UI | fidelity (cosmetic) | brief `MatchTone.correct` before `matched` |
| [ ] | G.07 | import/column-picker — map columns | provider + UI | fidelity | choose which column → term/meaning (default A/B) |
| [ ] | G.08 | theme/live-accent — app-wide accent + font-scale | theme system | fidelity | apply beyond PreviewCard |
| [ ] | G.09 | search/recents-persist | data | fidelity | persist recent searches to a store |
| [ ] | G.10 | study-result/many-wrong — per-session accuracy + CTA | data + domain + UI | ⚠ yes (undrivable in v1) | log correct/wrong per session; `manyWrong` head + "Review N cards" CTA |
| [ ] | G.11 | study-result/retry-finalize — resolve dead `retry` | cleanup | — | no separate finalize step exists → remove unused `retry` param OR document; NOT a fabricated feature |

## Definition of Done (per unit)
- Feature implemented across the needed layers; **strings from ARB**, **no magic
  values**, **Riverpod `@riverpod` (no setState)**, **SQL only in `*.drift`**.
- Tests: at least one widget/provider/domain test proving the new behaviour.
- `node tool/parity/props_check.mjs --strict` still green (if a constructor
  changed, update the `.d.ts` or add a typed exception).
- `node tool/verify/run.mjs` green. → branch → PR → merge → tick here.

## Run order & rationale
UI-only (G.01) → provider+UI (G.02, G.06, G.07) → domain (G.03) → service/query
(G.04, G.05) → theme (G.08) → data-layer (G.09) → biggest data+domain (G.10) →
cleanup (G.11). Data-model changes (G.10, G.09) last, when the pattern is warm.

## STOP conditions
- A gap needs a product decision I can't infer a sane default for (e.g. the
  many-wrong *threshold*) → pick a documented default, note it, continue.
- A change would break an existing invariant/test I can't reconcile honestly →
  STOP that unit, log it, move on.
