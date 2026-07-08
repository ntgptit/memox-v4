# WBS — Sinh test E2E từ scenario (màn hình → DB)

Sinh test **từ scenario + [DECISIONS.md](DECISIONS.md)**, KHÔNG bám code app (chống tautology).
Mỗi test trích `SC-*` + `DEC-*`; assert **cả UI lẫn DB thật**; test **đỏ khi code sai**.

## Nguyên tắc harness
- **Drift in-memory THẬT** (`NativeDatabase.memory()`) + **repository thật** — KHÔNG dùng
  `FakeStore` cho hành vi cốt lõi (fake chỉ dành golden/unit). Assert bằng **query DB thật**.
- Pump **cây widget thật** qua router/app, drive như người dùng (tap/nhập), rồi assert UI (find)
  + DB (select). Chạy trong `flutter test` (không cần emulator) → nhanh, CI-friendly.
- Test tag `e2e`; mỗi test doc-comment/tên trích `SC-<SCREEN>-NN`. `integration_test` (emulator)
  để dành 1 tập smoke sau.

## Tasks (thứ tự MANIFEST · 1 task = 1 màn = 1 PR)

| ID | Task | Đầu ra | DoD |
|---|---|---|---|
| **T.0** | Harness E2E | `test/e2e/support/e2e_harness.dart` (in-memory Drift + pump app + helpers: seedDb, pumpApp, DB-query asserts) | harness build + 1 smoke test xanh; gate xanh |
| T.1 | dashboard | `test/e2e/dashboard_e2e_test.dart` | mọi SC-DASHBOARD-* có test/`N/A`; theo DECISIONS; gate xanh |
| T.2 | library | `test/e2e/library_e2e_test.dart` | — |
| T.3 | deck-detail | `test/e2e/deck_detail_e2e_test.dart` | — |
| T.4 | flashcard-editor | … | — |
| T.5 | game-picker | … | — |
| T.6 | game-matching | … | — |
| T.7 | game-mc | … | — |
| T.8 | game-recall | … | — |
| T.9 | game-typing | … | — |
| T.10 | review | … | — |
| T.11 | player | … | — |
| T.12 | study-result | … | — |
| T.13 | search | … | — |
| T.14 | statistics | … | — |
| T.15 | reminder | … | — |
| T.16 | theme | … | — |
| T.17 | import | … | — |
| T.18 | export | … | — |
| T.19 | drawer | … | — |
| T.20 | study-session | … | — |
| T.21 | settings | … | — |

(account-sync HOÃN v1 → bỏ.)

## DoD chung mỗi task
1. Mỗi `SC-<screen>-*` (trong `docs/scenarios/<screen>.md`) → **1 test** hoặc **`// N/A: <lý do>`**.
   `N/A` CHỈ dùng cho: chiều thuần-visual đã phủ golden, hoặc feature **HOÃN v1** (vd account-sync).
   **KHÔNG** dùng N/A để né một hành vi chưa chạy được.
2. Test theo **DECISIONS** cho các điểm OQ (không tự chế lại).
3. **Assert TỪNG TRƯỜNG:** mọi assert DB kiểm **đủ tất cả cột** của row liên quan (id + mọi giá trị),
   không chỉ 1 trường. Ưu tiên so khớp cả row (companion/record equality) để không sót cột.
4. `node tool/verify/run.mjs` **xanh** với test **THẬT xanh** (không phải skip); PR CI xanh → merge.
5. Traceability: tên test chứa `SC-…`; comment trích `DEC-…` khi quyết theo default.

## Quy trình chạy & xử lý sự cố (BẮT BUỘC)

**A. Test bị kẹt (hang):**
- Mọi test có **`timeout: Timeout(Duration(seconds: 30))`**; harness dùng `settle()` **bounded**
  (không chờ vô hạn animation); CI job có timeout tổng.
- Test **timeout / treo = DEFECT** (deadlock, future không resolve, rebuild vô hạn) → **điều tra
  root-cause + fix**, KHÔNG bỏ qua, KHÔNG tăng timeout để né.
- **Root-cause đã gặp & fix (T.1):** `testWidgets` chạy trong **FakeAsync** → query **Drift**
  (in-memory, cần async THẬT) không resolve ⇒ màn kẹt loading + shimmer `..repeat()` chạy vô hạn ⇒
  treo. Fix ở harness `settle()`: chèn cửa sổ `tester.runAsync` (real async) xen kẽ `pump`, dừng khi
  `!hasScheduledFrame`. **Mọi test E2E phải dùng `settle(tester)`**, KHÔNG `pumpAndSettle()` trần.

**B. Phát hiện bug (test đỏ) → FIX, không SKIP:**
1. Chẩn đoán root-cause: **lỗi code app** hay **test/spec (DECISION) sai**?
2. Lỗi code → **fix code** (minimal; kit-first nếu là UI) trong **cùng PR màn** (hoặc PR fix
   tiền đề trước) → chạy lại **xanh**.
3. Test/DECISION sai → sửa test / cập nhật `DECISIONS.md` → chạy lại **xanh**.
4. **Cấm** `skip: true` để cho gate xanh — skip che bug. Màn **chưa "done"** khi còn test đỏ/skip.
5. Mỗi bug fix ghi rõ trong commit (`fix: <SC-ID> …`) để truy vết.

**C. Không hạ chuẩn để pass:** không nới assert, không xoá test, không N/A né. Nếu bí → dừng, báo,
ghi finding — không giả xanh.

## Loop
1 màn → tạo PR → merge main → **chờ 60s** → màn tiếp (thứ tự MANIFEST). Bắt đầu **T.0** (harness),
rồi T.1…T.21. Màn chỉ merge khi **mọi test xanh thật** (Quy trình B). Dừng khi hết task hoặc bị
chặn — ghi chỗ dừng để resume. **(Hiện: T.0 + T.1 dashboard đã xanh & merge — tiếp T.2 library.)**

## Truy nguồn
scenario `docs/scenarios/<screen>.md` (SC-*) · quyết định `DECISIONS.md` (DEC-*) · schema
`docs/database/schema-contract.md` · bảng D-xxx `docs/decision-tables/core-decision-table.md`.
