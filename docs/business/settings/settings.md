# Tính năng: Cài đặt, sao lưu & kiếm tiền

**Status:** Specified
**Phụ trách:** TBD
**Liên quan:** dòng quyết định D-008, D-012 · WBS TBD

## Mục đích

Cấu hình toàn cục, cộng hai cơ chế an toàn dữ liệu **khác nhau** (Backup cục bộ vs
CloudSync) và paywall Premium. Rút từ màn cài đặt của app tham chiếu.

## Các cụm cài đặt

| Cụm | Mục | Ghi chú |
| --- | --- | --- |
| Ngôn ngữ | NativeLanguage, ngôn ngữ giao diện | cả hai đều khác với LanguagePair đang chọn |
| Hiển thị từ | hiện trường mẹ đẻ, tô màu theo giới tính, đánh dấu Cyrillic trong trường Latinh | trợ giúp học đa ngôn ngữ |
| SRS | `leitner_box_count` (mặc định 7), thông báo | xem `docs/business/srs/srs-review.md` |
| Trò chơi | `game_words_per_round` (5), `game_random`, bàn phím | xem `docs/business/study/study-flow.md` (D-008) |
| Giọng nói | nhà cung cấp TTS + nhận dạng giọng nói (STT) | bật audio + có thể luyện nói |
| Nhắc học | giờ-trong-ngày + tập thứ trong tuần | UI: "Lời nhắc" (vd 13:00, T2–CN) |

## Backup vs Sync (hai cơ chế tách biệt)

| | Backup | CloudSync |
| --- | --- | --- |
| Là gì | bản chụp file cục bộ, khôi phục trên máy | đồng bộ sống đa thiết bị |
| Gắn với | một đường dẫn file | một tài khoản đám mây |
| Cấu hình | `auto_backup`, `backup_path`, "lần cuối" | đăng nhập tài khoản; đang *alpha* |

Hai cái này **không** thay thế nhau và phải mô hình riêng.

## Kiếm tiền (Premium) — HOÃN v1

> **Quyết định:** Premium **chưa phát triển ở v1** (chưa cần). Ghi lại để tham khảo,
> KHÔNG hiện thực bây giờ. (D-012)

- (Tham khảo app gốc) Thuê bao hằng năm, định kỳ, huỷ bất cứ lúc nào; khoá một phần
  tính năng. Ranh giới Free/Premium sẽ chốt khi mở lại.

## Luật & ca biên

- Nhắc học phụ thuộc quyền thông báo của HĐH và trạng thái tối ưu pin.
- Đổi `leitner_box_count` không được làm hỏng `SrsState.box` đang có (kẹp về dải hợp lệ).

## Ngoài phạm vi (nói rõ)

- Mua gói nội dung trong app — không mô hình ở v1.

## File mã nguồn

TBD (chưa hiện thực).

## Liên quan

- `docs/database/schema-contract.md` — các key `settings`
- `docs/decision-tables/core-decision-table.md`
