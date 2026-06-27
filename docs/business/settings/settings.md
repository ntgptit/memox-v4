# SETTINGS — Cài đặt, sao lưu & kiếm tiền — Đặc tả nghiệp vụ

## 0. Thông tin tài liệu

| Trường | Giá trị |
| --- | --- |
| Mã tính năng | `settings/settings` |
| Gói công việc (WBS) | W12 |
| Trạng thái | Specified |
| Người phụ trách | TBD |
| Dòng quyết định liên quan | D-008, D-012 |
| Phiên bản | 1.0 |

## 1. Mục đích & bối cảnh nghiệp vụ

Người học cần điều chỉnh trải nghiệm theo thói quen của mình (ngôn ngữ, cách hiển thị,
nhịp ôn, nhắc học) và bảo vệ dữ liệu (sao lưu). Tài liệu này gom các nhóm cài đặt, phân
biệt hai cơ chế an toàn dữ liệu (sao lưu cục bộ vs đồng bộ đám mây), và ghi nhận hướng kiếm
tiền (Premium) — vốn được hoãn ở v1.

## 2. Phạm vi

**Trong phạm vi:** các nhóm cài đặt; sao lưu/khôi phục cục bộ; nhắc học; mối quan hệ với
đồng bộ đám mây.
**Ngoài phạm vi (v1):** Premium (chỉ ghi nhận, không triển khai).

## 3. Tác nhân & các bên liên quan

| Tác nhân | Vai trò |
| --- | --- |
| Người học | Điều chỉnh cài đặt; sao lưu/khôi phục. |

## 4. Câu chuyện người dùng (User stories)

- **US-1** — Là người học, tôi muốn đặt tiếng mẹ đẻ và ngôn ngữ giao diện, để dùng app đúng ý.
- **US-2** — Là người học, tôi muốn chỉnh nhịp ôn và số thẻ mỗi ván, để hợp khả năng của mình.
- **US-3** — Là người học, tôi muốn được nhắc học vào giờ cố định, để duy trì thói quen.
- **US-4** — Là người học, tôi muốn sao lưu và khôi phục dữ liệu, để không sợ mất.

## 5. Nhóm cài đặt

| Nhóm | Mục | Ghi chú |
| --- | --- | --- |
| Ngôn ngữ | Tiếng mẹ đẻ; ngôn ngữ giao diện | đều khác với cặp đang học |
| Hiển thị từ | hiện trường mẹ đẻ; tô màu theo giới tính; đánh dấu Cyrillic trong trường Latinh | trợ giúp học đa ngôn ngữ |
| SRS | số ô (8); thông báo | xem `docs/business/srs/srs-review.md` |
| Trò chơi | số từ/ván (5); chọn ngẫu nhiên; bàn phím | xem `docs/business/game/game-modes.md` |
| Giọng nói | nhà cung cấp TTS + nhận dạng giọng nói | bật âm thanh |
| Nhắc học | giờ trong ngày + tập thứ trong tuần | "Lời nhắc" |

## 6. Sao lưu vs Đồng bộ (hai cơ chế khác nhau)

| | Sao lưu | Đồng bộ |
| --- | --- | --- |
| Bản chất | bản chụp file cục bộ, khôi phục trên máy | trạng thái sống đa thiết bị |
| Gắn với | một đường dẫn file | một tài khoản đám mây |
| Cấu hình | tự động sao lưu, đường dẫn, lần cuối | đăng nhập Google (alpha) |

## 7. Quy tắc nghiệp vụ (Business rules)

| Mã | Quy tắc | Lý do | Truy vết |
| --- | --- | --- | --- |
| BR-1 | Tiếng mẹ đẻ, ngôn ngữ giao diện và cặp đang học là ba khái niệm tách biệt. | Tránh nhầm lẫn cấu hình. | — |
| BR-2 | Số từ mỗi ván trò chơi do cài đặt quy định (mặc định 5). | Cho người học điều chỉnh nhịp luyện. | D-008 |
| BR-3 | Sao lưu (file cục bộ) khác hoàn toàn với đồng bộ (tài khoản). | Hai cơ chế an toàn dữ liệu độc lập. | — |
| BR-4 | Nhắc học phụ thuộc quyền thông báo và trạng thái tối ưu pin của hệ điều hành. | Đảm bảo nhắc đáng tin. | — |
| BR-5 | **Premium hoãn ở v1**: không có tính năng nào bị khoá sau trả phí. | Ưu tiên hoàn thiện trải nghiệm cốt lõi trước. | D-012 |

## 8. Tiêu chí chấp nhận (Acceptance criteria)

- **AC-1** — *Cho* người học đổi số từ/ván, *khi* mở một ván trò chơi, *thì* ván dùng đúng
  số đã đặt. ↔ D-008
- **AC-2** — *Cho* phiên bản v1, *khi* dùng bất kỳ tính năng nào, *thì* không có tính năng
  bị chặn vì chưa Premium. ↔ D-012

## 9. Giả định · Ràng buộc · Phụ thuộc (RAID)

- **Ràng buộc:** Premium ngoài phạm vi v1.
- **Phụ thuộc:** quyền hệ điều hành (thông báo, lưu trữ); tính năng Đồng bộ.

## 10. Câu hỏi mở

- Ranh giới Free/Premium — chốt khi mở lại hướng kiếm tiền.

## 11. Truy vết & liên quan

- **Quyết định:** `docs/decision-tables/core-decision-table.md` — D-008, D-012.
- **Spec liên quan:** `docs/business/account-sync/account-sync.md`, `docs/business/personalization/personalization.md`.
