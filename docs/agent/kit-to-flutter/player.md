# Kit → Flutter — player (màn 11)

> PROMPT ID: `kit-to-flutter/player` · feature `study` · Template **A** (review-style, per-state MxCard identity)
> FE file: `lib/presentation/features/study/screens/player_screen.dart`
> Self-contained. Đọc hết trước khi code. Nếu gặp DRIFT hoặc DIVERGENCE cần người quyết → DỪNG, báo, chờ.

---

## 1. Baseline

```bash
git checkout main
git pull --ff-only
git checkout -b claude/kit-to-flutter-player
```

Xác nhận working tree sạch trước khi bắt đầu.

## 2. Required reading (chỉ đọc đúng các file này)

- `docs/design/MemoX Design System/ui_kits/memox-app/specs/player.md` — token-resolved DOM theo từng state (playing / paused / speed / end).
- `tool/parity/contracts/player.gen.json` — 11 keyed node (key + component + variant). **KHÔNG sửa** (generated).
- `tool/parity/contracts/player.slots.skeleton.json` — slot role đề xuất (superset) → curate thành `player.slots.json`.
- `tool/parity/contracts/player.states.skeleton.json` — node membership theo state (superset) → curate thành `player.states.json`.
- `lib/presentation/features/study/screens/player_screen.dart` — FE hiện tại.
- Reference TEST để COPY: `test/presentation/features/study/review_parity_test.dart` (**Template A** — đây là mẫu chọn).
- Reference contract đã curate (mẫu định dạng): `tool/parity/contracts/review.slots.json`, `tool/parity/contracts/review.states.json`.
- Contract nền: `docs/ui-ux/ui-ux-contract.md`, `docs/contracts/code-style.md`, `docs/business/glossary.md`.

**Drift check trước khi code:** player là màn auto-play (D-014 — không đổi lịch SRS). Nếu FE mâu thuẫn spec ở hành vi (vd: player được ghi là đổi schedule) → DỪNG, báo theo mẫu `DRIFT DETECTED` trong `CLAUDE.md`. Ở đây spec = "read through cards, never changes schedule" và FE khớp → OK, tiếp tục.

## 3. Template đã chọn: **A (review-style)** — vì sao

`player.gen.json` có node `mx-node:player/card` = `MxCard` (variant `elevated`), và node đó **đã được key bằng `ValueKey` trong FE** (`player_screen.dart:143`). Có MxCard keyed ⇒ dùng Template A: với mỗi state, assert từng MxCard keyed → identity + variant + từng slot MxTextRole render (present) / không render (absent). Copy nguyên `review_parity_test.dart`, đổi `review` → `player` và đổi cách seed/reach state (mục 6).

> KHÔNG dùng Template B (dashboard-composition): player thân là 1 màn card-centric có MxCard keyed, không phải list/overlay.

## 4. Gate-able node (đã key trong FE — grep xác nhận)

Grep `mx-node:player` trong FE cho 8 node đã key:

| key | component (gen) | variant (gen) | FE hiện tại |
| --- | --- | --- | --- |
| `mx-node:player/screen` | MxScaffold | null | ✓ MxScaffold |
| `mx-node:player/appbar` | MxAppBar | null | ✓ MxAppBar |
| `mx-node:player/card` | MxCard | elevated | ✓ MxCard (padding lg) — **gate node chính của Template A** |
| `mx-node:player/prev` | MxIconButton | null | ✓ MxIconButton |
| `mx-node:player/playpause` | MxFab | null | ⚠ MxIconButton (divergence — mục 5) |
| `mx-node:player/next` | MxIconButton | null | ✓ MxIconButton |
| `mx-node:player/replay` | MxButton | primary | ⚠ MxButton variant outline (divergence — mục 5) |
| `mx-node:player/close` | MxButton | ghost | ✓ MxButton (default) |

**Chỉ `mx-node:player/card` là MxCard** → là node duy nhất Template A vòng qua (giống review chỉ vòng MxCard). Các node khác là identity đã có key nhưng không phải MxCard → test không assert variant cho chúng ở vòng MxCard; chúng được phủ ở tầng state-membership (`player.states.json`).

### Node trong gen.json NHƯNG chưa key trong FE → identity-rollout gap (ghi nhận, không ép)

- `mx-node:player/back`, `mx-node:player/options`, `mx-node:player/text-size` — appbar action; FE `MxAppBar` chưa expose các action này ⇒ **chưa có trong FE**. Không thêm mới trong task này (ngoài scope); note gap.
- `mx-node:player/speed` — nút tốc độ (MxButton ghost) — **không tồn tại trong FE**. Gap.
- `mx-node:player/progress` — kit là dải dot progress; FE render `MxText.label('${_index+1} / ${cards.length}')` KHÔNG key ⇒ gap (khác cả widget lẫn identity).
- `mx-node:player/end` — kit là container empty-state; FE render `MxContentBounds` KHÔNG key ⇒ gap. (`player/replay` + `player/close` bên trong ĐÃ key.)
- `mx-node:player/speed-control` — segmented control chỉ có ở state `speed`; **không tồn tại trong FE** ⇒ gap.

Liệt kê nguyên các gap này trong **final report** (mục "Identity-rollout gap"). Không rollout key mới cho appbar-actions/speed trong task này trừ khi bạn cũng thêm hành vi thật — đây là task style-parity, không phải feature.

## 5. Divergence → `tool/parity/intent-ledger.json` (KHÔNG ép về kit)

Ghi các mục sau vào `tool/parity/intent-ledger.json` (append, giữ format hiện có; nếu file chưa có mục player → tạo entry theo cấu trúc các screen khác). **Không** sửa FE để khớp kit ở các điểm này — đây là chệch có chủ đích:

1. `mx-node:player/playpause` — kit `MxFab`, FE `MxIconButton` (variant `primary`). Lý do: FE dùng MxIconButton cho cụm 4 nút transport đồng nhất (prev/playpause/next + speak). Ledger reason: `"fe uses MxIconButton(primary) not MxFab for transport-row consistency"`.
2. `mx-node:player/replay` — kit variant `primary`, FE `MxButtonVariant.outline`. Lý do: end-state đôi nút Replay(outline)+Close(default); FE chọn outline làm hành động phụ. Ledger reason: `"fe replay = outline (secondary emphasis), kit = primary"`.
3. Slot `player/card`.meaning — kit mock role `displaySmall`/700 + label "MEANING"; FE render `MxText(card.meaning, role: bodyLarge)`. Đây là slot binding thực của FE (giống review sửa meaning → bodySmall). Không phải drift — curate `player.slots.json` theo FE truth (`bodyLarge`), ghi 1 dòng note trong `$curated` của slots.json, KHÔNG cần ledger.

Sau khi ghi ledger, các divergence này KHÔNG được làm fail parity test (test A chỉ assert variant cho MxCard = `player/card`, không cho playpause/replay).

## 6. State-map (kit state → cách drive FE tới đúng node-set)

FE là 1 `ConsumerStatefulWidget` điều khiển bởi `_cards` (load qua `BuildStudyQueueUseCase` từ deck) và `_index` / `_playing`. Pump pattern: **giống `review_parity_test.dart`** — seed Drift in-memory (languagePair + deck + N card), override `databaseProvider` + `clockProvider(_FixedClock)`, `pumpWidget(host)`, rồi pump vài nhịp 50ms (player load queue trong `initState`; KHÔNG dùng `pumpAndSettle` vì `MxStateView.loading` có thể spin — dùng vòng `for` pump như review).

| kit state | FE reach được? | Cách reach | Node-set FE |
| --- | --- | --- | --- |
| `browsing` (≈ kit `playing`/`paused`) | ✓ | seed **1 card** → `_cards=[1]`, `_index=0` → nhánh `_player()` | `player/card`, `player/prev`, `player/playpause`, `player/next` |
| `end` | ✓ | seed **0 card** → `cards.isEmpty` → nhánh `_end()` | `player/replay`, `player/close` (card absent) |
| `paused` | ✗ coverage gap | `_playing` chỉ đổi ICON của `player/playpause` (play_arrow↔pause), KHÔNG đổi node identity/set. playing & paused render **cùng node-set** ⇒ không phải state phân biệt được ở tầng identity. | (= browsing) |
| `speed` | ✗ coverage gap | FE KHÔNG có `player/speed` / `player/speed-control` (không render segmented). Không reach được. | — |

**Quyết định curate `player.states.json`:** đặt state key theo cái FE reach được, giống review (review gộp `editing`/`audio` là gap, chỉ drive `browsing`+`end`):

```json
{
  "browsing": ["mx-node:player/card"],
  "paused":   ["mx-node:player/card"],
  "speed":    ["mx-node:player/card"],
  "end":      ["mx-node:player/replay", "mx-node:player/close"]
}
```

- `browsing` = state có card (chrome appbar/screen/prev/next/playpause KHÔNG liệt kê — chỉ giữ BODY MxCard-scope node để test Template A vòng qua, đúng như `review.states.json` chỉ giữ `review/term`+`review/meaning` cho browsing).
- `paused` / `speed` giữ để đủ bộ (documented) nhưng **không drive** trong test (coverage gap — ghi rõ trong `$curated` note giống review).
- `end` = `replay` + `close`.

> Lưu ý Template A vòng `if (node.component != 'MxCard') continue;` ⇒ test chỉ thực chất assert `player/card` present ở `browsing`/`paused`/`speed` và absent ở `end`. Vì `replay`/`close` không phải MxCard, chúng KHÔNG bị assert ở test A — đó là lý do phải note coverage rõ. Nếu muốn cũng gate present/absent cho end-state buttons, có thể thêm 1 vòng phụ non-MxCard (optional, giống dashboard state-set) — nhưng để bám sát Template A, giữ đúng review-style là đủ cho gate này.

## 7. Workflow (theo thứ tự, mỗi bước một layer)

1. **Curate `tool/parity/contracts/player.slots.json`** từ `player.slots.skeleton.json`:
   - `mx-node:player/card`: `{ "name": "term", "role": "displayLarge", "bind": "card.term" }`, `{ "name": "meaning", "role": "bodyLarge", "bind": "card.meaning" }` (sửa từ skeleton `displaySmall` → FE truth `bodyLarge`; bind = user content, KHÔNG l10n).
   - Bỏ `player/speed` khỏi slots (FE không render).
   - `player/appbar` title: FE dùng `l10n.studyPlayer` — nếu muốn cover, để dạng bind l10n `studyPlayer`, nhưng test A chỉ vòng MxCard ⇒ có thể bỏ. Giữ tối giản như `review.slots.json`.
   - Thêm `$curated` note: giải thích meaning=bodyLarge (FE truth, không phải kit mock), scope = 1-card player queue.
2. **Curate `tool/parity/contracts/player.states.json`** từ skeleton theo bảng mục 6 (chrome loại bỏ; `paused`/`speed` = documented-not-driven gap; `$curated` note nêu rõ playing/paused cùng node-set và speed không tồn tại FE).
3. **Align FE** `player_screen.dart` từ `Mx*` + token, mỗi node có `ValueKey('mx-node:...')`:
   - Xác nhận 8 key hiện có đúng chính tả (grep đã confirm). KHÔNG hoist node-literal sau dynamic key.
   - Progress: FE đang `MxText.label` — token-only, không hardcode; nếu để nguyên (chưa render dot-bar) thì KHÔNG cần thêm key `player/progress` (giữ gap, note). KHÔNG hardcode màu/spacing.
   - KHÔNG thêm node mới cho appbar-actions/speed (ngoài scope style-parity).
   - Divergence (playpause=MxIconButton, replay=outline) giữ nguyên → đã vào intent-ledger.
4. **l10n**: các key `studyPlayer`, `playerEnd`, `playerReplay`, `commonClose` đã có **cả** `app_en.arb` và `app_vi.arb` (đã verify). Nếu bạn thêm/đổi bất kỳ chuỗi user-facing nào → thêm vào **cả hai** ARB cùng lúc rồi regen. Không copy mock copy từ kit ("All played", "TOPIK I — Vocabulary"…) vào app — luôn từ ARB.
5. **Viết test** `test/presentation/features/study/player_parity_test.dart` — COPY `review_parity_test.dart`, đổi:
   - đường dẫn contract `review.*` → `player.*`;
   - import + host dựng `PlayerScreen(nodeId: deckId)` thay `ReviewScreen`;
   - `_stateSeed = { 'browsing': 1, 'end': 0 }` (paused/speed không drive — comment lý do coverage gap);
   - seed giữ nguyên pattern (languagePair ko→vi, 1 deck, N card `term:'학교'`);
   - pump vòng `for` 50ms (không `pumpAndSettle`).
6. **Xoá 2 skeleton**: `player.slots.skeleton.json` + `player.states.skeleton.json` sau khi đã curate ra bản chính (giống review/dashboard không còn skeleton).

## 8. Hard rules (vi phạm = task fail)

- **Token-only**: không hardcode màu, radius, spacing, text style, duration, chuỗi user-facing. Dùng `Mx*` widget + theme token + `MxSpacing`.
- **Không node-literal hoist sau dynamic key**: mỗi `ValueKey('mx-node:...')` phải là `const` gắn đúng node tĩnh; không sinh key động theo index/state.
- **Divergence → intent-ledger**, không ép FE về kit (playpause MxFab, replay primary).
- **l10n cả hai ARB**: mọi chuỗi mới vào `app_en.arb` **và** `app_vi.arb` cùng commit; regen l10n; không sửa `lib/l10n/generated/**` tay.
- Không sửa file generated (`*.g.dart`, `*.freezed.dart`, `player.gen.json`, `docs/_generated/**`).
- Không thêm dependency mới (Stop & ask nếu cần).
- Không đổi hành vi SRS/schedule (D-014: player không đổi lịch).
- Doc-code parity: nếu chạm hành vi user-visible / route → update doc tương ứng cùng commit (task này thuần style-parity ⇒ nhiều khả năng `WBS update: not needed` + không đổi business doc; xác nhận rồi ghi rõ).

## 9. Verification

```bash
node tool/verify/run.mjs --full
```

Phải PASS (viết pass-marker cho pre-commit hook). Trong đó có test parity mới + freshness check của specs. Nếu `--full` fail hoặc bị skip → KHÔNG được báo done. Trong lúc dev có thể `--quick` (không marker).

Sau khi verify PASS, trước final report: fan-out `code-reviewer` (review diff working-tree) + `docs-drift-detector` song song; gộp findings vào mục "Subagent review", fix blocker trước khi kết.

## 10. Commit (2 commit)

1. **impl**: contracts curate (`player.slots.json`, `player.states.json`) + xoá 2 skeleton + FE align + test + (ARB nếu đổi) + intent-ledger.
   ```
   feat(parity): style-parity — player (màn 11) — Template A, card gate + end/browsing states
   ```
2. **WBS trace**: append 1 dòng vào Commit Traceability Log (§10 `docs/project-management/wbs.md`), newest first:
   ```
   <8-char hash> · 2026-07-01 · <WBS IDs> · style-parity player (Template A; card+end gated, paused/speed coverage gap, playpause/replay → intent-ledger)
   ```

Đổi ô `[ ] 11-player.md` → `[x]` trong `docs/agent/kit-to-flutter/README.md` (queue) cùng commit impl hoặc trace.

## 11. Final report format

```
## player — kit→flutter DONE
- Template: A (review-style, MxCard identity per-state)
- Gate-able nodes (keyed): screen, appbar, card(MxCard elevated), prev, playpause, next, replay, close  [8]
- Contracts: player.slots.json + player.states.json curated; 2 skeleton deleted
- States driven: browsing (1 card), end (0 card). Coverage gap: paused (same node-set as browsing — _playing chỉ đổi icon), speed (không có speed-control trong FE)
- Divergences → intent-ledger: playpause (MxIconButton vs MxFab), replay (outline vs primary)
- Identity-rollout gap (chưa key trong FE): player/back, player/options, player/text-size, player/speed, player/progress, player/end, player/speed-control
- l10n: studyPlayer/playerEnd/playerReplay/commonClose đã có ở app_en.arb + app_vi.arb [no new keys | new keys: ...]
- Docs updated: <list | none — style-parity only>
- WBS update: <line appended | not needed — reason>
- Verify: node tool/verify/run.mjs --full → PASS
- Subagent review: <blockers fixed | minor findings ...>
```
