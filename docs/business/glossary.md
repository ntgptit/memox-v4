# Bảng thuật ngữ nghiệp vụ — MemoX V4

Ngôn ngữ chung giữa người dùng, BA và kỹ thuật. Mỗi thuật ngữ được định nghĩa một lần ở
đây và dùng nhất quán trong toàn bộ tài liệu. Cột "Tên kỹ thuật" giữ định danh dùng trong
mã nguồn để truy vết; đổi tên một thuật ngữ phải cập nhật mọi nơi
(`node tool/doc_guard/run.mjs terms <cũ>`).

## Nội dung & cấu trúc

| Thuật ngữ | Định nghĩa nghiệp vụ | Tên kỹ thuật |
| --- | --- | --- |
| Cặp ngôn ngữ | Ngữ cảnh học gồm ngôn ngữ đang học và ngôn ngữ của người học; mọi nội dung thuộc về một cặp. Đảo chiều hiển thị được. | `LanguagePair` |
| Tiếng mẹ đẻ | Ngôn ngữ của người học, đặt ở mức toàn cục; mặt nghĩa mặc định. | `NativeLanguage` |
| Bộ thẻ | Nút thư viện **tự lồng**: chứa thẻ trực tiếp và/hoặc bộ thẻ con; lồng nhiều cấp. | `Deck` |
| Thẻ học | Đơn vị từ vựng: một term cùng một/nhiều khối nghĩa, kèm âm thanh và các cờ. | `Card` |
| Nghĩa | Khối nghĩa theo một ngôn ngữ — một ô văn bản tự do. | `CardMeaning` |
| Term | Mặt ngôn ngữ đang học của thẻ (mặt hỏi). | `term` |
| Trạng thái ôn | Tình trạng lập lịch của một thẻ: ô Leitner, hạn ôn, kết quả gần nhất. | `SrsState` |
| Ô Leitner | Ô (0..8) quyết định khoảng cách ôn; ô càng cao, ôn càng thưa. | `LeitnerBox` |
| Trạng thái thẻ | Vòng đời: mới → đang học → đến hạn → đã thuộc, cộng "ẩn". | `CardStatus` |
| Số đến hạn | Số thẻ không ẩn đã đến hạn ôn của một nút (badge đỏ). | `DueCount` |
| Tiến độ | Tỉ lệ thẻ đã thuộc trên tổng số thẻ của một nút. | `Progress` |

## Hoạt động học

| Thuật ngữ | Định nghĩa nghiệp vụ | Tên kỹ thuật |
| --- | --- | --- |
| Ôn thẻ đến hạn | Hình thức học theo lịch SRS, ôn các thẻ đã đến hạn. Mở qua "Lặp lại" (chỉ hiện khi có thẻ đến hạn). | `DueReview` |
| Học thẻ mới | Hình thức học SRS đưa thẻ mới vào lịch qua chuỗi 5 chặng khó dần. Mở qua "Học". | `NewLearn` |
| Xem lại | Duyệt thẻ (term + nghĩa); không ảnh hưởng lịch ôn. | `ReviewMode` |
| Trò chơi | Bốn trò luyện (Ghép đôi, Đoán, Nhớ lại, Điền); không ảnh hưởng lịch ôn. | `Game` |
| Trình phát | Phát tự động các thẻ kèm âm thanh; không ảnh hưởng lịch ôn. | `Player` |
| Hoạt động hôm nay | Số phút và số từ học trong ngày (chỉ từ Ôn/Học). | `DailyActivity` |
| Mục tiêu ngày | Mục tiêu học mỗi ngày: số phút và/hoặc số từ. | `DailyGoal` |
| Streak | Số ngày liên tiếp đạt mục tiêu ngày. | `Streak` |
| Nhắc học | Lịch nhắc gồm giờ trong ngày và tập thứ trong tuần. | `Reminder` |
| Tìm kiếm | Tìm thẻ theo term và nghĩa, toàn cục hoặc trong một nút. | `Search` |

## Hệ thống

| Thuật ngữ | Định nghĩa nghiệp vụ | Tên kỹ thuật |
| --- | --- | --- |
| Sao lưu | Bản chụp file cục bộ, khôi phục được trên máy. Khác đồng bộ. | `Backup` |
| Đồng bộ | Đồng bộ dữ liệu đa thiết bị qua tài khoản Google (alpha). | `CloudSync` |
| Theme | Cá nhân hoá giao diện: chế độ màu, màu nhấn, cỡ chữ. | `Theme` |
| Premium | Gói trả phí — **hoãn ở v1**. | `Premium` |

## Liên quan

- `docs/business/index.md` — danh mục yêu cầu
- `docs/database/schema-contract.md` — cách các khái niệm này được lưu trữ
