# Navigation flow — {{PROJECT_NAME}}

Source of truth for routes. A new route requires updating BOTH this file and the
route constants in the SAME commit (CLAUDE.md hard rule).

## Route table

| Name | Path | Params | Push / replace | Notes |
| --- | --- | --- | --- | --- |
| <RouteName> | `/<path>` | | | |

<!-- FILL: one row per route. Match the constants in your routing layer exactly. -->

## Flow

<!-- FILL: entry points, redirects, deep links, back-stack rules. -->

```
<start> ─▶ <screen> ─▶ <screen>
```

## Rules

- No hardcoded path strings in features — reference the route constants.
- Redirect/guard logic documented here, not buried in widgets.

## Related

- `docs/architecture/overview.md` — where routing sits
- `docs/business/index.md` — screens these routes reach
