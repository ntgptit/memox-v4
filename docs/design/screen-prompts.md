# MemoX — Prompt thiết kế màn hình & state cho Claude Design

Bộ prompt để **Claude Design** thiết kế từng màn hình của MemoX và **mọi state** của
nó, bám sát nghiệp vụ trong `docs/business/**` và **MemoX Design System** đã đồng bộ
(project `ddee88dc`).

## Cách dùng

1. Mở project **MemoX Design System** trên Claude Design.
2. Dán **§0 Prompt nền** một lần để thiết lập ngữ cảnh, rồi dán từng **prompt màn hình**
   (§1…). Mỗi state là một frame riêng.
3. Truy vết: mỗi prompt ghi rõ spec nghiệp vụ + route (`docs/business/navigation/navigation-flow.md`).

---

## §0. Prompt nền (dán một lần đầu phiên)

> Bạn đang thiết kế **MemoX** — app học từ vựng bằng flashcard + lặp lại giãn cách (SRS),
> nền tảng **mobile (Flutter)**, giao diện **tiếng Việt**, hỗ trợ **light + dark**.
> BẮT BUỘC dùng **MemoX Design System** trong project này: token `--memox-*` (màu,
> spacing, radius, typography), component có sẵn tiền tố `Mx`, font **Plus Jakarta Sans**.
> KHÔNG dùng màu/spacing thô. Đã có sẵn kit `ui_kits/memox-app` (Dashboard, Library,
> Settings, StudySession) — các màn mới phải **đồng bộ phong cách** với chúng.
>
> Quy ước state cho MỌI màn: thiết kế các frame riêng cho **loading · rỗng (empty) ·
> có dữ liệu (loaded) · lỗi (error)** khi áp dụng, cộng các state riêng của màn. Mỗi
> hành động phá huỷ có dialog xác nhận; mỗi màn có đúng một hành động chính.
>
> Đơn vị nội dung là **thẻ** (term ngôn ngữ đang học + nghĩa). Mọi nội dung thuộc một
> **cặp ngôn ngữ** (vd 한국어 → Tiếng Việt).

---

## §1. Library / Trang chủ (cây thư viện) — route `library` `/`

Spec: `docs/business/folder/folder-management.md`, `docs/business/deck/deck-management.md`

> Thiết kế màn **Thư viện** — màn chính. Header: bộ chọn **cặp ngôn ngữ** (한국어 ⇄
> Tiếng Việt, có nút đảo chiều) + nút **tìm kiếm** + nút **sắp xếp**. Thân: danh sách
> cây **thư mục / bộ thẻ**, mỗi dòng hiển thị: tên · số từ · số thẻ ẩn (icon mắt gạch) ·
> **% tiến độ** (vòng tròn quanh nút Play) · **badge đỏ số thẻ đến hạn** · nút **Play**.
> FAB "+" tạo thư mục/bộ thẻ; nút "Thêm từ".
>
> State cần thiết kế:
> - **loading** — skeleton danh sách.
> - **empty** — chưa có nội dung, CTA "Tạo bộ thẻ" + "Thêm từ".
> - **loaded** — danh sách đầy đủ (gồm dòng có badge due và dòng 0%).
> - **overlay: menu Play** — bottom sheet 5 mục: **Học** ("N từ mới"), **Lặp lại**
>   ("Lặp lại N từ" — *chỉ hiện khi có thẻ đến hạn*), **Xem lại các từ**, **Một trò
>   chơi** ("đến hạn + mới"), **Trình phát**.
> - **overlay: menu Sắp xếp** — Bảng chữ cái ↑/↓ · Ngày tạo ↑/↓ · Ngày học ↑/↓.

## §2. Dashboard / Hoạt động hôm nay — (engagement)

Spec: `docs/business/engagement/dashboard-engagement.md`

> Thiết kế màn **Dashboard** tổng quan động lực. Khối **Hoạt động hôm nay**: thời gian
> học + số từ học. Khối **Mục tiêu ngày**: vòng/thanh tiến độ tới mục tiêu (phút hoặc
> từ). Khối **Streak**: số ngày liên tiếp + biểu tượng lửa. Lối tắt: "Tiếp tục học",
> "Thẻ đến hạn (N)". Mini-stat: % đã thuộc.
>
> State: **loaded** (đã có hoạt động), **empty** (hôm nay chưa học — khuyến khích bắt
> đầu), **streak vừa lập kỷ lục** (biến thể nhấn mạnh).

## §3. Folder detail / Chi tiết thư mục — route `folderDetail` `/folder/:id`

Spec: `docs/business/folder/folder-management.md`

> Thiết kế màn **Chi tiết thư mục**. Header: nút back · tên thư mục · nút loa (phát
> audio) · nút sửa. Thân: danh sách thư mục con + bộ thẻ (cùng kiểu dòng như Library:
> số từ · % · badge due · Play). Ô tìm trong thư mục + chỉ báo chiều "KO > VI" + sort.
>
> State: **loading**, **empty** (thư mục rỗng), **loaded**, **overlay menu Play** (như §1).

## §4. Deck detail / Danh sách thẻ — route `deckDetail` `/deck/:id`

Spec: `docs/business/deck/deck-management.md`, `docs/business/flashcard/flashcard-management.md`

> Thiết kế màn **Danh sách thẻ** của một bộ thẻ. Mỗi dòng thẻ: **term** (đậm) + **nghĩa**
> (rút gọn) + badge trạng thái (mới/đến hạn/đã thuộc). Thanh dưới: nút **reload** (đặt
> lại tiến độ) · **xuất** · **xoá**. FAB "+" / "Thêm từ".
>
> State: **loading** · **empty** ("Chưa có thẻ" + CTA Thêm từ) · **loaded** · **tìm
> trong bộ thẻ** (có kết quả) · **không có kết quả** · **overlay: thao tác trên một
> thẻ** (sheet: Sửa · Ẩn · Xoá) · **dialog xác nhận xoá**.

## §5. Flashcard editor / Tạo–Sửa thẻ — route `flashcardEditor` `/deck/:id/card`

Spec: `docs/business/flashcard/flashcard-management.md`

> Thiết kế màn **Tạo / Sửa thẻ**. Trường: **Term** (bắt buộc) · **Nghĩa (mẹ đẻ)** — ô
> văn bản tự do, bắt buộc · **Nghĩa ngôn ngữ phụ** (tuỳ chọn) · **Giới tính** (tuỳ chọn,
> chip) · **Audio** (tự sinh TTS, nút phát) · công tắc **Ẩn**.
>
> State: **tạo mới** (form rỗng) · **sửa** (đã điền) · **lỗi validation** (thiếu
> term/nghĩa — báo dưới trường) · **cảnh báo trùng mềm** (banner "Đã có thẻ tương tự —
> vẫn thêm?").

## §6. Học thẻ mới (NewLearn) — chuỗi 5 chặng — route `study` `/study/:nodeId`

Spec: `docs/business/study/study-flow.md`, `docs/business/srs/srs-review.md`

> Thiết kế **luồng học thẻ mới**: thanh tiến độ tích luỹ 0→100% trên đầu; mỗi chặng là
> một frame. Thiết kế đủ **5 chặng**:
> 1. **Xem lại** — 2 vùng: term (có loa) + nghĩa đầy đủ; nút "Tiếp".
> 2. **Ghép đôi** — 2 cột thẻ (term ↔ nghĩa); state: chưa ghép · ghép đúng (cặp biến
>    mất) · ghép sai (rung/đỏ).
> 3. **Đoán** — prompt term + 4 lựa chọn nghĩa; state: chờ chọn · chọn đúng (xanh) ·
>    chọn sai (đỏ + chỉ đáp án đúng).
> 4. **Nhớ lại** — term (nghĩa ẩn) + nút **Hiển thị**; sau khi lộ nghĩa: 2 nút **Đã
>    quên** / **Nhớ được**.
> 5. **Điền** — hiện nghĩa + ô gõ term + **Trợ giúp**/**Kiểm tra**; sau kiểm tra:
>    **Đúng** / **Thử lại** (hiện so khớp ký tự đúng/sai).
>
> Lưu ý: **trả lời sai ở bất kỳ chặng nào** → thẻ quay lại hàng đợi (thiết kế chỉ báo
> "học lại"). Kết thúc → chuyển màn Kết quả (§10).

## §7. Bốn trò chơi + bộ chọn — route `game` `/game/:nodeId`

Spec: `docs/business/game/game-modes.md`

> Thiết kế **bộ chọn "Một trò chơi"**: lưới/menu chọn 1 trong 4 — **Ghép đôi · Đoán ·
> Nhớ lại · Điền** (mỗi mục có icon + tên) + dropdown **"Chế độ lặp lại giãn cách"**
> (Theo giãn cách / Tất cả / Chỉ thẻ chưa thuộc).
>
> Và 4 màn game (dùng lại bố cục các chặng §6, nhưng là phiên độc lập): mỗi game thiết
> kế state **đang chơi** · **đúng** · **sai (học lại trong ván)** · **hoàn thành ván**.

## §8. Xem lại (Review) — route `review` `/review/:nodeId`

Spec: `docs/business/study/study-flow.md`

> Thiết kế màn **Xem lại** (duyệt thẻ, không đổi lịch ôn). Hai vùng: **nghĩa** (trên,
> có nút bút chì sửa inline) + **term** (dưới, có loa). Thanh tiến độ; vuốt/nút qua thẻ
> kế. Header: nút chỉnh cỡ chữ (T) · loa · menu.
>
> State: **đang duyệt** · **đang sửa inline** · **thẻ cuối (kết thúc)**.

## §9. Trình phát (Player) — route `player` `/player/:nodeId`

Spec: `docs/business/study/study-flow.md`

> Thiết kế màn **Trình phát** — phát tự động rảnh tay. Hiển thị term + nghĩa của thẻ
> hiện tại + audio; **chỉ báo tiến độ dạng chấm**; điều khiển play/pause, qua thẻ, tốc
> độ. State: **đang phát** · **tạm dừng** · **hết danh sách**.

## §10. Kết quả phiên học (Study result)

Spec: `docs/business/study/study-flow.md`, `docs/business/engagement/dashboard-engagement.md`

> Thiết kế màn **Kết quả** sau một phiên Học/Ôn: số thẻ đã học, tỉ lệ đúng/sai, thời
> gian, **cập nhật streak** (hiệu ứng). CTA: "Tiếp tục" / "Về thư viện". State:
> **đạt mục tiêu ngày** (chúc mừng) · **chưa đạt**.

## §11. Tìm kiếm — route `search` `/search`

Spec: `docs/business/search/global-search.md`

> Thiết kế màn **Tìm kiếm** thẻ. Ô tìm trên cùng; kết quả là danh sách thẻ khớp **term
> hoặc nghĩa**, **gồm cả thẻ ẩn**; **chip lọc trạng thái** (Tất cả / Mới / Đến hạn / Đã
> thuộc).
>
> State: **rỗng** (chưa nhập — gợi ý/gần đây) · **có kết quả** (kèm lọc) · **không có
> kết quả**.

## §12. Thống kê — route `statistics` `/statistics`

Spec: `docs/business/statistics/statistics.md`

> Thiết kế màn **Thống kê** hiện đại. Bộ chọn phạm vi (cặp đang chọn / toàn app). Các
> khối: **heatmap lịch học** (kiểu đóng góp), **streak** (hiện tại + dài nhất), **thời
> gian học** theo tuần (cột), **phân bố theo ô Leitner** 1..8 (cột), **dự báo đến hạn**
> N ngày tới (đường), **độ chính xác** (donut/gauge), **tổng quan thư viện**.
>
> State: **loaded** · **chưa đủ dữ liệu** (empty thân thiện).

## §13. Cài đặt — route `settings` `/settings`

Spec: `docs/business/settings/settings.md`

> Thiết kế màn **Cài đặt** dạng danh sách nhóm: **Ngôn ngữ** (tiếng mẹ đẻ, ngôn ngữ
> giao diện) · **Hiển thị từ** · **Lặp lại giãn cách (SRS)** (số ô = 8, thông báo) ·
> **Trò chơi** (số từ/ván, ngẫu nhiên, bàn phím) · **Giọng nói** (TTS/STT) · **Nhắc
> học** · **Sao lưu/Khôi phục** · **Đồng bộ đám mây**. *Không* hiển thị Premium (hoãn).
>
> State: **loaded** (mỗi nhóm hiện giá trị tóm tắt).

## §14. Nhắc học (Reminder)

Spec: `docs/business/settings/settings.md`

> Thiết kế màn **Nhắc học**: chọn **giờ** (time picker) + **các thứ trong tuần** (chip
> T2…CN). State: **bật** (có giờ + thứ) · **tắt**.

## §15. Tài khoản & Đồng bộ — route `account` `/settings/account`

Spec: `docs/business/account-sync/account-sync.md`

> Thiết kế màn **Tài khoản & Đồng bộ** (Google). State: **chưa đăng nhập** (nút "Đăng
> nhập Google") · **đã đăng nhập** (email, "Đồng bộ lần cuối …", nút Đồng bộ ngay, Đăng
> xuất) · **đang đồng bộ** (tiến trình) · **xung đột** (thông báo last-write-wins) ·
> **offline** (badge "ngoại tuyến").

## §16. Cá nhân hoá / Chủ đề (Theme)

Spec: `docs/business/personalization/personalization.md`

> Thiết kế màn **Chủ đề**: chọn **chế độ màu** (Sáng / Tối / Theo hệ thống) · **màu
> nhấn** (dải swatch) · **cỡ chữ** (Nhỏ / Vừa / Lớn), kèm **xem trước trực tiếp** một
> thẻ mẫu. State: light · dark.

## §17. Nhập / Xuất

Spec: `docs/business/import-export/import-export.md`

> Thiết kế hai màn:
> - **Nhập**: chọn nguồn (CSV / Excel / dán văn bản) + **dấu phân tách** (Tab/phẩy/chấm
>   phẩy) + **ánh xạ cột** + **bước xem trước** + cảnh báo trùng mềm.
> - **Xuất**: chọn **định dạng** (CSV/Excel/sao chép) + phạm vi + công tắc **kèm trạng
>   thái SRS**.

## §18. Quản lý cặp ngôn ngữ & Drawer

Spec: `docs/business/system/overview.md`

> Thiết kế **drawer điều hướng**: header "Hoạt động hôm nay" (timer + số từ) + các mục
> Thêm/Xóa ngôn ngữ · Nhập · Xuất · Thống kê · Chủ đề · Cài đặt · Trợ giúp · Đồng bộ.
> Và màn **Thêm cặp ngôn ngữ** (chọn ngôn ngữ đang học → tiếng mẹ đẻ).

---

## Liên quan

- `docs/business/index.md` — danh mục tính năng (truy vết spec)
- `docs/business/system/system-flow.md` — sơ đồ luồng toàn hệ thống
- `docs/business/navigation/navigation-flow.md` — route & điều hướng
- `docs/design/design-language.md` — token & component dùng chung
- `docs/ui-ux/ui-ux-contract.md` — ràng buộc state mọi màn
