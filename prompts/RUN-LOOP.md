# RUN-LOOP — how to drive the build loop from another session

The build is a queue of self-contained task files in `prompts/` (see `00-INDEX.md`).
**One step = one fresh session.** Paste the driver prompt below into a NEW Claude Code
session; it auto-detects the next step from the WBS status and runs **exactly one**,
then stops. Open another fresh session and paste the **same** prompt for the next step.

> Why a fresh session each time: every step is scoped to read only its own docs. A new
> session = empty context, so the UI/spec can't overflow and the agent can't drift.

---

## ▶ Driver prompt — copy this, run once per fresh session (auto-advances)

```text
Continue the MemoX V4 build using the prompt pack in `prompts/`. Do EXACTLY ONE step, then stop.

1. Read `prompts/00-INDEX.md` (loop order + conventions) and `docs/project-management/wbs.md` (status).
2. Choose the step to run: the LOWEST-numbered file in the INDEX order whose work is not done yet AND
   whose dependencies are all done. "Done" = its WBS work package is `Done` in wbs.md (for step 01-S0,
   which has no WBS row, treat it as done only if the Drift `app_database` + `language_pair` repo + the
   app shell already exist in `lib/`). If you cannot tell, STOP and ask me which step to run.
3. Open that step's `prompts/NN-*.md` and execute it to completion, following it literally:
   required reading → drift check → implement by layer (BE → FE) → `node tool/verify/run.mjs --full`
   (must PASS) → fan out code-reviewer + docs-drift-detector on the diff → fix blockers.
4. Commit with the message in the file, update docs + WBS in the SAME commit (CLAUDE.md parity), then
   push to `origin main`. Confirm working tree clean and local == remote.
5. Do NOT start any other step. Then report: step completed, verify summary, WBS update, and which
   `prompts/NN-*.md` is next.

Hard stops (stop and ASK, do not guess): any DRIFT DETECTED, any new dependency gated in the file
(W8 / W10 / W12), any STOP condition in CLAUDE.md, or verify not green after 2 fix attempts.
```

---

## ▶ Run a specific step (skip auto-detect)

```text
Run MemoX V4 build step `prompts/02-W2-flashcard.md` to completion: follow it literally
(required reading → drift check → implement BE→FE → node tool/verify/run.mjs --full → review fan-out →
commit + push to origin main). Do only this step, then report and name the next file. Stop and ask on
any DRIFT, gated dependency, or CLAUDE.md STOP condition.
```
Replace the filename with the step you want.

---

## ▶ Optional: self-paced `/loop` (one session, auto-cadence)

Only if you want it to keep going on its own. Context grows across steps, so this is the
**less safe** option — prefer a fresh session per step above.

```text
/loop Continue the MemoX V4 build from prompts/ : each iteration, run the next not-done step per
prompts/00-INDEX.md + docs/project-management/wbs.md exactly as that prompts/NN-*.md file says
(read → drift check → implement BE→FE → node tool/verify/run.mjs --full → review fan-out →
commit + push origin main), do ONE step per iteration, then report and continue. Stop and ask on any
DRIFT, gated dependency (W8/W10/W12), or CLAUDE.md STOP condition.
```

---

## Order (for reference — full table in `00-INDEX.md`)
`01-S0` → `02-W2` → `03-W6` → `04-W3` → `05-W5` → `06-W4` → `07-W7` → `08-W8` →
`09-W11` → `10-W9` → `11-W10` → `12-W12` → `13-W13`

You'll be asked to approve new dependencies at **W8** (file_picker/csv/excel),
**W10** (google_sign_in/googleapis/secure storage), **W12** (flutter_local_notifications/timezone).
