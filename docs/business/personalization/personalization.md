# PERSONALIZATION — Cá nhân hoá giao diện — Đặc tả nghiệp vụ

## 0. Thông tin tài liệu

| Trường | Giá trị |
| --- | --- |
| Mã tính năng | `personalization/personalization` |
| Gói công việc (WBS) | W13 |
| Trạng thái | Implemented (chế độ màu sáng/tối/hệ thống + màu nhấn (brand/warm/cool từ token sẵn có) + cỡ chữ (nhỏ/vừa/lớn); áp dụng live qua MemoXApp, lưu trong settings W12. Hoãn: theme tải về, tuỳ biến theo màn, phông tuỳ ý) |
| Người phụ trách | TBD |
| Dòng quyết định liên quan | — |
| Phiên bản | 1.0 |

## 1. Mục đích & bối cảnh nghiệp vụ

Người học sử dụng ứng dụng trong nhiều điều kiện ánh sáng và có sở thích thị giác khác
nhau. Cá nhân hoá giao diện giúp việc học thoải mái hơn và giảm mỏi mắt, qua đó hỗ trợ học
lâu dài.

## 2. Phạm vi

**Trong phạm vi:** chế độ màu, màu nhấn, cỡ chữ.
**Ngoài phạm vi (v1):** theme tải về; tuỳ biến theo từng màn; phông chữ tuỳ ý.

## 3. Tác nhân & các bên liên quan

| Tác nhân | Vai trò |
| --- | --- |
| Người học | Chọn theme phù hợp sở thích/điều kiện. |

## 4. Câu chuyện người dùng (User stories)

- **US-1** — Là người học, tôi muốn chọn chế độ sáng/tối/theo hệ thống, để học dễ chịu mọi lúc.
- **US-2** — Là người học, tôi muốn chỉnh cỡ chữ, để đọc thoải mái.

## 5. Luồng nghiệp vụ (Use cases)

### UC-1: Đổi theme
- **Luồng chính:** người học chọn chế độ màu, màu nhấn hoặc cỡ chữ; hệ thống áp dụng ngay,
  không cần khởi động lại, và lưu lại.

## 6. Quy tắc nghiệp vụ (Business rules)

| Mã | Quy tắc | Lý do | Truy vết |
| --- | --- | --- | --- |
| BR-1 | Hỗ trợ chế độ màu Sáng / Tối / Theo hệ thống. | Phù hợp điều kiện ánh sáng. | — |
| BR-2 | Cho chọn màu nhấn từ bảng màu định sẵn và cỡ chữ (nhỏ/vừa/lớn). | Cá nhân hoá vừa đủ, giữ nhất quán thiết kế. | — |
| BR-3 | Thay đổi áp dụng ngay và được lưu vào cài đặt. | Phản hồi tức thì, bền vững. | — |

## 7. Tiêu chí chấp nhận (Acceptance criteria)

- **AC-1** — *Cho* người học chọn chế độ Tối, *khi* áp dụng, *thì* giao diện chuyển sang
  tối ngay mà không khởi động lại. ↔ BR-3
- **AC-2** — *Cho* chế độ "Theo hệ thống", *khi* hệ thống đổi sáng/tối, *thì* ứng dụng đổi theo. ↔ BR-1

## 8. Yêu cầu phi chức năng

- Cả chế độ sáng và tối đều đạt độ tương phản đọc được (xem `docs/ui-ux/ui-ux-contract.md`).

## 9. Giả định · Ràng buộc · Phụ thuộc (RAID)

- **Phụ thuộc:** token thiết kế (`docs/design/design-language.md`); lưu trong cài đặt.

## 10. Câu hỏi mở

- Không.

## 11. Truy vết & liên quan

- **Spec liên quan:** `docs/business/settings/settings.md`.
- **Thiết kế:** `docs/ui-ux/ui-ux-contract.md`, `docs/design/design-language.md`.
