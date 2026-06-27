# SRS — Ôn tập theo lịch giãn cách (Leitner) — Đặc tả nghiệp vụ

## 0. Thông tin tài liệu

| Trường | Giá trị |
| --- | --- |
| Mã tính năng | `srs/srs-review` |
| Gói công việc (WBS) | W3 |
| Trạng thái | Implemented (engine BE: scheduler 8 ô + queue/cap; không màn riêng — UI học là W4) |
| Người phụ trách | TBD |
| Dòng quyết định liên quan | D-002, D-003, D-004, D-005, D-011, D-018 |
| Phiên bản | 1.0 |

## 1. Mục đích & bối cảnh nghiệp vụ

Mục tiêu của người học là ghi nhớ lâu dài với ít công sức nhất. Nếu ôn quá sớm thì
lãng phí thời gian; ôn quá muộn thì đã quên. Lặp lại giãn cách (spaced repetition)
giải bài toán này bằng cách giãn dần khoảng cách ôn cho mỗi thẻ theo mức độ thành
thạo.

MemoX áp dụng thuật toán **Leitner 8 ô**: mỗi thẻ nằm ở một "ô" tương ứng một khoảng
cách ôn; trả lời đúng đẩy thẻ lên ô cao hơn (ôn thưa dần), trả lời sai kéo xuống (ôn
dày lại). Tính năng này định nghĩa cách thẻ gia nhập hệ thống lập lịch, cách chuyển ô,
và các giới hạn để người học không bị quá tải.

## 2. Phạm vi

**Trong phạm vi:** mô hình 8 ô và khoảng cách ôn; điều kiện để thẻ mới được xếp lịch;
quy tắc chuyển ô khi ôn ("Lặp lại"); hạn mức thẻ mới mỗi ngày; phạm vi một chiều học.

**Ngoài phạm vi (v1):** các thuật toán dựa trên hệ số dễ như SM-2 hay FSRS; lập lịch
riêng cho từng chiều học (đảo chiều hiển thị dùng chung một lịch).

## 3. Tác nhân & các bên liên quan

| Tác nhân | Vai trò |
| --- | --- |
| Người học | Tự chấm Đúng/Sai khi ôn; thụ hưởng lịch ôn tối ưu. |
| Hệ thống lập lịch (SRS) | Tính ô và hạn ôn kế tiếp cho mỗi thẻ. |

## 4. Câu chuyện người dùng (User stories)

- **US-1** — Là người học, tôi muốn được đưa đúng những thẻ đã đến hạn, để ôn đúng lúc
  sắp quên.
- **US-2** — Là người học, tôi muốn thẻ mình hay sai xuất hiện thường xuyên hơn, để
  củng cố điểm yếu.
- **US-3** — Là người học, tôi muốn giới hạn số thẻ mới mỗi ngày, để không bị quá tải.

## 5. Luồng nghiệp vụ (Use cases)

### UC-1: Thẻ mới gia nhập lịch ôn
- **Tiền điều kiện:** thẻ ở trạng thái Mới (ô 0, chưa xếp lịch).
- **Luồng chính:** người học hoàn thành **đủ 5 chặng** của phiên "Học"
  (xem `docs/business/study/study-flow.md`); hệ thống đưa thẻ vào **ô 1** và đặt hạn ôn
  theo khoảng cách của ô 1.
- **Luồng thay thế:** người học thoát giữa chừng → thẻ **vẫn là Mới** (chưa xếp lịch).
- **Hậu điều kiện:** thẻ có lịch ôn và sẽ đến hạn trong tương lai.

### UC-2: Ôn một thẻ đến hạn (chuyển ô)
- **Tiền điều kiện:** thẻ đang đến hạn; người học mở "Lặp lại".
- **Luồng chính:** hệ thống hiển thị thẻ; người học tự chấm **Đúng** hoặc **Sai**; hệ
  thống chuyển ô và đặt lại hạn ôn theo ô mới.
- **Hậu điều kiện:** thẻ ở ô mới với hạn ôn mới; hoạt động trong ngày được cộng dồn.

## 6. Quy tắc nghiệp vụ (Business rules)

| Mã | Quy tắc | Lý do | Truy vết |
| --- | --- | --- | --- |
| BR-1 | Hệ thống dùng **8 ô** Leitner; thẻ Mới ở ô 0 (chưa xếp lịch). | Cân bằng giữa độ mịn lịch và sự đơn giản. | — |
| BR-2 | Thẻ chỉ vào **ô 1** sau khi hoàn thành **đủ 5 chặng** học mới. | Chỉ xếp lịch khi đã thực sự tiếp xúc đủ với thẻ. | D-002 |
| BR-3 | Chấm **Đúng** → lên 1 ô (trần là ô 8). | Thành thạo thì giãn khoảng cách ôn. | D-003, D-005 |
| BR-4 | Chấm **Sai** → lùi 1 ô (sàn là ô 1). | Quên thì cần ôn dày lại, nhưng không phạt nặng về tận đầu. | D-004 |
| BR-5 | Khoảng cách ôn theo ô: 1 · 3 · 7 · 14 · 30 · 60 · 120 ngày; **ô 8 = đã thuộc**, ngừng xếp lịch. | Giãn cách tăng dần, phổ biến cho học từ vựng. | — |
| BR-6 | Mỗi thẻ có **một** trạng thái lịch (một chiều); đảo chiều hiển thị không tạo lịch riêng. | Giữ mô hình đơn giản ở v1. | D-011 |
| BR-7 | Mỗi ngày chỉ nạp tối đa **20** thẻ mới (cấu hình được). | Chống quá tải, duy trì thói quen bền vững. | D-018 |
| BR-8 | Thẻ ẩn không bao giờ vào hàng đợi ôn lẫn bị tính đến hạn. | Tôn trọng ý định tạm gác của người học. | — |

## 7. Tiêu chí chấp nhận (Acceptance criteria)

- **AC-1** — *Cho* một thẻ Mới, *khi* người học hoàn thành đủ 5 chặng học, *thì* thẻ
  vào ô 1 và có hạn ôn. ↔ D-002
- **AC-2** — *Cho* một thẻ ở ô k (k < 8), *khi* chấm Đúng, *thì* thẻ lên ô k+1 với hạn
  ôn theo khoảng cách mới. ↔ D-003
- **AC-3** — *Cho* một thẻ ở ô k (k > 1), *khi* chấm Sai, *thì* thẻ lùi về ô k−1. ↔ D-004
- **AC-4** — *Cho* một thẻ ở ô 8, *khi* chấm Đúng, *thì* thẻ giữ nguyên ô 8 (đã thuộc). ↔ D-005
- **AC-5** — *Cho* số thẻ mới vượt hạn mức ngày, *khi* dựng phiên học mới, *thì* chỉ
  nạp tối đa 20 thẻ mới. ↔ D-018

## 8. Yêu cầu phi chức năng

- Dựng hàng đợi đến hạn cho một bộ thẻ lớn trong khoảng dưới 100 ms.

## 9. Giả định · Ràng buộc · Phụ thuộc (RAID)

- **Giả định:** người học chấm Đúng/Sai trung thực.
- **Ràng buộc:** một chiều học cho mỗi thẻ ở v1.
- **Phụ thuộc:** luồng "Học" 5 chặng (study-flow); bảng `srs_state` (schema).

## 10. Câu hỏi mở

- Khoảng cách 8 ô là mục tiêu ban đầu; tinh chỉnh khi có dữ liệu giữ chân thực tế.

## 11. Truy vết & liên quan

- **Dữ liệu:** `docs/database/schema-contract.md` — bảng `srs_state`.
- **Quyết định:** `docs/decision-tables/core-decision-table.md` — D-002…D-005, D-011, D-018.
- **Spec liên quan:** `docs/business/study/study-flow.md`, `docs/business/flashcard/flashcard-management.md`.
