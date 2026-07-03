# Props-Parity queue

Loop đọc file này (STEP 2). Chọn ô `[ ]` **đầu tiên** không nằm trong `BLOCKED.txt`,
deps đã `[x]`, theo thứ tự P0 → P1 → P2. Chi tiết từng task: [`WBS.md`](WBS.md).
Tick `[x]` sau khi merge; append id vào `DONE.txt`.

## P0 — Foundation (làm hết trước khi vào P1)

| | ID | Task |
|---|---|---|
| [x] | F.0 | Mapping/alias config `tool/parity/props_map.json` |
| [x] | F.1 | `tool/parity/props_check.mjs` (advisory) |
| [x] | F.2 | Hiệu chuẩn trên 15 shared → exceptions.json |
| [x] | F.3 | Exception schema + queue + WBS committed |

## P1 — Loop per-feature (23 unit / 68 `.d.ts`)

| | ID | Unit | #comp |
|---|---|---|---|
| [x] | C.01 | _shared | 3 |
| [x] | C.02 | game-recall | 2 |
| [x] | C.03 | game-typing | 2 |
| [x] | C.04 | game-mc | 1 |
| [x] | C.05 | game-matching | 1 |
| [x] | C.06 | game-picker | 3 |
| [x] | C.07 | player | 2 |
| [x] | C.08 | review | 2 |
| [x] | C.09 | study-result | 4 |
| [x] | C.10 | study-session | 9 |
| [x] | C.11 | dashboard | 4 |
| [x] | C.12 | deck-detail | 5 |
| [x] | C.13 | library | 6 |
| [x] | C.14 | drawer | 4 |
| [x] | C.15 | search | 2 |
| [ ] | C.16 | flashcard-editor | 2 |
| [ ] | C.17 | import | 2 |
| [ ] | C.18 | export | 2 |
| [ ] | C.19 | reminder | 2 |
| [ ] | C.20 | settings | 2 |
| [ ] | C.21 | statistics | 3 |
| [ ] | C.22 | theme | 2 |
| [ ] | C.23 | account-sync (deferred Flutter) | 3 |

## P2 — Seal

| | ID | Task |
|---|---|---|
| [ ] | Z.0 | props_check → blocking trong verify gate |
| [ ] | Z.1 | wiring-guard test `props_check_gate_test.dart` |
| [ ] | Z.2 | docs + ledger tổng |

> **Checker limitation to fix before Z.0 blocking** (found C.09): `props_check`
> only scans enums declared in the widget's own `.dart` file, so a prop whose
> Flutter type is an enum **imported** from another file (e.g. `ResultHero.tone` →
> `MxIconTileTone` in `mx_icon_tile.dart`) is not value-checked — enum drift on
> forwarded props is a false-negative. Resolve imported enums (or fold this into
> Z.0) so the blocking gate can't miss cross-file enum mismatches.
