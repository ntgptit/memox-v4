# RUN-LOOP — how to drive the build loop from another session

The build is a queue of self-contained task files in `prompts/` (see `00-INDEX.md`).
**One step = one fresh session.** Paste the driver prompt below into a NEW Claude Code
session; it auto-detects the next step from the WBS status and runs **exactly one**,
then stops. Open another fresh session and paste the **same** prompt for the next step.

> Why a fresh session each time: every step is scoped to read only its own docs. A new
> session = empty context, so the UI/spec can't overflow and the agent can't drift.

---

## 🌙 Overnight / unattended — run through the night (NEVER asks)

Use this when you're away/asleep. It runs steps back-to-back, develops **both BE and FE**
each step, and **never asks**: any problem is appended to `prompts/NIGHT-LOG.md` and the
loop continues. Only steps whose `verify --full` is **GREEN** get committed/pushed — a step
that can't go green (or needs an unapproved dependency) is parked with `git stash` and logged,
so **`main` stays green** all night. Review `prompts/NIGHT-LOG.md` in the morning.

Copy this into a fresh session before sleeping:

```text
Run the MemoX V4 build pack in prompts/ UNATTENDED, step after step, until no eligible step remains. This is an overnight run — DO NOT ask me anything. If anything is uncertain, blocked, fails, or needs a decision, append a dated entry to prompts/NIGHT-LOG.md and KEEP GOING.

0. FIRST, before changing anything: run `git status`. If the tree is NOT clean it holds my uncommitted work — append a note to prompts/NIGHT-LOG.md listing the dirty files and STOP immediately; do not stage, stash, discard, or commit anything. A clean baseline is required (I'll commit my work and relaunch). Only proceed when the tree is clean.

Per iteration, pick the next eligible step = lowest-numbered file in prompts/00-INDEX.md whose dependencies' WBS are Done (01-S0 counts as done once the Drift app_database + language_pair repo + app shell exist in lib/). Then:

1. Develop BOTH the BE and the FE scope of that step's prompts/NN-*.md. Read only the docs it lists -> drift check -> implement by layer (BE: entity->repo->DAO/Drift->use case; FE: @riverpod viewmodel->screen/widgets->route) -> node tool/verify/run.mjs --full. A step is "done" ONLY when BOTH BE and FE are implemented AND verify --full is GREEN.

2. GREEN -> update docs + WBS in the same commit (CLAUDE.md parity), commit with the file's message, push origin main. Append a one-line DONE entry to prompts/NIGHT-LOG.md. Continue.

3. NOT green / blocked -> never ask, never push broken code. Append to prompts/NIGHT-LOG.md: timestamp, step id, BLOCKED, what failed, key error excerpt, suggested fix. Park the attempt with `git stash push -u -m "BLOCKED:<step>"` so the tree returns to the last green commit, then commit+push just the NIGHT-LOG entry (node tool/verify/run.mjs --docs to get its marker). Skip to the next eligible step.

4. NEVER add a dependency that is not already in docs/stack/stack.md (W8 file_picker/csv/excel, W10 google_sign_in/googleapis/secure-storage, W12 flutter_local_notifications/timezone are NOT in it). If a step needs one, log BLOCKED(dep: <names>) and skip it -- do not add it.

5. Triggers that mean "log + skip", NOT "ask": DRIFT DETECTED, ambiguous spec, gated dependency, or verify still red after 2 fix attempts.

6. Stop only when every step is either merged or BLOCKED. Then write a final summary to prompts/NIGHT-LOG.md: steps merged (with commit hashes) and steps BLOCKED (with reasons). Leave main clean and green.

Guardrails still apply at all times: CLAUDE.md parity + hard rules, verify ONLY via tool/verify, no hardcoded routes/colors/strings/durations, reuse Mx* components + tokens, generated files via build_runner (never hand-edit). main must stay green -- the only commits pushed are steps that passed verify --full.
```

> Want it to self-pace with scheduled wake-ups instead of one long session? Prefix the
> block above with `/loop ` (the loop skill will re-enter each iteration). Same rules apply.

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
