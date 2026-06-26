# Tính năng: Tài khoản & Đồng bộ (Account & Sync)

**Status:** Specified
**Phụ trách:** TBD
**Liên quan:** dòng quyết định D-027 · WBS TBD

## Mục đích

Đăng nhập và đồng bộ dữ liệu đa thiết bị **qua tài khoản Google**.

## Hành vi người dùng thấy

1. **Đăng nhập bằng Google** (OAuth). Hiển thị email đã đăng nhập.
2. **Đồng bộ** dữ liệu người dùng: cặp ngôn ngữ, thư mục, bộ thẻ, thẻ + nghĩa,
   `srs_state`, cài đặt, hoạt động/streak.
3. Đồng bộ tự động (nền) + cho phép đồng bộ thủ công.
4. Đăng xuất.

## Luật & ca biên

- **Xung đột:** giải quyết theo **last-write-wins** ở mức bản ghi, dựa trên mốc
  `updated_at` mới nhất. (D-027)
- **Kho lưu:** qua **Google Drive** (thư mục `appDataFolder` ẩn) ở v1 alpha.
- **Xoá đa thiết bị:** dùng **tombstone** để lan truyền việc xoá.
- App vẫn chạy **offline**; đồng bộ khi có mạng.
- Khác với **Backup** cục bộ (file trên máy) — xem `docs/business/settings/settings.md`.
- Tính năng đang mức **alpha**.

## File mã nguồn

TBD (chưa hiện thực).

## Liên quan

- `docs/business/settings/settings.md` — Backup (≠ Sync)
- `docs/database/schema-contract.md`
- `docs/decision-tables/core-decision-table.md`
