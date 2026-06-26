# Bảng thuật ngữ — MemoX V4

Tên canonical cho mọi khái niệm miền. Định nghĩa một lần ở đây; dùng đúng từ đó ở
mọi nơi (code, docs, UI). Đổi tên một thuật ngữ = phải cập nhật mọi tham chiếu —
tìm bằng `node tool/doc_guard/run.mjs terms <old>`.

Tên canonical để **tiếng Anh** (khớp code); nhãn UI và định nghĩa tiếng Việt ở các cột bên.

## Cấu trúc nội dung

| Tên (canonical) | Định nghĩa | Ghi chú |
| --- | --- | --- |
| LanguagePair | Ngữ cảnh học: một ngôn ngữ nguồn (đang học) + một ngôn ngữ đích (của người học). Mọi nội dung thuộc về đúng một cặp. | UI: "Cặp ngôn ngữ". Đảo chiều được (KO→VI / VI→KO). |
| NativeLanguage | Tiếng mẹ đẻ của người học, đặt ở mức toàn cục; mặc định là mặt nghĩa. | UI: "Tiếng mẹ đẻ". Khác với ngôn ngữ giao diện và khác ngôn ngữ đang học. |
| Folder | Nút chứa, gồm thư mục con và/hoặc bộ thẻ; lồng được nhiều cấp. | UI: "Thư mục". Tổng hợp số liệu/tiến độ của toàn bộ cây con. |
| Deck | Nút trực tiếp chứa các thẻ. | UI: "Bộ thẻ". Folder và Deck đều là *nút học được*. |
| StudyableNode | Bất kỳ Folder hay Deck nào; có thể bắt đầu học/luyện tại bất kỳ nút (một deck, hoặc cả một cây thư mục). | Không phải kiểu lưu trữ — chỉ là một vai trò. |
| Card | Một mục từ vựng: một `term` + một hoặc nhiều `CardMeaning`, kèm audio, giới tính, cờ ẩn (tuỳ chọn). | UI: "Thẻ" / "Từ". **Đa trường**, KHÔNG phải cặp mặt trước/mặt sau. |
| CardMeaning | Phần nghĩa theo một ngôn ngữ — **một ô văn bản tự do** (dịch + giải thích + từ nguyên gõ chung). | Một thẻ có thể có nhiều ngôn ngữ (vd VI mẹ đẻ + EN trung gian). |
| Term | Mặt ngôn ngữ-đang-học của thẻ (mặt hỏi/đề bài). | vd `폐강`. |
| SrsState | Trạng thái lập lịch của một thẻ (một chiều duy nhất): ô Leitner, hạn ôn, kết quả gần nhất. | Một dòng cho mỗi thẻ. |
| LeitnerBox | Ô (1..N) mà thẻ đang nằm; ô càng cao thì khoảng cách ôn càng dài. | UI: "Ô". **MemoX dùng 8 ô** (thuật toán 8-box); app gốc mặc định 7. |
| CardStatus | Vòng đời suy ra: `new` → `learning` → `due` → `mastered`, cộng `hidden`. | `hidden` bị loại khỏi hàng đợi và khỏi số đến hạn. |
| DueCount | Số thẻ không ẩn có `due_at <= now` của một nút. | Badge đỏ; UI giới hạn "99+". |
| Progress | Tỉ lệ thành thạo của một nút = số thẻ mastered / tổng số thẻ. | Chỉ số `%` mỗi nút; cộng dồn lên cây. |

## Hoạt động

| Tên (canonical) | Định nghĩa | Ghi chú |
| --- | --- | --- |
| StudySession | Một lượt học SRS làm đổi `SrsState` + `DailyActivity`. Có **hai lối** tách biệt. | Gồm `DueReview` và `NewLearn`. |
| DueReview | Lối học SRS ôn các thẻ **đến hạn** (`due`). | UI: mục **"Lặp lại"** trong menu (mở bằng nút Play); chỉ hiện khi due>0; nhãn "Lặp lại N từ". |
| NewLearn | Lối học SRS học thẻ **mới** qua **chuỗi 5 chặng khó dần** (Xem lại → Ghép đôi → Đoán → Nhớ lại → Điền). | Vào bằng menu "Học" ("X từ mới"). |
| ReviewMode | Duyệt thẻ (term + nghĩa đầy đủ), sửa inline; không đổi SRS. | UI: "Xem lại". Vừa chạy riêng (menu "Xem lại các từ"), vừa là **chặng 1 của NewLearn**. |
| Game | "Một trò chơi" = **picker** chọn 1 trong 4 game (`MatchingGame`, `MultipleChoiceGame`, `RecallGame`, `TypingGame`) để luyện riêng; không đổi SRS. | 4 game này cũng là chặng 2–5 của `NewLearn`. Kèm dropdown "Chế độ lặp lại giãn cách". |
| MatchingGame | Mini-game ghép cặp term ↔ nghĩa ở 2 cột; cặp ghép đúng biến mất. | UI: "Ghép đôi". |
| MultipleChoiceGame | Mini-game hiện 1 prompt (term) + N lựa chọn nghĩa, chọn đúng. | UI: "Đoán". |
| RecallGame | Mini-game hiện term → lộ nghĩa ("Hiển thị") → tự chấm: "Đã quên" làm thẻ lặp lại trong ván, "Nhớ được" cho qua. | UI: "Nhớ lại". |
| TypingGame | Mini-game hiện nghĩa → gõ term; "Kiểm tra"/"Trợ giúp", "Đúng"/"Thử lại" (dung sai). | UI: "Điền". |
| Player | **Phát tự động (auto-play)** lần lượt các thẻ (term + nghĩa) + audio, rảnh tay; tiến độ dạng chấm; không đổi SRS. | UI: "Trình phát". |
| DailyActivity | Bộ đếm theo ngày, theo cặp: số giây học + số từ học. | UI: "Hoạt động hôm nay". Nuôi mục tiêu/streak. |
| Reminder | Lịch nhắc học: một giờ-trong-ngày + tập các thứ trong tuần. | UI: "Lời nhắc" (vd 13:00, T2–CN). |
| Search | Tìm thẻ theo **term + nghĩa**, toàn cục hoặc trong một nút. | UI: ô tìm kiếm. |
| DailyGoal | Mục tiêu học mỗi ngày (số phút và/hoặc số từ). | Gắn với "Hoạt động hôm nay". |
| Streak | Số ngày liên tiếp đạt DailyGoal. | Reset khi một ngày không đạt. |

## Hệ thống

| Tên (canonical) | Định nghĩa | Ghi chú |
| --- | --- | --- |
| Backup | Bản chụp file cục bộ của toàn bộ dữ liệu, khôi phục được trên máy; hỗ trợ tự động. | UI: "Sao lưu/Khôi phục". **Khác** với Sync. |
| CloudSync | Đồng bộ đa thiết bị qua tài khoản đám mây. | UI: "Đồng bộ đám mây". Đang ở mức *alpha*. |
| Premium | Gói trả phí (thuê bao hằng năm) khoá một phần tính năng. | UI: "Gói Premium". **Hoãn — chưa phát triển ở v1.** |
| Theme | Cá nhân hoá giao diện: chế độ màu, màu nhấn, cỡ chữ. | UI: "Chủ đề". |

## Liên quan

- `docs/business/index.md` — nơi các thuật ngữ này được dùng
- `docs/database/schema-contract.md` — cách Card/CardMeaning/SrsState lưu trữ
