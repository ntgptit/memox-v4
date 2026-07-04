# Gaps-remediation queue

Loop reads this (STEP 2). Pick the first `[ ]` not in `BLOCKED.txt`, in order.
Detail per unit: [`WBS.md`](WBS.md). Tick `[x]` after merge; append id to `DONE.txt`.

| | ID | Unit | Reverses v1? |
|---|---|---|---|
| [x] | G.01 | settings/group-expanded — SRS detail sub-page | deferred UI |
| [ ] | G.02 | statistics/scope-switch — This pair / All | ⚠ yes |
| [x] | G.03 | deck-detail/reset-confirm — reset card progress | ⚠ yes |
| [x] | G.04 | player/speed→TTS — apply playback rate | fidelity |
| [ ] | G.05 | library/sort — date-created + last-studied | fidelity |
| [x] | G.06 | game-matching/correct-flash | fidelity |
| [x] | G.07 | import/column-picker — map columns | fidelity |
| [x] | G.08 | theme/live-accent — app-wide accent + font-scale | fidelity |
| [x] | G.09 | search/recents-persist | fidelity |
| [ ] | G.10 | study-result/many-wrong — per-session accuracy + CTA | ⚠ yes |
| [ ] | G.11 | study-result/retry-finalize — resolve dead `retry` | cleanup |
