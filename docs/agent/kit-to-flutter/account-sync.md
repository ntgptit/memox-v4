# Kit → Flutter conversion prompt — **account-sync** (W10 · DEFERRED / BLOCKED)

> SELF-CONTAINED. Đọc hết file này rồi thực thi. **KHÔNG vẽ lại UI, KHÔNG convert.**
> Kết luận đã chốt sẵn ở đầu: màn `account-sync` **CHƯA convert được** — bị chặn bởi
> W10-alpha + human gap GCP/OAuth. Nhiệm vụ THỰC của bạn ở prompt này là: **xác nhận
> trạng thái BLOCKED, ghi/đối chiếu divergence vào intent-ledger, và (tuỳ chọn) gate node
> DUY NHẤT hiện có (`account/sync` tile trong /settings)** — KHÔNG dựng `AccountScreen`.
> Nếu gặp DRIFT hoặc cần người quyết → DỪNG, báo, chờ.

---

## PROMPT ID

`kit-to-flutter/account-sync` · screen id `account` (LƯU Ý: id là `account`, KHÔNG phải
`account-sync`; contract file dùng `account.gen.json`) · feature `account-sync` · WBS **W10**
(Implemented **alpha**) · 5 kit state (signed-out / signed-in / syncing / conflict / offline).

**STATUS: 🔴 DEFERRED (conversion BLOCKED).** Không có `AccountScreen` trong FE. 8 node trong
`account.gen.json`, **chỉ 1** node được key trong FE — và nó nằm ở **màn khác**
(`/settings`, không phải màn account).

FE surface hiện có (grep xác nhận, xem mục "Trạng thái build"):
`lib/presentation/features/settings/screens/settings_screen.dart:158` — 1 `ListTile`
`key: const ValueKey('mx-node:account/sync')`, onTap → `SyncNowUseCase`.

---

## Baseline

```bash
git checkout main
git pull --ff-only
git checkout -b claude/kit-to-flutter-account-sync
```

Không bắt đầu khi working tree bẩn. `node tool/verify/run.mjs --quick` xanh trước khi sửa.

---

## Required reading (CHỈ đọc đúng các file này)

Universal (theo `CLAUDE.md`): `docs/_generated/repo-map.md`, `docs/_generated/where-is.md`,
`docs/business/index.md`, `docs/business/glossary.md`, `docs/contracts/error-contract.md`,
`docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`.

Screen-specific:
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/account-sync.md` — token-resolved
  DOM cho 5 state (mỗi state là full tree vì khác base quá nhiều). Chỉ để hiểu KIT muốn gì —
  **KHÔNG dựng lại**.
- `tool/parity/contracts/account.gen.json` — 8 keyed node (key/component/variant).
  **KHÔNG sửa** (generated). **Đã xác minh: có 3 `MxCard` (signin/profile/sync)** — nhưng
  không cái nào là `MxCard` trong FE (xem dưới).
- `tool/parity/contracts/account-sync.slots.skeleton.json` — slot skeleton (chỉ 4 nhóm text:
  appbar/signin/google/screen). AUTO-PROPOSED, KHÔNG ship.
- `tool/parity/contracts/account-sync.states.skeleton.json` — per-state node membership
  (SUPERSET). AUTO-PROPOSED, KHÔNG ship.
- `docs/business/account-sync/account-sync.md` — **W10 alpha**; §9 ràng buộc alpha; §12
  human gap GCP/OAuth. Đây là nguồn sự thật cho "vì sao BLOCKED".
- FE (surface duy nhất): `lib/presentation/features/settings/screens/settings_screen.dart`
  (dòng ~157–196: tile `mx-node:account/sync` + `_sync()` gọi `SyncNowUseCase`).
- `tool/parity/intent-ledger.json` — **account đã có 7 exception behavior sẵn** (screen,
  appbar, profile, sign, google, sync-now + 1 mục settings-profile). Đọc để KHÔNG ghi trùng.
- Reference TEST (khuôn, để hiểu 2 template — **KHÔNG copy nguyên vì màn này chưa convert**):
  - `test/presentation/features/study/review_parity_test.dart` — **Template A** (MxCard
    identity per-state).
  - `test/presentation/features/engagement/dashboard_states_test.dart` — **Template B**
    (state-composition: assert tập keyed node đúng chính xác theo state).
- Mẫu format prompt đã hoàn chỉnh để bám độ sâu: `docs/agent/kit-to-flutter/player.md`
  (Template A), `docs/agent/kit-to-flutter/library.md` (Template B).

**Drift check trước khi làm gì:** đọc `docs/business/account-sync/account-sync.md §12`. Doc đã
ghi rõ FE hiện tại = 1 tile /settings + `CloudSyncService`/`SyncNowUseCase`, **không có màn
account**, và human gap = client id / Drive API / per-platform OAuth. FE khớp doc → KHÔNG phải
drift; đây là **DEFERRED có chủ đích, đã document**. Nếu bạn phát hiện FE đã âm thầm có
`AccountScreen` hoặc thêm nút sign-in/sign-out mới (mâu thuẫn §12) → DỪNG, báo theo mẫu
`DRIFT DETECTED` trong `CLAUDE.md` và chờ người.

---

## Trạng thái build: account-sync CÓ được build trong FE không? → **KHÔNG (alpha, deferred)**

Câu hỏi (1) từ nhiệm vụ: `account.gen.json` có 3 MxCard (signin/profile/sync) — **bao nhiêu
được key?** Trả lời qua grep `mx-node:account/` trong `lib/`:

| kit node (gen.json) | component (gen) | variant | keyed trong FE? | ở đâu |
| --- | --- | --- | --- | --- |
| `mx-node:account/screen` | MxScaffold | null | ❌ | không có AccountScreen |
| `mx-node:account/appbar` | MxAppBar | null | ❌ | — |
| `mx-node:account/signin` | **MxCard** | elevated | ❌ | — |
| `mx-node:account/google` | MxButton | primary | ❌ | — |
| `mx-node:account/profile` | **MxCard** | elevated | ❌ | — |
| `mx-node:account/sync` | **MxCard** | elevated | ✅ **1** | `settings_screen.dart:158` — nhưng là **`ListTile`** trong /settings, KHÔNG phải `MxCard`, KHÔNG phải màn account |
| `mx-node:account/sync-now` | MxButton | outline | ❌ | — |
| `mx-node:account/signout` | MxButton | ghost | ❌ | — |

**Kết luận:** 1/8 node keyed, 0/3 MxCard render đúng thân MxCard. Node keyed duy nhất
(`account/sync`) là **entry-point tile trong màn Settings** trỏ tới `SyncNowUseCase`, KHÔNG
phải bất kỳ node nào của màn account trong kit. → **Màn `account-sync` KHÔNG phải là một keyed
screen chuẩn. Conversion BLOCKED / DEFERRED.**

### Vì sao BLOCKED (từ `account-sync.md §9, §12`)

- **W10 = alpha.** Cloud-sync orchestration (`CloudSyncService` + `GoogleDriveSyncService` +
  `SyncNowUseCase`, LWW mức snapshot) **đã build + có test**, reachable qua tile /settings.
  Nhưng **UI màn account (profile/signin/signout/sync-now/sync-status) CHƯA dựng.**
- **🔴 Human gap (không code được):** `CloudSyncConfig.clientId` mặc định rỗng → service trơ
  ("not configured"). Để bật thật cần con người làm: (1) GCP project bật **Drive API**;
  (2) **OAuth client id** (đưa vào `CloudSyncConfig` / `--dart-define`); (3) OAuth per-platform:
  Android SHA-1 + `google-services.json`, iOS URL scheme + `Info.plist`, desktop client.
- **`google_sign_in` = new dependency territory.** Bất kỳ việc dựng UI sign-in/sign-out
  "thật" nào cũng phụ thuộc `google_sign_in` + luồng OAuth. Theo `CLAUDE.md` trigger map
  ("new dependency → **Stop and ask. Approval needed.**") — **KHÔNG tự thêm/kích hoạt.** Nếu
  task tương lai yêu cầu bật sign-in, phải DỪNG và xin phê duyệt dependency + human gap trước.

---

## Chosen template: **KHÔNG áp dụng (DEFERRED)** — nhưng khi unblock thì dùng gì

Không chọn template để convert bây giờ, vì **không có màn để test**. Ghi nhận để lần sau:

- **Khi W10 unblock** (đã dựng `AccountScreen` thật, đã có OAuth): màn account body là
  **card-centric có MxCard keyed per-state** (signin/profile/sync là MxCard, đổi theo state)
  → **Template A** (review-style, giống `player.md`): với mỗi state, vòng MxCard keyed →
  assert identity + variant + slot MxTextRole present/absent.
- **Template B** (state-composition, giống `library.md`) là phương án thay thế nếu khi dựng,
  các card KHÔNG được key literal (dùng key động) — khi đó gate tập keyed control
  (`google`/`sync-now`/`signout`) đúng theo state.

→ Quyết định template **HOÃN** đến khi có FE. Prompt này KHÔNG viết parity test cho màn account.

---

## Gate-able node NGAY BÂY GIỜ (không phải màn account)

Chỉ **1** node keyed hiện hữu và nó thuộc màn **Settings**, không phải account:

| key | FE | ở màn | gate được? |
| --- | --- | --- | --- |
| `mx-node:account/sync` | `ListTile` (icon `cloud_sync_outlined` + title/subtitle, onTap → `SyncNowUseCase`) | `/settings` | ✅ nhưng đây là **entry-point**, không phải màn account |

**Việc gate node này thuộc parity của màn `settings`, KHÔNG phải màn account.** Kiểm tra
`docs/agent/kit-to-flutter/settings.md` + test parity của settings: nếu tile này **đã** được
phủ ở đó (present khi signed-in/có sync, đúng l10n `settingsSyncTitle`/`settingsSyncSubtitle`)
→ **KHÔNG làm lại** ở prompt này (tránh trùng gate). Nếu **chưa** phủ → phương án tối thiểu
hợp lệ duy nhất của prompt này là **thêm/đảm bảo 1 assert cho tile `account/sync` trong test
parity của settings** (không dựng màn mới). Ghi rõ lựa chọn vào final report.

7 node còn lại (`screen/appbar/signin/google/profile/sync-now/signout`) = **KHÔNG gate được**
(chưa tồn tại trong FE) → identity-rollout gap, gated on W10 unblock.

---

## Divergences → `tool/parity/intent-ledger.json` (đã có 7 mục — ĐỐI CHIẾU, không ghi trùng)

`intent-ledger.json` **đã** chứa các exception behavior cho screen `account` (và 1 cho
`settings`). **Đọc trước, đừng append trùng.** Các mục hiện có (verbatim `reason` tóm tắt):

1. `settings` · node `*` (profile) — kit đặt user-profile trong settings; MemoX local-first,
   không có account identity; surface account duy nhất = tile Google Drive sync → không có
   profile node ở settings.
2. `account` · `screen` — W10 alpha: sync orchestration built + reachable qua 1 tile /settings
   (keyed `account/sync`), **không có màn account riêng**; full account UI gated on GCP/OAuth
   human gap.
3. `account` · `appbar` — không có màn account (W10 alpha) → không có app bar account.
4. `account` · `profile` — local-first, không user identity → không profile surface.
5. `account` · `sign` (signin/signout) — sign-in/out UI thuộc W10 GCP/OAuth human gap; v1
   trigger sign-in ngầm qua `SyncNow` (`signInRequired`), không có nút auth standalone.
6. `account` · `google` — control Google-connect thuộc human gap (client id, Drive API,
   per-platform), chưa surface trong FE.
7. `account` · `sync-now` — nút sync-now standalone thuộc màn account (chưa dựng); v1 chạy
   `SyncNow` từ onTap tile `/settings` (`account/sync`), không có control sync-now riêng.

**Việc của bạn:**
- **KHÔNG** ghi lại 7 mục trên.
- Kiểm tra còn thiếu mục nào không. Ứng viên có thể **thiếu**: `account` · `signout` (mục #5
  gộp "sign" cho cả signin+signout — nếu ledger validator cần entry tách theo node key
  `signout` thì bổ sung; nếu "sign" đã cover cả hai theo convention project thì GIỮ NGUYÊN,
  ghi rõ trong report là đã cover). Cũng cân nhắc `account` · `sync-status` và `account` ·
  `sync-bar` nếu validator liệt kê chúng như node chưa map — nhưng chỉ thêm nếu công cụ parity
  THỰC SỰ đòi (đừng thêm cho vui). Mỗi mục mới theo đúng cấu trúc hiện có:
  `{screen, node, kind:"*", verdict:"exception", exceptionKind:"behavior", reason, source}`,
  `source` = `docs/business/account-sync/account-sync.md`.
- Nếu chạy công cụ parity (mục Verification) mà nó **không** báo node account nào "unmapped"
  → 7 mục hiện có là đủ; **không thêm gì**. Ghi "ledger complete, no new entries" trong report.

**KHÔNG ép FE về kit** ở bất kỳ điểm nào — toàn bộ màn account là chệch có chủ đích, đã document.

---

## State-map (5 kit state → FE reach được không?)

FE **không có màn account** ⇒ **không state nào của màn account reach được**. Trạng thái sync
thực sự sống ở kết quả `SyncNowUseCase` (`SyncOutcome.pushed/pulled/signInRequired` + `Err`)
hiển thị dưới dạng **snackbar** trong /settings, KHÔNG phải các card state của kit.

| kit state | node-set (kit) | FE reach? | ghi chú |
| --- | --- | --- | --- |
| `signed-out` | signin + google | ❌ coverage gap | không có màn account; sign-in ngầm qua SyncNow (`signInRequired` → snackbar), không có card signin |
| `signed-in` | profile + sync + sync-now + sync-status + signout | ❌ coverage gap | không có profile/sync card; không có nút signout; không có avatar/identity (local-first) |
| `syncing` | profile + sync + sync-bar + sync-status | ❌ coverage gap | SyncNow chạy đồng bộ trong onTap; **không có sync-bar/progress UI** — chỉ snackbar khi xong |
| `conflict` | profile + sync (merged banner) | ❌ coverage gap | LWW mức snapshot chạy trong use case; **không có conflict/merged UI** — kết quả là push/pull, không banner |
| `offline` | profile + sync (cloud_off) | ❌ coverage gap | không có offline sync-status card; offline = app vẫn chạy (BR-3), không có surface trạng thái offline riêng |

→ **5/5 state là coverage gap.** Toàn bộ state-map bị chặn bởi "không có màn account". Ghi rõ
trong final report; KHÔNG curate `account-sync.states.json` (không có gì để drive).

---

## Workflow — vì DEFERRED, đây là các bước THỰC TẾ (không convert)

1. **Xác nhận BLOCKED bằng grep** (đừng tin, hãy kiểm):
   `grep -rn "mx-node:account/" lib/` → phải ra **đúng 1** hit (`settings_screen.dart` ·
   `account/sync`). Nếu ra nhiều hơn (ai đó đã dựng màn account) → prompt này **stale**: DỪNG,
   báo, chờ người cập nhật prompt (chuyển sang Template A/B thật).
2. **Đối chiếu intent-ledger** (mục trên): đảm bảo 7 exception account/settings vẫn đúng
   `source` + `reason`; thêm mục còn thiếu **chỉ khi** công cụ parity đòi. Không trùng.
3. **KHÔNG tạo** `account-sync.slots.json` / `account-sync.states.json` (không có FE để gate).
   **Xoá 2 skeleton** `account-sync.slots.skeleton.json` + `account-sync.states.skeleton.json`
   **CHỈ KHI** project convention là "skeleton đã xử lý thì xoá" (player/library đã xoá skeleton
   sau khi curate). Ở đây **không curate** → cân nhắc: giữ skeleton (đánh dấu deferred) HAY xoá
   kèm 1 ghi chú trong README rằng account deferred. **Mặc định: GIỮ skeleton** (chưa tiêu thụ,
   màn chưa convert) và ghi trạng thái deferred ở README queue. Ghi rõ lựa chọn trong report.
4. **KHÔNG chạm FE** để dựng màn account. **KHÔNG thêm** `google_sign_in` hay nút auth (human
   gap + dependency approval). Nếu tile `account/sync` ở /settings **chưa** được gate trong test
   parity settings → thêm 1 assert tối thiểu ở test settings (present + đúng l10n key), KHÔNG
   dựng màn mới. Nếu đã gate → không làm gì FE-side.
5. **Cập nhật queue** `docs/agent/kit-to-flutter/README.md`: đánh dấu account-sync là
   **DEFERRED (W10 alpha, GCP/OAuth human gap + google_sign_in approval)** — KHÔNG đánh `[x]`
   done (nó chưa done, nó bị hoãn). Dùng ký hiệu deferred nhất quán với README hiện có.
6. **Doc parity:** không đổi behavior nào ⇒ thường chỉ cần đảm bảo `account-sync.md §12` vẫn
   khớp thực tế (nó khớp). Nếu bạn thêm ledger entry → đó là doc-adjacent, cùng commit.

---

## Hard rules (vi phạm = fail — trích `CLAUDE.md`)

- **KHÔNG dựng `AccountScreen` / signin / signout / profile / sync-now UI** trong prompt này.
  Màn account bị chặn bởi W10 human gap — dựng UI "thật" cần OAuth + `google_sign_in` = **Stop
  and ask, approval needed**.
- **KHÔNG thêm dependency** (`google_sign_in` hay bất kỳ gì) — dừng và xin phê duyệt.
- **KHÔNG copy MOCK COPY** từ kit spec ("Linh Tran", "linh@memox.app", "Sync across devices",
  "Last: 14:02 today", "Kept the latest (last-write-wins)"…) vào app/test. String thật lấy từ
  ARB (`lib/l10n/`).
- **KHÔNG hardcode** route/màu/text-style/duration/string.
- **KHÔNG ship skeleton làm curated**; và KHÔNG "curate" state/slot cho màn không tồn tại.
- **KHÔNG đánh dấu account-sync `[x]` done** — nó DEFERRED. Đánh dấu deferred có lý do.
- **KHÔNG ép FE về kit** — toàn bộ divergence account là chủ đích, đã ở intent-ledger.
- **KHÔNG sửa generated** (`*.g.dart`, `*.freezed.dart`, `account.gen.json`, `lib/l10n/generated/**`,
  `docs/_generated/**`).
- Nếu grep phát hiện màn account đã được dựng (mâu thuẫn prompt) → DỪNG, báo DRIFT, chờ.

---

## Verification

```bash
node tool/verify/run.mjs --full
```

Phải XANH (ghi pass-marker cho pre-commit hook). Vì thay đổi ở đây là docs/ledger-only (±1
assert tile settings), fan-out có thể bỏ qua theo `CLAUDE.md` ("Skip fan-out … cho docs-only /
trivial changes") — nhưng vẫn phải chạy `--full` (hoặc `--docs` nếu THUẦN docs) để có marker.
Nếu có đụng test settings → chạy `flutter test test/presentation/features/settings/` cho chắc.

Nếu `--full` fail hoặc skip → KHÔNG báo done.

---

## Commit

Vì DEFERRED, thường chỉ 1 commit docs/ledger (+ WBS trace). Nếu không có thay đổi ledger/FE
nào cần (7 exception đã đủ, tile đã gate) thì chỉ commit cập nhật README queue + WBS.

**Commit** (docs/ledger):
```
docs(parity): account-sync DEFERRED (W10 alpha) — mark deferred in kit-to-flutter queue

- account-sync conversion blocked: no AccountScreen in FE; only mx-node:account/sync
  (settings tile → SyncNowUseCase) is keyed. Full UI gated on GCP/OAuth human gap +
  google_sign_in dependency (approval needed).
- intent-ledger: account already has 7 behavior exceptions (screen/appbar/profile/sign/
  google/sync-now + settings-profile) — <no new entries | added: ...>.
- README kit-to-flutter queue: account-sync -> DEFERRED (not done).

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
```

**WBS** (`CLAUDE.md` §WBS): W10 không advance (vẫn alpha, human gap mở). Append 1 dòng Commit
Traceability Log (§10 `docs/project-management/wbs.md`), newest first:
`<8-char hash> · <YYYY-MM-DD> · W10 · account-sync kit→flutter DEFERRED (no FE screen; GCP/OAuth human gap + google_sign_in approval)`.
Nếu breakdown W10 không đổi: report ghi `WBS update: not needed — W10 stays alpha, human gap unchanged` (nhưng Commit Traceability Log vẫn append vì có touch WP).

---

## Final report (đưa vào tin nhắn cuối)

- **Status: DEFERRED / BLOCKED** — không convert. Lý do: không có `AccountScreen` trong FE
  (1/8 gen node keyed, và node đó là tile `/settings`, không phải màn account); W10 alpha +
  human gap GCP/OAuth (client id / Drive API / per-platform); `google_sign_in` = dependency
  approval needed.
- Template: **hoãn** — khi unblock dùng **A** (card-centric MxCard keyed per-state) như player.
- Gate-able node NGAY BÂY GIỜ: `mx-node:account/sync` (settings tile) — 1 node, thuộc parity
  **settings**, không phải account. [đã gate ở settings / đã thêm assert / không đụng].
- Identity-rollout gap (chưa key, gated on W10): screen, appbar, signin, google, profile,
  sync-now, signout (7).
- State-map: **5/5 coverage gap** (signed-out/signed-in/syncing/conflict/offline) — không màn
  account để drive; trạng thái sync = kết quả `SyncNowUseCase` (snackbar) ở /settings.
- Divergences → intent-ledger: 7 exception account/settings đã có [no new | added: ...].
- Contracts: KHÔNG curate slots/states (màn chưa tồn tại). Skeleton: [giữ (deferred) / xoá — lý do].
- Docs updated: README queue (account-sync → DEFERRED) [+ ledger nếu có]. account-sync.md §12
  vẫn khớp FE.
- `node tool/verify/run.mjs --full`: PASS/FAIL.
- WBS: dòng traceability appended / `not needed — W10 stays alpha`.
- Subagent review: bỏ qua (docs/ledger-only per CLAUDE.md) / hoặc tóm tắt nếu chạy.
