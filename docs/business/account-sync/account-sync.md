# ACCOUNT & SYNC — Tài khoản & Đồng bộ — Đặc tả nghiệp vụ

## 0. Thông tin tài liệu

| Trường | Giá trị |
| --- | --- |
| Mã tính năng | `account-sync/account-sync` |
| Gói công việc (WBS) | W11 |
| Trạng thái | Specified (alpha) |
| Người phụ trách | TBD |
| Dòng quyết định liên quan | D-027 |
| Phiên bản | 1.0 |

## 1. Mục đích & bối cảnh nghiệp vụ

Người học thường dùng nhiều thiết bị và lo mất dữ liệu khi đổi máy. Đồng bộ qua tài khoản
Google cho phép dữ liệu học theo người dùng giữa các thiết bị, trong khi ứng dụng vẫn hoạt
động offline. Tính năng này khác với sao lưu cục bộ (file trên máy): đồng bộ là trạng thái
sống đa thiết bị.

## 2. Phạm vi

**Trong phạm vi:** đăng nhập Google; đồng bộ dữ liệu người dùng đa thiết bị; giải quyết
xung đột.
**Ngoài phạm vi (v1):** chia sẻ nội dung giữa các người dùng khác nhau.

## 3. Tác nhân & các bên liên quan

| Tác nhân | Vai trò |
| --- | --- |
| Người học | Đăng nhập, đồng bộ, đăng xuất. |
| Google (Drive) | Lưu trữ dữ liệu đồng bộ. |

## 4. Câu chuyện người dùng (User stories)

- **US-1** — Là người học, tôi muốn đăng nhập bằng Google và đồng bộ dữ liệu, để dùng được
  trên nhiều thiết bị.
- **US-2** — Là người học, tôi muốn tiếp tục học khi offline, để không phụ thuộc mạng.

## 5. Luồng nghiệp vụ (Use cases)

### UC-1: Đăng nhập & đồng bộ
- **Luồng chính:** người học đăng nhập Google; hệ thống đồng bộ cặp ngôn ngữ, thư mục, bộ
  thẻ, thẻ, trạng thái ôn, cài đặt và hoạt động; đồng bộ tự động khi có mạng, có thể đồng
  bộ thủ công.
- **Luồng ngoại lệ (xung đột):** khi cùng một bản ghi bị sửa ở hai nơi, hệ thống giữ bản
  có mốc cập nhật mới nhất (last-write-wins).

### UC-2: Đăng xuất
- **Luồng chính:** người học đăng xuất; dữ liệu cục bộ vẫn giữ.

## 6. Quy tắc nghiệp vụ (Business rules)

| Mã | Quy tắc | Lý do | Truy vết |
| --- | --- | --- | --- |
| BR-1 | Xác thực bằng tài khoản Google. | Hạ tầng quen thuộc, không cần dựng backend riêng. | — |
| BR-2 | Xung đột giải quyết theo last-write-wins ở mức bản ghi, dựa trên mốc cập nhật. | Đơn giản, đủ dùng cho dữ liệu một người dùng. | D-027 |
| BR-3 | Ứng dụng hoạt động offline; đồng bộ khi có mạng. | Học là hoạt động không nên phụ thuộc mạng. | — |
| BR-4 | Đồng bộ khác với sao lưu cục bộ (file trên máy). | Tránh nhầm lẫn hai cơ chế an toàn dữ liệu. | — |

## 7. Tiêu chí chấp nhận (Acceptance criteria)

- **AC-1** — *Cho* một bản ghi bị sửa ở hai thiết bị, *khi* đồng bộ, *thì* bản có mốc cập
  nhật mới hơn được giữ. ↔ D-027
- **AC-2** — *Cho* mất mạng, *khi* người học tiếp tục học, *thì* ứng dụng vẫn hoạt động và
  đồng bộ lại khi có mạng. ↔ BR-3

## 8. Yêu cầu phi chức năng

- Đồng bộ chạy nền, không chặn thao tác học.

## 9. Giả định · Ràng buộc · Phụ thuộc (RAID)

- **Giả định:** người học có tài khoản Google.
- **Ràng buộc:** tính năng đang ở mức **alpha**.
- **Phụ thuộc:** kho lưu Google Drive; mốc cập nhật trên mọi bản ghi.

## 10. Câu hỏi mở

- Cơ chế đánh dấu xoá (tombstone) để xoá lan đa thiết bị — chốt khi triển khai.

## 11. Truy vết & liên quan

- **Quyết định:** `docs/decision-tables/core-decision-table.md` — D-027.
- **Spec liên quan:** `docs/business/settings/settings.md` (sao lưu cục bộ).
