# `tool/parity/` — props-parity gate

Diffs each kit component's **typed prop contract** (`<Component>.d.ts`) against the
corresponding **Flutter widget constructor**, so "does the Flutter widget expose the
same API the kit promises" is a **gate**, not a memory game. Plan + full task list:
[`docs/agent/props-parity/WBS.md`](../../docs/agent/props-parity/WBS.md).

> **Scope.** This gate covers the **API surface only** — prop names, enum value
> spaces, optional/required. It does **not** check visual fidelity (padding, color,
> layout, state machine) — that is the DOM spec / gallery's job. A component can pass
> `props_check` and still render wrong; that is by design, not a gap here.

## Files

| File | Role |
| --- | --- |
| `props_map.json` | Alias/drop/type/enum config (this doc's schema). Input to the checker. |
| `props_check.mjs` | The checker (F.1). Reads the two contracts, applies `props_map.json`, prints drift. |
| `../../props-parity.exceptions.json` | Typed, per-prop **intentional** divergences (see reasons below). |

## `props_map.json` schema

| Key | Meaning |
| --- | --- |
| `componentsRoot` / `featuresRoot` / `sharedRoot` | Where kit `.d.ts` live (shared core/nav/surfaces · feature-local · `_shared`). |
| `flutterSharedRoot` / `flutterFeaturesRoot` | Where the Flutter widgets live. |
| `fileAlias` | `"<kitDir>/<PascalName>" → {class, file}` **only** when `snake_case(PascalName)` diverges (e.g. `dashboard/ContinueCard → ContinueDeckCard`). Keyed by dir so same-named components in different dirs stay distinct. |
| `propNameAlias` | web prop → ordered list of accepted Flutter param names. A kit prop is **satisfied** if the ctor declares **any** name in its list (`children → label\|child\|text`, `onClick → onPressed\|onTap`). |
| `propDrop.names` | web-only props (`node`, `className`, `style`, `type`, …) dropped before diffing — never a MISSING. |
| `typeMap` | web `.d.ts` type → Flutter type for the optionality/type dimension (`string@icon → IconData`, `ReactNode → Widget`, `() => void → VoidCallback`). |
| `enumValueAlias` | union literal → Flutter enum value name. `kebabToCamel:true` normalizes `primary-soft → primarySoft` generically; `map` lists irregulars (`sm → small`). Naming **only**. |
| `enumBaseNote` | Why extra Flutter enum values (the "base" the kit omits) are **not** auto-accepted — each must be an `enum-base-expansion` exception. |
| `diffDimensions` | The four drift classes the checker emits. |

## Exceptions (`props-parity.exceptions.json`)

A JSON array of typed, intentional divergences. **Every entry is schema-checked on
every run** — a missing field or an unknown `reason` fails the process (exit 2),
even in advisory mode, so a malformed exception can never silently suppress real
drift. Required fields:

| Field | Rule |
| --- | --- |
| `component` | kit key, `"<dir>/<PascalName>"` (e.g. `core/MxButton`) |
| `prop` | the diverging prop, or `"*"` for whole-component (`deferred-screen`/`flutter-only` only) |
| `reason` | one of the closed set below |
| `note` | why the divergence is intentional (required — no silent entries) |

### Reasons — closed set

| Reason | For |
| --- | --- |
| `web-only` | prop meaningful only on web (already covered by `propDrop`; use for edge cases) |
| `enum-base-expansion` | Flutter enum adds the base value the kit expresses by omitting the prop (`neutral`, `standard`, `medium`) |
| `flutter-idiom` | platform rename beyond the global alias table |
| `deferred-screen` | component on a deferred screen (account-sync) — no Flutter counterpart yet |
| `flutter-only` | Flutter widget with no kit component (`library_node_card`, `search_app_bar`) — not gated by a `.d.ts` |
| `fixture-parameterized` | kit component is a **static visual fixture** (hardcodes sample content + literal node ids so the parity generator sees real DOM); the Flutter widget parameterizes that content / adds the real callbacks. Common in the game/study POC widgets (e.g. `TermCard` hardcodes 친구; Flutter takes `term`). |

An exception is **per-prop** (`"prop": "size"`) except `deferred-screen` / `flutter-only`
which use `"prop": "*"`. A `"*"` + `flutter-idiom` is a **red flag** (hiding drift).

## Usage

```bash
node tool/parity/props_check.mjs            # all components
node tool/parity/props_check.mjs --only dashboard   # one feature unit
```

Advisory (exit 0) through P0/P1; flipped to **blocking** (exit≠0 on undeclared drift)
in P2 task Z.0, and wired into `tool/verify/run.mjs`.
