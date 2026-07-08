# Definition of Exhaustive (DoE) — không bỏ sót chi tiết nào

Chuẩn khắt khe (thị trường Nhật): **mỗi màn** phải có scenario cho **mọi mục dưới đây**.
Không được "quên" — mục nào không áp dụng phải ghi rõ **`N/A + lý do`**, không để trống.
Mỗi file feature mở đầu bằng **bảng DoE** (12 chiều × các state/phần tử) đánh dấu ✅ / N/A.

Nguồn liệt kê (để không bịa & không sót):
- **State**: `docs/contracts/<screen>.md` (đủ state) + `MANIFEST.yaml`.
- **Phần tử tương tác**: `docs/design/…/specs/<screen>.md` (DOM: mọi node — button, icon-button,
  field, toggle, chip, menu-item, tab, FAB, sheet, dialog).
- **Hành vi/biên**: `docs/decision-tables/core-decision-table.md` (D-xxx) + `docs/business/*` (BR-x).
- **DB**: `docs/database/schema-contract.md` (bảng/cột).

## 12 chiều bắt buộc / màn

| # | Chiều | Phải phủ |
|---|---|---|
| 1 | **Mọi state** | Từng state trong kit contract: loaded · empty · loading · error · + mọi overlay (menu/sheet/dialog/picker/confirm). Mỗi state = ≥1 scenario dẫn tới nó. |
| 2 | **Mọi phần tử tương tác** | Từng button/icon-button/field/toggle/chip/menu-item/tab/FAB trong DOM spec → hành động + kết quả (UI + DB). Kể cả nút phụ (back, close, more, clear). |
| 3 | **Điều hướng vào/ra** | Mọi entry point vào màn; back/close/swipe-dismiss; deep-link; mọi push đi ra; giữ/khôi phục vị trí cuộn & state khi quay lại. |
| 4 | **Nhập liệu & validation** (mỗi field) | rỗng · chỉ khoảng trắng · quá dài (biên max) · ký tự đặc biệt/emoji · **CJK (Hàn/Nhật)** · trùng (soft-dup D-020) · sai định dạng → **thông báo lỗi cụ thể** (nội dung + vị trí) · trim. |
| 5 | **Lượng dữ liệu** | 0 (empty) · 1 · nhiều · rất nhiều (scroll/lazy) · biên (0, max, tràn số). Danh sách rỗng vs có phần tử ẩn (D-006). |
| 6 | **Async & lỗi** | loading (skeleton) · thành công · **thất bại + retry** · timeout · huỷ giữa chừng · local-first (không mạng vẫn chạy). |
| 7 | **Persistence (DB)** | Mỗi hành động ghi → assert đúng bảng/cột (schema-contract). **Kill & mở lại app → dữ liệu còn** (round-trip). Cascade xoá (D-024). |
| 8 | **Định dạng & i18n** | ngày/giờ/số theo locale; **plural** (1 thẻ vs N thẻ); tiền/đơn vị; CJK render đúng (không tofu); RTL nếu có; text dài → ellipsis/wrap không vỡ layout. |
| 9 | **Dark mode** | Mọi state đúng ở **cả light + dark** (token, không hardcode màu). |
| 10 | **Responsive** | 320px → tablet; **không overflow**; xoay ngang; nội dung dài cuộn được; safe-area/notch. |
| 11 | **A11y** | semantic label mỗi control; hit-area ≥48; focus/tab order; contrast; screen-reader đọc đúng thứ tự. |
| 12 | **Concurrency & edge thời gian** | double-tap/nhấn nhanh 2 lần; back khi đang load; mất kết nối giữa chừng; **đổi ngày lúc nửa đêm** (streak/reset D-021); phiên bị gián đoạn (resume). |

## Bảng DoE đầu mỗi file feature (mẫu)

```
## DoE — <screen>
| Chiều | Trạng thái | Scenario / N/A(lý do) |
|---|---|---|
| 1 States (n=…) | ✅ | SC-…-01..k (mỗi state 1 dòng) |
| 2 Elements (n=…) | ✅ | … |
| 3 Nav in/out | ✅ | … |
| 4 Validation | ✅ / N/A(không có input) | … |
| 5 Data volume | ✅ | … |
| 6 Async/error | ✅ | … |
| 7 Persistence | ✅ | … |
| 8 Format/i18n | ✅ | … |
| 9 Dark | ✅ | … |
| 10 Responsive | ✅ | … |
| 11 A11y | ✅ | … |
| 12 Concurrency/time | ✅ / N/A(lý do) | … |
```

## "Đầy đủ 100%" ⇔
1. `coverage.md`: **mọi** screen có bảng DoE **không còn ô trống** (12/12 = ✅ hoặc N/A-có-lý-do).
2. **Mọi** state (117) đến được qua ≥1 scenario.
3. **Mọi** phần tử tương tác trong DOM spec có ≥1 scenario.
4. **Mọi** D-xxx (trừ HOÃN/REMOVED) có ≥1 scenario E2E.

Chỉ khi cả 4 xanh mới sang bước dựng harness + sinh test.
