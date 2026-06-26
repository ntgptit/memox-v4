# Tính năng: Quản lý Thẻ (Card)

**Status:** Specified
**Phụ trách:** TBD
**Liên quan:** dòng quyết định D-006, D-011 · `docs/contracts/usecase-contracts/_template.md` · WBS TBD

## Mục đích

Thẻ là đơn vị học nhỏ nhất. App tham chiếu coi thẻ là một bản ghi **giàu trường**
(không phải cặp trước/sau): một `term` (ngôn ngữ đang học) + một hoặc nhiều phần
nghĩa theo ngôn ngữ, kèm audio và giới tính ngữ pháp (tuỳ chọn).

## Hành vi người dùng thấy

1. Thẻ hiển thị một **term** (ngôn ngữ đang học) ở mặt hỏi và một khối **nghĩa** ở mặt trả lời.
2. Khối nghĩa là **một ô văn bản tự do** theo từng ngôn ngữ — người dùng gõ chung
   bản dịch, từ loại, định nghĩa, từ nguyên (vd Hán Việt) vào một ô. Có thể có nhiều
   ngôn ngữ (vd VI mẹ đẻ + EN trung gian). Xem `docs/business/glossary.md` → `CardMeaning`.
3. Term phát được audio (TTS).
4. Thẻ được tạo thủ công, sửa inline (vd từ `ReviewMode`), sắp lại thứ tự, xoá, và
   **ẩn** (loại khỏi việc học mà không xoá).
5. Thẻ có thể nạp hàng loạt qua Import (xem `docs/business/index.md`).

## Trường khi tạo/sửa thẻ (chốt)

| Trường | Bắt buộc | Ghi chú |
| --- | --- | --- |
| Term | có | mặt ngôn ngữ đang học |
| Nghĩa (mẹ đẻ) | có | ô văn bản tự do |
| Nghĩa ngôn ngữ phụ | không | vd EN trung gian |
| Audio | tự sinh | TTS theo term; phát lại được |
| Giới tính | không | cho ngôn ngữ có giống |
| Ẩn | không | cờ loại khỏi học |

*(v1 không thêm ví dụ / ảnh / tag — giữ gọn.)*

## Trạng thái

| Trạng thái | Kích hoạt | Người dùng thấy |
| --- | --- | --- |
| new | thẻ vừa tạo, chưa học | tính vào "từ mới", không tính đến hạn |
| learning / due | đã học ít nhất 1 lần, `due_at <= now` | tính vào badge đến hạn |
| mastered | đạt ô Leitner cao nhất | tính vào `Progress %` |
| hidden | người dùng ẩn thẻ | loại khỏi hàng đợi & số đến hạn |

## Luật & ca biên

- Một thẻ thuộc đúng một deck (`docs/database/schema-contract.md`).
- `hidden` gỡ thẻ khỏi hàng đợi học và khỏi `DueCount` nhưng giữ nguyên dữ liệu; thẻ
  ẩn không tính vào số "X từ" hiển thị của nút (đếm riêng qua biểu tượng 👁).
- Nghĩa theo từng ngôn ngữ; mặc định hiện nghĩa tiếng mẹ đẻ, có thể hiện kèm một
  ngôn ngữ trung gian (vd EN) tuỳ cài đặt.
- Phát hiện trùng (cùng term trong cùng deck) khi tạo/import là **cảnh báo mềm**,
  vẫn cho thêm (không chặn cứng). (D-020)

## Ngoài phạm vi (nói rõ)

- Media ngoài audio (ảnh/video) — không mô hình ở v1.
- Audio riêng cho từng nghĩa — v1 chỉ term có audio.

## File mã nguồn

TBD (chưa hiện thực).

## Liên quan

- `docs/database/schema-contract.md` — `card`, `card_meaning`
- `docs/business/srs/srs-review.md` — lập lịch cho một thẻ
- `docs/decision-tables/core-decision-table.md` — D-006, D-011
