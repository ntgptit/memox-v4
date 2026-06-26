# Tính năng: Tìm kiếm (Search)

**Status:** Specified
**Phụ trách:** TBD
**Liên quan:** dòng quyết định D-019 · WBS TBD

## Mục đích

Tìm nhanh thẻ theo từ khoá, khớp trên **cả term và nghĩa**.

## Hành vi người dùng thấy

1. Ô tìm kiếm ở thanh trên (toàn cục) và trong từng nút (trong thư mục/deck).
2. Khớp từ khoá trên `term` (ngôn ngữ đang học) **và** nội dung nghĩa
   (`card_meaning.text`). (D-019)
3. Kết quả là danh sách thẻ khớp; phạm vi tuỳ ngữ cảnh: toàn thư viện (tìm toàn cục)
   hoặc trong nút đang mở (tìm trong thư mục).

## Luật & ca biên

- Chỉ tìm trong **cặp ngôn ngữ đang chọn**.
- Thẻ ẩn: **có** hiện trong kết quả.
- Có **bộ lọc theo trạng thái** (mới / đến hạn / đã thuộc). (D-028)

## Ngoài phạm vi (v1)

- Khớp tag/ghi chú — v1 chưa có tag.

## File mã nguồn

TBD (chưa hiện thực).

## Liên quan

- `docs/business/flashcard/flashcard-management.md` — nội dung thẻ
- `docs/decision-tables/core-decision-table.md`
