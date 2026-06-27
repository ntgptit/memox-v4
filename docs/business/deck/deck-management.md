# DECK — Quản lý Bộ thẻ (cây lồng nhau) — Đặc tả nghiệp vụ

## 0. Thông tin tài liệu

| Trường | Giá trị |
| --- | --- |
| Mã tính năng | `deck/deck-management` |
| Gói công việc (WBS) | W6 |
| Trạng thái | Specified |
| Người phụ trách | TBD |
| Dòng quyết định liên quan | D-023, D-024 |
| Phiên bản | 2.0 |

## 1. Mục đích & bối cảnh nghiệp vụ

Bộ thẻ là **đơn vị thư viện duy nhất** của MemoX và là nơi người học thực sự "học" hằng
ngày. Một bộ thẻ **tự lồng nhau thành cây**: nó có thể chứa **đồng thời** thẻ học trực tiếp
và các bộ thẻ con. Nhờ vậy người học tổ chức nội dung theo chủ đề (cây nhiều cấp) mà không
cần một khái niệm "thư mục" riêng. Bộ thẻ gốc là bộ thẻ không có bộ thẻ cha.

> Pivot v1: bỏ khái niệm "Thư mục"; bộ thẻ tự lồng đảm nhiệm việc tổ chức cây
> (xem `docs/project-management/wbs.md` §10).

## 2. Phạm vi

**Trong phạm vi:** tạo, đổi tên, di chuyển, xoá và sắp xếp bộ thẻ; lồng bộ thẻ con; tổng
hợp số liệu đệ quy của cây con; điểm vào để thêm/nhập thẻ.
**Ngoài phạm vi (v1):** tự động trộn/gộp hai bộ thẻ; chia sẻ/đồng sở hữu.

## 3. Tác nhân & các bên liên quan

| Tác nhân | Vai trò |
| --- | --- |
| Người học | Tổ chức cây bộ thẻ; tạo và quản lý bộ thẻ; thêm thẻ. |

## 4. Câu chuyện người dùng (User stories)

- **US-1** — Là người học, tôi muốn tạo một bộ thẻ theo chủ đề, để gom các từ liên quan.
- **US-2** — Là người học, tôi muốn tạo bộ thẻ con bên trong một bộ thẻ, để tổ chức nội
  dung thành cây theo chủ đề.
- **US-3** — Là người học, tôi muốn di chuyển một bộ thẻ sang bộ thẻ cha khác (hoặc ra
  gốc), để sắp xếp lại thư viện.
- **US-4** — Là người học, tôi muốn xoá một bộ thẻ không còn cần, để dọn dẹp.
- **US-5** — Là người học, tôi muốn sắp xếp danh sách theo nhiều tiêu chí, để ưu tiên nội
  dung phù hợp.

## 5. Luồng nghiệp vụ (Use cases)

### UC-1: Tạo / đổi tên / di chuyển bộ thẻ
- **Luồng chính:** người học tạo bộ thẻ (tên bắt buộc) ở gốc hoặc bên trong một bộ thẻ
  cha; có thể đổi tên hoặc di chuyển sang bộ thẻ cha khác / ra gốc.
- **Luồng ngoại lệ:** không cho di chuyển một bộ thẻ vào chính cây con của nó (tránh chu trình).

### UC-2: Xoá bộ thẻ
- **Luồng chính:** người học xoá bộ thẻ; hệ thống yêu cầu xác nhận và **xoá lan** toàn bộ
  cây con (bộ thẻ con, thẻ, nghĩa và trạng thái ôn bên trong).

### UC-3: Thêm thẻ vào bộ thẻ
- **Luồng chính:** người học thêm thẻ thủ công ("Thêm từ") hoặc nạp hàng loạt qua Nhập.

### UC-4: Sắp xếp danh sách
- **Luồng chính:** người học chọn tiêu chí sắp xếp; hệ thống sắp lại danh sách con của một
  bộ thẻ (hoặc danh sách gốc).

## 6. Quy tắc nghiệp vụ (Business rules)

| Mã | Quy tắc | Lý do | Truy vết |
| --- | --- | --- | --- |
| BR-1 | Tên bộ thẻ bắt buộc, không rỗng; có thể trùng tên giữa các bộ thẻ khác cha. | Nhận diện được nhưng không quá cứng nhắc. | — |
| BR-2 | Một bộ thẻ chứa **đồng thời** thẻ trực tiếp và bộ thẻ con (node hỗn hợp). | Linh hoạt, không cần khái niệm thư mục riêng. | — |
| BR-3 | Di chuyển bộ thẻ không được tạo chu trình (không vào cây con của chính nó). | Giữ cây phân cấp hợp lệ. | — |
| BR-4 | Xoá bộ thẻ là **xoá lan toàn bộ cây con** (bộ thẻ con + thẻ + nghĩa + srs), sau xác nhận. | Tránh dữ liệu mồ côi. | D-024 |
| BR-5 | Số liệu của bộ thẻ (số thẻ, tiến độ, số đến hạn, số ẩn) **tổng hợp đệ quy** từ cây con. | Cho cái nhìn tổng quan tức thì. | — |
| BR-6 | Sắp xếp theo: bảng chữ cái, ngày tạo, ngày học gần nhất — mỗi tiêu chí có chiều tăng/giảm. | Phù hợp nhiều thói quen học. | D-023 |

> Học/ôn tại một bộ thẻ cha gộp **đệ quy** thẻ của cả cây con — quy tắc này thuộc luồng
> học (`docs/business/study/study-flow.md`, D-009).

## 7. Tiêu chí chấp nhận (Acceptance criteria)

- **AC-1** — *Cho* một bộ thẻ có nội dung con (bộ thẻ con và/hoặc thẻ), *khi* xoá và xác
  nhận, *thì* toàn bộ cây con bị xoá. ↔ D-024
- **AC-2** — *Cho* tạo bộ thẻ với tên rỗng, *khi* lưu, *thì* hệ thống chặn. ↔ BR-1
- **AC-3** — *Cho* thao tác di chuyển tạo chu trình, *khi* thực hiện, *thì* hệ thống từ chối. ↔ BR-3
- **AC-4** — *Cho* danh sách bộ thẻ, *khi* chọn một tiêu chí sắp xếp, *thì* danh sách được
  sắp đúng theo tiêu chí và chiều đã chọn. ↔ D-023

## 8. Yêu cầu phi chức năng

- Tổng hợp số liệu cây con không gây giật khi mở bộ thẻ lớn.
- Mở bộ thẻ lớn (hàng nghìn thẻ) vẫn cuộn mượt (xem `docs/quality/performance-contract.md`).

## 9. Giả định · Ràng buộc · Phụ thuộc (RAID)

- **Phụ thuộc:** thẻ (`card`); tính năng Nhập/Xuất; cấu trúc `deck` tự tham chiếu
  (`parent_deck_id`) trong schema.

## 10. Câu hỏi mở

- Không.

## 11. Truy vết & liên quan

- **Quyết định:** `docs/decision-tables/core-decision-table.md` — D-023, D-024 (và D-009 cho học đệ quy).
- **Spec liên quan:** `docs/business/flashcard/flashcard-management.md`,
  `docs/business/study/study-flow.md`, `docs/business/import-export/import-export.md`.
- **Dữ liệu:** `docs/database/schema-contract.md` — bảng `deck` (tự lồng qua `parent_deck_id`).
