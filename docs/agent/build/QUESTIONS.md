# Build-loop questions & blockers (async — for the human)

The autonomous build loop writes here **instead of stopping** when it hits
something that needs a human decision, then skips to the next task. Nothing here
blocks the loop; resolve these when you're back.

Format per entry: **task · what's ambiguous · the fallback I chose (so the build
kept moving) · what I need from you.**

---

## Open

_(none yet — loop just started)_

## Resolved

_(none yet)_

---

## Loop status log

- **Start (asleep run):** foundation I.0–I.3, I.6, I.7 already done + 3 infra
  chores (gitignore codegen, LF pins, verify runner). Resuming at **I.4**.
  Order: I.4 → I.5 → I.8 → I.10 → I.9 (foundation seal) → T.* → DM contracts →
  DM.9 fakes → P/K/H → H.08 → DT.* → DM.4–7 → S.00 → S.* → V.*. Deferred (`[~]`)
  skipped. Each task: branch → build → `node tool/verify/run.mjs` → commit → PR →
  merge → tick DONE.txt. Pushes use `MEMOX_SKIP_DESIGN_SYNC=1`.
