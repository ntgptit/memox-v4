# Kịch bản kiểm thử E2E — hành vi người dùng thật (màn hình → DB)

Bộ **scenario viết TRƯỚC test**, mô phỏng thao tác người dùng thật đi xuyên toàn stack:
**UI (widget) → provider/use-case → repository → DB (Drift)**. Mỗi scenario khẳng định
kết quả ở **cả hai đầu**: giao diện (state theo kit) **và** dữ liệu bền vững (bảng DB).

## Nguyên tắc số 1 — chống "test theo code" (tautology)

> Scenario bám **YÊU CẦU**, KHÔNG bám code. Test được sinh **từ scenario**, không phải
> đọc code rồi viết test khớp code.

Nếu để agent đọc code app rồi viết test, test chỉ "đóng dấu" hành vi hiện tại — **kể cả
bug** — và luôn xanh. Ngược lại, scenario ở đây phát biểu *điều PHẢI xảy ra theo spec*;
nếu code sai, test (sinh từ scenario) **phải đỏ**. Vì vậy mọi scenario **trích nguồn**
tới spec, KHÔNG trích tới `lib/...`.

## Ba nguồn chuẩn (không lấy từ code app)

| Nguồn | Định nghĩa | Dùng cho |
|---|---|---|
| **UI kit** → `docs/contracts/<screen>.md`, `MANIFEST.yaml`, `docs/wireframes/` | màn nào, **state nào** phải render | Assertion **UI** trong mỗi bước |
| **Bảng quyết định** → `docs/decision-tables/core-decision-table.md` (D-xxx: Given/When/Then) | nhánh **hành vi** đã chốt | Điều kiện + kết quả kỳ vọng |
| **Business specs** → `docs/business/*` (BR-x, quy tắc SRS/cap/streak…) | **quy tắc** đứng sau | Số liệu/quy tắc chi tiết (khoảng cách ô, cap 20/ngày…) |

Schema DB để viết assertion tầng dữ liệu: `docs/database/schema-contract.md`
(bảng `decks`, `cards`, `card_meanings`, `srs_states`, `review_logs`, `daily_activity`,
`language_pairs`, `settings`…).

## Định dạng một scenario

Mỗi scenario có **header truy nguồn** rồi các bước **Given / When / Then**, mỗi Then tách
rõ **UI** và **DB**:

```
### SC-<FEATURE>-<n> — <tên ngắn>
Nguồn: D-002, D-017 · kit: study-session[stage1..5], study-result[standard] · BR: srs-review §xếp-lịch
Tiền điều kiện (Given):
  - DB: decks(1 "Korean"), cards(1 term="사과", hidden=0), srs_states: (chưa có → new)
Thao tác (When):
  1. Mở Library → chạm deck "Korean" → deck-detail[loaded]
  2. Play → "Học" → hoàn thành đủ 5 chặng → chấm Đúng
Kỳ vọng (Then):
  - UI: study-session đi qua stage1-review…stage5-typing → study-result[standard]
  - DB: srs_states[card].box = 1; due_at = now + interval(ô 1); review_logs +1 dòng
  - UI: về deck-detail, thẻ rời nhóm `new`
```

Quy ước:
- **ID ổn định** `SC-<FEATURE>-<n>` (không đánh số lại; chỉ thêm) để test trích dẫn 1-1.
- Mọi state UI phải là **state có thật trong kit** (tra `docs/contracts/`); không bịa state.
- Mọi assertion DB phải là **bảng/cột có thật** trong schema-contract; không bịa cột.
- Không nhắc `lib/...` hay tên class trong scenario — đó là chi tiết triển khai.

## "Đầy đủ" nghĩa là gì (đo được)

> **Chuẩn khắt khe — không bỏ sót:** mỗi màn phải tick đủ **12 chiều** trong
> [`CHECKLIST.md`](CHECKLIST.md) (Definition of Exhaustive). Mục không áp dụng ⇒ ghi
> `N/A + lý do`, KHÔNG để trống. Đây là bảo chứng "không quên chi tiết nào".

Coverage được đo bằng [`coverage.md`](coverage.md):
1. **Mọi dòng D-xxx** (trừ REMOVED/HOÃN) phải được ≥1 scenario E2E exercise.
2. **Mọi user-facing state trong kit** phải **đến được** qua ≥1 bước scenario (117 state; trừ
   state thuần loading/error mô phỏng).
3. Mỗi journey chạm ≥1 assertion DB (chứng minh xuống tới tầng dữ liệu).

Scenario CHƯA đầy đủ khi coverage.md còn ô trống — đó là danh sách việc còn phải viết.

## Sau khi scenario được duyệt → sinh test

Harness đề xuất (bước 2, không làm trước khi scenario chốt):
- **Chính — widget test + Drift in-memory (thật)**: bơm `NativeDatabase.memory()` thay
  cho fake ở tầng DB, pump cây widget thật, drive như người dùng, rồi assert **UI + query
  DB thật**. Chạy trong `flutter test` (không cần emulator) → nhanh, CI-friendly, đúng
  tinh thần "màn hình → DB". **Không dùng fake** cho các assertion hành vi cốt lõi.
- **Phụ — `integration_test`**: một tập smoke chạy trên emulator/thiết bị cho các journey
  quan trọng nhất (repo hiện **chưa có** `integration_test/` — dựng khi cần).
- Mỗi test **trích ID scenario** ở tên/doc-comment; test đỏ ⇒ hoặc code sai, hoặc scenario
  đổi — không bao giờ sửa test cho khớp code.

## Cấu trúc thư mục

```
docs/scenarios/
  README.md              — file này (phương pháp)
  _template.md           — khuôn 1 scenario
  coverage.md            — ma trận D-xxx × scenario · kit-state × scenario (đo "đầy đủ")
  study-srs.md           — MẪU hoàn chỉnh: vòng học lõi (new-learn → ô 1 → due-review → chuyển ô → thuộc)
  <feature>.md           — các feature còn lại (thêm dần sau khi duyệt format)
```

## Trạng thái

- ✅ Phương pháp + khuôn + **1 feature mẫu** (`study-srs.md`) + coverage skeleton.
- ⏳ Chờ duyệt format → nhân rộng cho: content (deck/card), games/review/player, search,
  import/export, statistics/engagement, settings/personalization, glossary/language-pair.
