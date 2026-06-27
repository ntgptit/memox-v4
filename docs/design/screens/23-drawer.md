# 23. Drawer / Ngăn điều hướng & Cặp ngôn ngữ

Thiết kế **ngăn điều hướng (drawer)** và màn **Thêm cặp ngôn ngữ** của MemoX (app học từ
vựng flashcard + SRS, mobile, tiếng Việt). Dùng MemoX Design System trong project này
(`Mx*`, `--memox-*`, Plus Jakarta Sans, light + dark).

**Ngữ cảnh:** drawer là trung tâm điều hướng phụ và quản lý ngôn ngữ.

**Bố cục drawer:** header "Hoạt động hôm nay" (đồng hồ thời gian + số từ). Danh sách mục:
Thêm ngôn ngữ · Xóa ngôn ngữ · Nhập · Xuất · Thống kê · Chủ đề · Cài đặt · Câu hỏi thường
gặp · Gửi email · Đồng bộ (alpha).

**Thiết kế các state sau — mỗi state một frame:**

> Gồm cả **trạng thái tương tác** của mọi control trên màn (ô nhập/tìm khi đang gõ, dropdown · bộ chọn · menu ⋮ khi mở, mục đang chọn, bottom sheet · drawer khi mở) — mỗi cái một frame; đừng để control nào ở dạng tĩnh chưa nối hành vi.

1. **Drawer mở** — header hoạt động + danh sách mục đầy đủ, icon rõ ràng.
2. **Thêm cặp ngôn ngữ** — chọn **ngôn ngữ đang học** → **tiếng mẹ đẻ**; nút "Thêm".
3. **Xóa ngôn ngữ** — danh sách cặp hiện có + xác nhận xoá (cảnh báo mất dữ liệu cặp đó).

## Hiện thực (S0)

`lib/presentation/shared/navigation/app_drawer.dart` (+ `app_shell.dart`). Ba state qua một
`enum _DrawerView { menu, addLanguage, removeLanguage }`; cặp đang chọn + đảo chiều hiển thị
đọc từ `languagePairNotifierProvider` (keepAlive). Mọi copy qua l10n key (`lib/l10n/*.arb`:
`drawer*`, `addLanguage*`, `removeLanguage*`, `activity*`, `comingSoon`, `common*`); màu/giãn
cách qua token (`MxSpacing`, `Theme`). Header hoạt động hiện 0 phút·0 từ (placeholder, W11
nối số thật). Các mục phụ (Nhập/Xuất/Thống kê/Chủ đề/Cài đặt/FAQ/Email/Đồng bộ) hiện báo
"sắp ra mắt", nối hành vi thật khi feature tương ứng (W8–W13) tới. Tên ngôn ngữ là endonym
(reference data, không l10n) ở `lib/core/constants/supported_languages.dart`.
