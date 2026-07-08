# Khuôn scenario (copy vào file feature)

```
### SC-<FEATURE>-<n> — <tên ngắn phát biểu hành vi>
Nguồn: <D-xxx[, D-yyy]> · kit: <screen>[<state>[, <state>]] · BR: <business file §mục>
Tiền điều kiện (Given):
  - DB: <bảng(dữ liệu khởi tạo tối thiểu)>
  - Cài đặt (nếu khác mặc định): <vd new_cards_per_day=20>
Thao tác (When):
  1. <thao tác người dùng trên màn> → <screen>[<state>]
  2. <thao tác tiếp> …
Kỳ vọng (Then):
  - UI: <screen>[<state>] hiện; <yếu tố nhìn thấy khớp kit>
  - DB: <bảng.cột> = <giá trị>; <bảng> +N/-N dòng
Biến thể (nếu có):
  - <đổi 1 điều kiện Given> ⇒ <đổi Then tương ứng> (trích D-xxx khác)
```

Nhắc:
- 1 scenario = 1 hành vi kiểm được. Journey dài chia thành các scenario nối nhau bằng Given.
- State UI phải tra `docs/contracts/<screen>.md`; cột DB tra `docs/database/schema-contract.md`.
- KHÔNG trích `lib/...`/tên class. KHÔNG mô tả "code làm gì" — chỉ "người dùng thấy/DB lưu gì".
