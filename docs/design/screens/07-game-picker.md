# 07. Game picker / Chọn trò chơi

Thiết kế màn **chọn trò chơi** ("Một trò chơi") của MemoX (app học từ vựng flashcard +
SRS, mobile, tiếng Việt). Dùng MemoX Design System trong project này (`Mx*`, `--memox-*`,
Plus Jakarta Sans, light + dark).

**Ngữ cảnh:** người học chọn **1 trong 4** trò chơi để luyện riêng (không đổi lịch ôn),
kèm chọn phạm vi lấy từ.

**Bố cục:** tiêu đề "Một trò chơi". Lưới/menu 4 lựa chọn (mỗi mục: icon + tên + mô tả
ngắn): **Ghép đôi · Đoán · Nhớ lại · Điền**. Dropdown "Chế độ lặp lại giãn cách": Theo
giãn cách / Tất cả / Chỉ thẻ chưa thuộc.

**Thiết kế các state sau — mỗi state một frame:**

> Gồm cả **trạng thái tương tác** của mọi control trên màn (ô nhập/tìm khi đang gõ, dropdown · bộ chọn · menu ⋮ khi mở, mục đang chọn, bottom sheet · drawer khi mở) — mỗi cái một frame; đừng để control nào ở dạng tĩnh chưa nối hành vi.

1. **Mặc định** — 4 lựa chọn rõ ràng + dropdown phạm vi (mặc định "Theo giãn cách"); chú
   thích số từ mỗi ván (mặc định 5).
2. **Mở dropdown phạm vi** — danh sách 3 lựa chọn, mục đang chọn được tô.
3. **Không đủ thẻ** — thông báo "Cần thêm thẻ để chơi" + CTA "Thêm từ".

## Hiện thực (W5)

`lib/presentation/features/game/screens/game_picker_screen.dart` (route `/game/:nodeId`) +
`game_screen.dart` (route `/game/:nodeId/play`) + 4 widget game (matching/multiple_choice/
recall/typing). `GameSessionNotifier` (family theo `GameRequest`) dựng ván (≤ `game_words_per_round`
= 5, D-008) qua `BuildGameRoundUseCase`, lọc theo scope; **không đổi SrsState** (D-007). Sai →
thẻ quay lại hàng đợi ván, ván xong khi mọi thẻ đúng (D-015). Mọi copy l10n (`game*`), token Mx*.
**Hoãn:** audio/loa (cần dep TTS ngoài stack), vào game từ menu Play của một nút (W4 study),
gather đệ quy cây con (dùng thẻ trực tiếp của nút ở v1).
