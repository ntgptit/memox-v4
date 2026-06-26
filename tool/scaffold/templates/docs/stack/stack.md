# Stack — {{PROJECT_NAME}}

Detected/seeded stack: **{{STACK}}** (id: `{{STACK_ID}}`, source root: `{{SRC_DIR}}/`).

<!-- FILL: pin exact technologies + versions. Adding a dependency requires approval (CLAUDE.md hard rule). -->

| Concern | Choice | Version | Notes |
| --- | --- | --- | --- |
| Language / runtime | | | |
| Framework | | | |
| State management | | | |
| Persistence | | | |
| Routing | | | |
| i18n | | | |
| Testing | | | |
| Lint / format | | | |

## Verification chain

The build/test commands for this stack live in `tool/verify/verify.config.json`
and run only through `node tool/verify/run.mjs`. Update that file, not ad-hoc scripts.

## Related

- `docs/architecture/overview.md` — the layering this stack implements
- `docs/testing/test-strategy.md` — how this stack is verified
