# Kit → Flutter — conversion queue (AI-authored prompts)

Each `<screen>.md` here is a **tailored, self-contained** conversion prompt written by
an analysis agent that read the screen's spec + `gen.json`/`slots`/`states` skeletons +
the real FE file. They are NOT stamped from a template — each encodes that screen's real
structure: which parity template fits, exactly which nodes are gate-able (with FE
citations), which divergences go to `tool/parity/intent-ledger.json`, and which kit
states map to a drivable FE state vs a coverage gap.

## Two parity templates (a screen uses one)
- **A — review-style** (`test/presentation/features/study/review_parity_test.dart`): per
  state, assert each keyed **MxCard**'s identity + variant + slot `MxTextRole`. Used when
  the screen has keyed MxCard node(s) in the FE.
- **B — dashboard-composition** (`test/presentation/features/engagement/dashboard_states_test.dart`):
  per state, assert the keyed **node SET** renders exactly. Used for list/overlay screens
  with few/no keyed MxCard.

## How to run (loop, one screen per iteration)
> `/loop` Đọc `docs/agent/kit-to-flutter/README.md`, chọn màn **pending** đầu tiên (`[ ]`),
> đọc + thực thi ĐẦY ĐỦ file prompt của màn đó (baseline `checkout main` → curate
> slots/states → align FE keys → l10n → parity test → `node tool/verify/run.mjs --full` →
> 2 commit + WBS trace → push), rồi đổi ô đó thành `[x]`. Mỗi vòng đúng 1 màn. Nếu prompt
> bảo **DỪNG** (drift / divergence cần người quyết) → dừng, báo, chờ. Hết pending → báo xong.

`dashboard` + `review` đã convert (curated slots/states + parity test) — không có prompt.
Xếp theo thứ tự chạy đề xuất: **gate mạnh/sạch trước**.

## Queue

| # | Screen | Template | Gate-able | Notes |
| --- | --- | --- | --- | --- |
| [x] | dashboard | A | 4 MxCard | done (POC) |
| [x] | review | A | 2 MxCard | done (template) |
| [x] | `player.md` | **A** | 8 (1 MxCard) | done — playing+end gated; paused/speed gap; 2 divergence→ledger |
| [x] | `study-session.md` | **A** | 6 (1 MxCard) | done — stage1 present / stages+due absent; slot=term-only (meaning là sibling) |
| [x] | `game-recall.md` | **A** | 7 (2 MxCard) | done — term/meaning Card/Text→MxCard; before-reveal/revealed gated |
| [x] | `theme.md` | **A** | 6 (1 MxCard) | done — preview identity+flat-via-ledger; 3 states non-node-distinct |
| [x] | `deck-detail.md` | B | 10 | done — loaded/empty gated; error+overlays=gap; add-in-empty→ledger |
| [x] | `statistics.md` | B | 7 | done — 5 heads gated (loaded/insufficient/loading); 6 divergence→ledger |
| [x] | `settings.md` | B | chrome | done via generator fix — kit summary-row model ≠ FE flat rows, so body nodes (games/srs-*/theme) are identity-rollout gaps (not 1:1 mappable); no per-state gate |
| [ ] | `flashcard-editor.md` | B | 5 | form; +keyboardType note; 4 gap states |
| [ ] | `reminder.md` | B | 2 | time=Container, time-edit=ListTile → ledger |
| [ ] | `export.md` | B | 3 | progress key trên Text≠MxCard; exporting gap |
| [ ] | `import.md` | B | 4 | ⚠ DRIFT? FE single-scroll vs kit 5-step wizard |
| [ ] | `search.md` | B | 4 | ⚠ FE chỉ key chrome → roll out 4 body key |
| [ ] | `library.md` | B | 7 | deck card key động; 7 overlay gap states |
| [ ] | `game-typing.md` | B | 7 | meaning=Card≠MxCard; 4 gap states |
| [ ] | `game-mc.md` | B | 4 | prompt=Card; D-015 no feedback frame |
| [ ] | `game-picker.md` | B | 2 | ⚠ DRIFT? not-enough tại count==0 vs kit "<4 words" |
| [ ] | `game-matching.md` | B | ~1 | gate mỏng nhất (shared GameScreen scaffold) |
| [ ] | `drawer.md` | B | 5 | shared component (Scaffold.drawer), không phải route |
| [ ] | `study-result.md` | B | 3 | goal MxCard chưa key; 6/7 states là gap |
| [~] | `account-sync.md` | — | — | **DEFERRED / BLOCKED** — W10 alpha + `google_sign_in` (cần duyệt dependency) |

⚠ = prompt gắn cờ khả năng DRIFT (business-rule / structural) → **DỪNG** và xác nhận với người.
