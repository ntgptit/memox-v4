<!-- GENERATED per screen by tool/parity/gen_convert_prompts.mjs from this template.
     Edit the template, not the generated docs/agent/kit-to-flutter/*.md. -->
# PROMPT ID: MX-KIT-TO-FLUTTER-theme

Repo:    https://github.com/ntgptit/memox-v4
Base:    main
Screen:  `theme`   ·   feature: `personalization`   ·   FE file: `personalization/screens/theme_screen.dart`
States:  `light` · `dark` · `accent-size`

## Goal
Chuyển/khớp màn `theme` từ UI kit (JSX) sang Flutter cho ĐÚNG kit — verify-gated, không đoán.
Đúng 1 màn. KHÔNG đổi màn khác, KHÔNG đổi kit JSX. (Phần lớn màn ĐÃ có FE — việc chính là
hoàn thiện: curate slot/state + per-state parity test + lấp identity gap, và align nếu lệch.)

## Mandatory baseline
git checkout main && git pull origin main
git config core.hooksPath .githooks
git status                       # sạch; nếu không → dừng, báo
git rev-parse HEAD
git checkout -b claude/kit-to-flutter-theme

## Required reading (chỉ các file này)
Kit truth:
- `docs/design/MemoX Design System/ui_kits/memox-app/specs/theme.md`     — DOM resolve token (node/layout/font/color/bbox/mx: hint)
- `docs/design/MemoX Design System/ui_kits/memox-app/shots/theme--*.png` — ảnh light+dark từng state (ĐỌC ẢNH, không đọc JSX kit)
Contracts (skeleton đã sinh sẵn):
- `tool/parity/contracts/theme.gen.json`                 — IDENTITY: key + component + variant
- `tool/parity/contracts/theme.slots.skeleton.json`     — ĐỀ XUẤT text→MxTextRole + l10n/bind (curate)
- `tool/parity/contracts/theme.states.skeleton.json`    — ĐỀ XUẤT node theo state (curate)
Mẫu đã convert đầy đủ (COPY pattern):
- `test/presentation/features/study/review_parity_test.dart` + `tool/parity/contracts/review.{slots,states}.json`
- `test/presentation/features/engagement/dashboard_parity_test.dart` + `dashboard.{slots,states}.json`
Nền Flutter (CHỈ lắp từ đây):
- `lib/presentation/shared/widgets/**` (mx_*.dart)  ·  `lib/core/theme/mx_*.dart` (token)  ·  `lib/l10n/app_{en,vi}.arb`
- FE hiện tại của màn: `lib/presentation/features/personalization/screens/theme_screen.dart`
Contract docs: `CLAUDE.md` · `docs/ui-ux/{ui-ux-contract,l10n-copy-contract}.md` · `docs/state/state-management-contract.md` · `docs/testing/test-strategy.md` · `docs/design/design-language.md`

## Drift check (trước khi code)
Nếu FE hiện có khác spec (component/variant/state) → DỪNG, báo theo mẫu `DRIFT DETECTED` (CLAUDE.md), chờ.
Divergence CÓ CHỦ Ý (vd Container thay MxCard, variant/nội dung lệch) → ghi `tool/parity/intent-ledger.json`, KHÔNG ép khớp.

## Workflow (đúng thứ tự)
1. Đọc `theme.md` + shots. Mỗi state: xác định node xuất hiện, layout (spec `layout:` → Row/Column/Wrap/Grid, KHÔNG toạ độ tuyệt đối), style (token `--memox-*` → `mx_*.dart`).
2. Curate `tool/parity/contracts/theme.slots.json` TỪ skeleton: VERIFY `role` (sửa nhầm label↔body↔title); điền `l10n`=ARB key (copy tĩnh) hoặc `bind`=domain field; bỏ chrome. Format theo `dashboard.slots.json`.
3. Curate `tool/parity/contracts/theme.states.json` TỪ skeleton: giữ node BODY từng state (bỏ chrome), key `mx-node:` prefix; state kit chưa render riêng ở FE → giữ + ghi "chưa map" (coverage gap). Theo `review.states.json`.
4. Implement/align `lib/presentation/features/personalization/screens/theme_screen.dart`: CHỈ Mx* + token (KHÔNG raw color/spacing/radius/text-style/duration, KHÔNG hardcode string). Mỗi node trong `.gen.json` → widget + `key: ValueKey('mx-node:<id>')` + variant khớp. Mỗi slot → `MxText` role đúng (l10n qua AppLocalizations, bind qua provider). State drive từ provider. Layering UseCase→Repository(interface)→DataSource; presentation không import data.
5. l10n: thêm key ngữ nghĩa vào CẢ `app_en.arb` + `app_vi.arb`.
6. Test `test/presentation/features/personalization/theme_parity_test.dart` — COPY `review_parity_test.dart`, đổi screen id + state-map (cách seed/pump tới từng state). Assert mỗi keyed MxCard: present-in-state → render + variant + slot role (+ l10n string nếu slot l10n); absent-in-state → `findsNothing`.
7. Xoá skeleton đã curate: `theme.slots.skeleton.json` + `theme.states.skeleton.json`.

## Hard rules (vi phạm = fail)
- KHÔNG tạo Mx*/token/route/string mới ngoài kit contract.  ·  Token-only, KHÔNG raw value.
- `ValueKey('mx-node:<id>')` khớp `data-mx-node`; KHÔNG đổi/xoá id.  ·  KHÔNG hoist widget node-literal ra sau wrapper key động (parity mù → rớt contract).
- KHÔNG sửa file generated (`*.g.dart`, `*.freezed.dart`, `l10n/generated/**`, `docs/_generated/**`).
- Divergence FE↔kit → `intent-ledger.json`, đừng ép.  ·  Mọi chữ là l10n key, thêm CẢ HAI arb.

## Verification (qua tool/verify)
`node tool/verify/run.mjs --full`  → PASS: doc_guard, gen_l10n, analyze, format, parity_contract, kit_fresh, slots_check, states_check, parity_fe_keys, test, style_parity.
MISSING (parity_fe_keys)=thiếu ValueKey · ORPHAN=key thừa · slots/states STALE=trỏ node kit không có · style_parity mismatch=variant/role/màu lệch.
Fail vì môi trường (thiếu Flutter/Chrome) → KHÔNG báo pass; ghi lệnh + lỗi + phần đã xong.

## Auto-review fan-out (sau verify PASS, trước report)
Song song: `code-reviewer` (diff working-tree) + `docs-drift-detector`. Sửa blocker trước khi xong.

## WBS + commit
- Cập nhật §10 `docs/project-management/wbs.md` (append-only, newest-first, hash 8 ký tự thật). 2 commit: (1) impl+slots+states+test; (2) WBS trace.
- `git commit -m "feat(personalization): convert theme to Flutter — identity + slots + per-state parity"` → commit WBS → `git push origin claude/kit-to-flutter-theme` → xác nhận local==remote.

## Final report
## Summary · ## States mapped (state→drive được?/gap) · ## Contracts (slots nodes·slots / states / skeleton deleted) · ## Divergences→intent-ledger · ## Verification (từng gate + paste summary) · ## Git (branch/commit/pushed/local==remote/status) · ## Result: Pass — hoặc — Chưa pass + lệnh lỗi + hướng sửa hẹp.
