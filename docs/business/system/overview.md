# MemoX V4 — Tài liệu bối cảnh nghiệp vụ

Tài liệu nền cho mọi đặc tả: bối cảnh, tầm nhìn, các bên liên quan, phạm vi và bản đồ năng
lực. Bảng trạng thái ở §6 là nguồn theo dõi tiến độ (bước 7 của Pre-commit parity check
cập nhật khi một mục chuyển Specified ↔ Implemented).

## 1. Bối cảnh & vấn đề

Người tự học ngoại ngữ tích luỹ hàng nghìn từ nhưng quên nhanh vì ôn không đúng nhịp, dễ
bỏ cuộc vì thiếu động lực, và ngại nhập liệu. Thị trường có nhiều app flashcard nhưng
thường hoặc quá phức tạp, hoặc khoá tính năng cốt lõi sau trả phí.

## 2. Tầm nhìn

MemoX giúp người học **ghi nhớ lâu dài với ít công sức nhất**: lập lịch ôn tự động theo
mức độ thành thạo, gamification nhẹ để duy trì thói quen, và toàn quyền tổ chức/sở hữu nội
dung — hoạt động tốt cả khi offline, đồng bộ đa thiết bị.

## 3. Các bên liên quan

| Bên liên quan | Quan tâm |
| --- | --- |
| Người học | Học hiệu quả, đều đặn; kiểm soát và an toàn dữ liệu. |
| Chủ sản phẩm | Trải nghiệm cốt lõi vững trước khi nghĩ tới kiếm tiền. |
| Nền tảng (Google, hệ điều hành) | Đăng nhập/đồng bộ, thông báo, lưu trữ. |

## 4. Phạm vi sản phẩm (v1)

**Trong phạm vi:** quản lý nội dung; SRS 8 ô; các hình thức học & luyện; tìm kiếm;
nhập/xuất; thống kê & gắn kết; đồng bộ Google (alpha); cài đặt & cá nhân hoá.
**Ngoài phạm vi (v1):** Premium; chia sẻ nội dung giữa người dùng; media ngoài âm thanh;
học chéo nhiều cặp ngôn ngữ trong một phiên.

## 5. Bản đồ năng lực & luồng tổng thể

Nội dung thuộc về một **Cặp ngôn ngữ**; người học duyệt cây **Bộ thẻ (lồng nhau)**, chọn một
nút và chọn một hình thức học:

```
Cặp ngôn ngữ ─▶ Cây thư viện ─▶ Nút ─▶ bấm Play → menu
                                         ├─ Lặp lại (khi đến hạn) ─▶ ôn thẻ ĐẾN HẠN ─┐
                                         ├─ Học ─▶ học thẻ MỚI (5 chặng) ────────────┼─▶ tự chấm ─▶ Leitner (8 ô) ─▶ Hoạt động ngày++
                                         └─ Xem lại / Trò chơi / Trình phát ─▶ chỉ luyện tập (không đổi lịch ôn)
```

Chỉ **Ôn đến hạn** ("Lặp lại") và **Học thẻ mới** ("Học") thay đổi lịch ôn và cộng hoạt
động ngày. Hệ thống nền: Cài đặt, Theme, Sao lưu cục bộ (≠ Đồng bộ Google), Nhập/Xuất, Nhắc
học. (Premium hoãn v1.) Sơ đồ đầy đủ: `docs/business/system/system-flow.md`.

## 6. Bảng trạng thái

| Tính năng | Đặc tả | Trạng thái | Kiểm chứng bởi |
| --- | --- | --- | --- |
| Quản lý Thẻ | `docs/business/flashcard/flashcard-management.md` | Implemented | `test/data/repositories/card_repository_impl_test.dart` |
| Ôn tập SRS (8 ô Leitner) | `docs/business/srs/srs-review.md` | Implemented | `test/domain/services/srs_scheduler_test.dart` |
| Luồng học & luyện tập | `docs/business/study/study-flow.md` | Specified | TBD |
| Bốn trò chơi | `docs/business/game/game-modes.md` | Specified | TBD |
| Quản lý Bộ thẻ (cây lồng nhau) | `docs/business/deck/deck-management.md` | Implemented | `test/data/repositories/deck_repository_impl_test.dart` |
| Tìm kiếm | `docs/business/search/global-search.md` | Specified | TBD |
| Nhập / Xuất | `docs/business/import-export/import-export.md` | Specified | TBD |
| Thống kê | `docs/business/statistics/statistics.md` | Specified | TBD |
| Hoạt động & streak | `docs/business/engagement/dashboard-engagement.md` | Specified | TBD |
| Tài khoản & Đồng bộ | `docs/business/account-sync/account-sync.md` | Specified | TBD |
| Cài đặt & sao lưu | `docs/business/settings/settings.md` | Specified | TBD |
| Cá nhân hoá (theme) | `docs/business/personalization/personalization.md` | Specified | TBD |

## 7. Giả định & ràng buộc cấp sản phẩm

- Một người dùng một dữ liệu (chưa đa người dùng/chia sẻ).
- Ưu tiên offline-first; đồng bộ là alpha.
- SRS một chiều cho mỗi thẻ ở v1.

## Liên quan

- `docs/business/index.md` — tóm tắt yêu cầu & danh mục tính năng
- `docs/business/system/system-flow.md` — sơ đồ luồng toàn hệ thống
- `docs/project-management/wbs.md` — trạng thái bàn giao
