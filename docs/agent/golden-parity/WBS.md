# Golden-Parity WBS — Flutter screen goldens ↔ kit shots (tolerance diff)

> **Mục tiêu.** Dựng lớp golden test phía Flutter: render MỌI màn × state × theme
> với data seed khớp state của kit (`docs/design/screen-state-matrix.md`), sinh
> `goldens/screens/<screen>--<state>--<theme>.png`, và **so tự động** với ảnh kit
> `shots/<screen>--<state>--<theme>.png` do exporter (visual-parity WBS) chụp.
> Quyết định 2026-07-06: (1) **diff pixel tự động**, (2) golden dùng **fixture
> riêng**, (3) viết WBS này trước khi code.
>
> Bổ trợ, KHÔNG thay: visual-parity WBS (`docs/agent/visual-parity/WBS.md`) lo
> phía KIT (exporter → shots). Golden-parity lo phía FLUTTER + bước SO. Đây là
> hiện thực hoá VP.6 ("đo Flutter thật") bằng golden thay vì đo getRect.

---

## 0. Sự thật kỹ thuật phải nắm trước (định hình toàn bộ thiết kế)

**S1 — Cross-renderer KHÔNG bằng-nhau-tuyệt-đối.** Golden Flutter = Skia; shot
kit = Chromium (Playwright). Font hinting, sub-pixel AA, shadow blur luôn lệch ở
mức pixel. ⇒ "diff tự động" = **diff DUNG SAI / perceptual**, không phải
exact-equality. Cụ thể: chuẩn hoá (downscale) → `pixelmatch`/SSIM → **ngưỡng hiệu
chuẩn per-màn** (baseline ratchet). Không có ngưỡng thì gate đỏ vĩnh viễn.

**S2 — RỦI RO #1: nội dung phải khớp.** Kit render MOCK COPY ("Good evening,
Linh", "TOPIK I — Vocabulary", "48 due", "12:30"…). Flutter render ARB + fake
data, và nhiều chỗ **cố ý khác** (greeting không có tên "Linh"; ngày format
khác; số liệu illustrative). Chữ lệch → diff nổ. Hai lối xử lý, chọn per-vùng:
- **Tái tạo mock content**: golden fixture seed **đúng** nội dung kit (tên "Linh",
  deck "TOPIK I", đúng số) → dùng khi Flutter *có thể* nhận content ngoài.
- **Mask vùng nội dung**: bôi đen vùng chữ/số trước khi diff, chỉ so layout/màu →
  dùng khi content Flutter cố ý khác kit (greeting, date).
Đây là chi phí lớn nhất của "diff tự động"; mỗi màn phải khai báo content-strategy.

**S3 — Lockstep kích thước & platform.** Cả hai ảnh phải 390×780 @ DPR 1. Golden
Flutter vốn nhạy platform (font dev↔CI) ⇒ **cả golden lẫn bước diff chỉ sinh/chạy
trên platform chuẩn (CI ubuntu)**, đúng quy ước "V.1 golden suite runs on the
canonical platform" đã ghi trong `component_gallery_test.dart`.

**S4 — Phụ thuộc shots tươi.** Shots kit hiện STALE (exporter mất). ⇒ tách:
G.1 (golden Flutter, có giá trị ĐỘC LẬP làm regression) chạy ngay được; **G.2
(bước diff kit↔Flutter) chặn trên visual-parity VP.2** (exporter sinh shots tươi).

---

## 1. Kiến trúc folder — tách theo MỤC ĐÍCH

```
test/
  fixtures/                       ← MỚI · data thuần, KHÔNG widget, golden-only
    _fixture.dart                    StateFixture: { overrides, drive?, contentMask? }
    state_registry.dart              screen → { stateName → StateFixture }; nguồn chân lý
    dashboard_fixtures.dart          seed khớp MOCK CONTENT kit (Linh/TOPIK I/…)
    library_fixtures.dart
    ...
  golden/
    support/
      screen_golden.dart          ← pump 390×780 @DPR1, (screen,state,theme) → golden
    screens/                      ← MỚI · parity golden, 1 file/màn
      dashboard_golden_test.dart     loop state×theme → goldens/screens/dashboard--*.png
      ...
    goldens/
      screens/                    ← PNG commit, CHỈ sinh trên CI ubuntu
      token_swatch_*.png          ← giữ (structural)
    gallery/                      ← giữ (component structural)
tool/visual-diff/                 ← MỚI (cạnh exporter) · bước SO kit↔Flutter
  diff.mjs                           align theo filename → downscale → pixelmatch/SSIM
  thresholds.json                    ngưỡng per-màn (ratchet baseline)
  masks/<screen>--<state>.json       vùng mask content (S2)
```

Nguyên tắc: `fixtures/` chỉ data (dùng lại được); `golden/screens/` chỉ pixel
Flutter; `tool/visual-diff/` chỉ so hai phía. Behavior test (`presentation/
features/…`) **giữ nguyên**, không refactor (quyết định #2).

---

## 2. Contract của fixture (StateFixture)

```dart
class StateFixture {
  final List<Override> overrides;              // seed store/service cho state
  final Future<void> Function(WidgetTester)? drive;   // tap tới overlay / fake stuck-error
  final List<Rect> contentMask;                // vùng chữ/số bỏ qua khi diff (S2)
}
```
- `state_registry.dart`: `Map<String, Map<String, StateFixture>>` — key ngoài =
  screen id, key trong = **tên state đúng theo screen-state-matrix.md**.
- Fixture seed **mock content kit** khi có thể (S2 lối 1); khai báo `contentMask`
  cho phần cố ý khác (S2 lối 2).
- Golden-only: KHÔNG đụng fake của behavior test (giữ 2 nguồn tách biệt theo QĐ#2;
  đánh đổi: chấp nhận có thể lệch giữa "state behavior kiểm" và "state golden vẽ" —
  bù lại bằng gate coverage §5).

---

## 3. Bước diff (`tool/visual-diff/diff.mjs`)

Input: `test/golden/goldens/screens/*.png` (Flutter) + `.../shots/*.png` (kit).
1. Align theo filename `<screen>--<state>--<theme>`; báo file lệch danh sách 2 phía.
2. Áp mask (`masks/<screen>--<state>.json`) lên CẢ hai ảnh.
3. **Downscale ×0.5** (dập nhiễu sub-pixel AND giữ cấu trúc layout/màu).
4. `pixelmatch` (threshold màu) → % pixel khác; HOẶC SSIM → điểm tương đồng.
5. So với `thresholds.json[screen--state]`; đỏ khi vượt. Xuất ảnh diff + báo cáo.
6. **Ratchet**: ngưỡng chỉ được siết, không nới; nới phải kèm lý do commit.

Output: `visual-diff-report.md` + `diff/<screen>--<state>--<theme>.png` (heatmap).

---

## 4. Phases

### G.0 — Spike + hiệu chuẩn trên Dashboard *(1 PR, KHÔNG chặn trên VP)*
- [ ] `_fixture.dart` + `screen_golden.dart` + `dashboard_fixtures.dart` (6 state).
- [ ] `diff.mjs` bản đầu + hiệu chuẩn ngưỡng trên 1 cặp ảnh THẬT (dùng shot kit
      dashboard hiện có — dù stale — chỉ để calibrate cơ chế, ghi rõ "calibration
      only").
- [ ] Chốt: downscale factor, metric (pixelmatch vs SSIM), format mask/threshold.
- **DoD:** chứng minh diff phân biệt được "cùng layout, khác AA" (PASS) vs "card
      lệch 8px / sai màu / thiếu element" (FAIL) trên dashboard. Docs cơ chế.

### G.1 — Golden Flutter (độc lập, có giá trị regression riêng) *(theo batch)*
- [ ] `state_registry` phủ 22 màn theo matrix (126 state); fixture per màn.
- [ ] `golden/screens/<screen>_golden_test.dart` sinh baseline trên CI ubuntu.
- [ ] Gate coverage matrix↔fixture (§5).
- **DoD:** mọi state matrix có 1 golden × 2 theme; `flutter test` xanh; baseline
      commit từ CI.

### G.2 — Bước diff kit↔Flutter *(CHẶN trên visual-parity VP.2 = shots tươi)*
- [ ] `diff.mjs` hoàn thiện + `thresholds.json` baseline per màn (hiệu chuẩn thật).
- [ ] Mask cho các màn content-cố-ý-khác (greeting, date, illustrative counts).
- [ ] CI job (ubuntu): sinh golden → lấy shots → diff → fail theo ngưỡng.
- **DoD:** đổi kit không re-mirror Flutter → diff đỏ; nới ngưỡng phải có lý do.

### G.3 — Gate & wiring-guard *(1 PR)*
- [ ] Wire vào `tool/verify/run.mjs` (golden test full; diff step khi shots có mặt,
      skip-có-thông-báo khi chưa — như code guard).
- [ ] Wiring-guard test (golden suite tồn tại, diff được gọi, thresholds ratchet).
- [ ] Docs: cập nhật retrospective + visual-parity WBS (VP.6 = golden-parity này).

### G.4 — *(phase 2, sau)* Golden ngoài kit-state
- Interaction/responsive/error state Flutter-only mà kit không phủ (đúng "sau đó
  mới sang điểm khác" của yêu cầu). Không diff kit (không có shot đối chiếu) — chỉ
  regression Flutter.

---

## 5. Gate coverage (matrix ↔ fixture)
Script nhỏ: mọi state trong `screen-state-matrix.md` phải có entry trong
`state_registry`; mọi entry phải map về matrix. Thiếu/mồ côi = đỏ. Ngăn "phủ giả".

## 6. Quyết định

| ID | Câu hỏi | Trạng thái |
|---|---|---|
| Đ-G-1 | Metric: pixelmatch (threshold màu) vs SSIM | chốt ở G.0 sau calibrate |
| Đ-G-2 | Downscale ×0.5 đủ dập nhiễu? hay ×0.25 | chốt ở G.0 |
| Đ-G-3 | Ngưỡng khởi điểm per-màn (vd < 2% pixel-khác sau downscale) | chốt ở G.2 |
| Đ-G-4 | Content: tái tạo mock vs mask — mặc định per màn | quyết trong lúc build từng màn |

## 7. Rủi ro

| Rủi ro | Né |
|---|---|
| **Content lệch (S2) làm diff nổ** | fixture tái tạo mock content; mask vùng cố-ý-khác; khai báo per-state |
| Ngưỡng khó chỉnh (nhiễu AA) | downscale trước diff; SSIM nếu pixelmatch quá nhạy; ratchet, calibrate trên ảnh thật |
| Golden nhạy platform | sinh/diff CHỈ trên CI ubuntu (S3); local = update-and-review |
| Shots kit stale/chưa có | G.1 độc lập; G.2 chặn trên VP.2; calibrate G.0 ghi rõ "stale, chỉ thử cơ chế" |
| 2 nguồn fixture lệch nhau (QĐ#2) | gate coverage §5 + đối chiếu định kỳ; chấp nhận đánh đổi có chủ đích |
