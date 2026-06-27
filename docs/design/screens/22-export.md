# 22. Export / Xuất dữ liệu

Thiết kế màn **Xuất thẻ** của MemoX (app học từ vựng flashcard + SRS, mobile, tiếng Việt).
Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`, Plus Jakarta Sans, light +
dark).

**Ngữ cảnh:** xuất thẻ ra ngoài để sao lưu hoặc chia sẻ.

**Bố cục:** chọn **phạm vi** (một bộ thẻ / một thư mục) · chọn **định dạng** (CSV / Excel /
sao chép văn bản) · chọn **dấu phân tách** (cho CSV & văn bản) · công tắc **"Kèm trạng thái
ôn (ô/hạn)"** · nút "Xuất".

**Thiết kế các state sau — mỗi state một frame:**

1. **Cấu hình xuất** — phạm vi + định dạng + separator + công tắc kèm trạng thái SRS.
2. **Đang xuất** — tiến trình ngắn.
3. **Hoàn tất** — "Đã xuất N thẻ" + nút chia sẻ / lưu / "Đã sao chép".
