# NIGHT-LOG — unattended build issues

Append-only journal for the overnight loop (`prompts/RUN-LOOP.md` → Overnight driver).
The loop does **not** ask — every problem, decision, or skipped part is recorded here and
the loop continues. Read this in the morning to see what merged and what needs a human.

Entry format:

```
## <YYYY-MM-DD HH:mm> · <step id, e.g. W8> · <DONE | BLOCKED | NOTE>
- What: <what happened>
- Where: <file / area>
- Error: <key excerpt, if any>
- Action: <committed+pushed <hash> / parked via git stash / safe default applied>
- Suggested fix: <for the human>
```

DONE entries can be a single line: `## <ts> · <step> · DONE · <hash> · <one-line summary>`.

---

<!-- The overnight loop appends below this line. -->
