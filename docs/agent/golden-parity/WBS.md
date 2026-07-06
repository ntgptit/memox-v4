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

Quy ước quản lý (yêu cầu 2026-07-06): **folder theo màn, mỗi state = 1 file
`.dart` riêng**. Thêm state = thêm 1 file (+1 dòng đăng ký), không sửa file chung
→ diff PR gọn, không đụng độ, dễ maintain.

```
test/
  fixtures/                          ← MỚI · data thuần, KHÔNG widget, golden-only
    _fixture.dart                       StateFixture: { overrides, drive?, contentMask? }
    state_registry.dart                 gộp mọi *_fixtures.dart → registry toàn cục
    dashboard/                          ← 1 FOLDER / màn
      dashboard_empty_fixture.dart      ← 1 FILE / state (seed khớp MOCK CONTENT kit)
      dashboard_not_studied_fixture.dart
      dashboard_loaded_fixture.dart
      dashboard_goal_met_fixture.dart
      dashboard_streak_reset_fixture.dart
      dashboard_loading_fixture.dart
      dashboard_fixtures.dart           barrel: {stateName → fixture} cho MÀN NÀY
    library/
      library_empty_fixture.dart
      library_loaded_fixture.dart
      ...  library_fixtures.dart
    ...  (22 folder màn)
  golden/
    support/
      screen_golden.dart             ← pump 390×780 @DPR1, (screen,state,theme) → golden
    screens/                         ← MỚI · parity golden, 1 FOLDER / màn
      dashboard/
        dashboard_golden_test.dart      loop state×theme của MÀN NÀY từ registry
      library/ library_golden_test.dart
      ...
    goldens/
      screens/                       ← PNG commit, CHỈ sinh trên CI ubuntu
        dashboard--empty--light.png … (tên khớp shot kit)
      token_swatch_*.png             ← giữ (structural)
    gallery/                         ← giữ (component structural)
tool/visual-diff/                    ← MỚI (cạnh exporter) · bước SO kit↔Flutter
  diff.mjs                              align theo filename → downscale → pixelmatch/SSIM
  thresholds.json                       ngưỡng per-màn (ratchet baseline)
  masks/<screen>--<state>.json          vùng mask content (S2)
```

Nguyên tắc: `fixtures/<screen>/` chỉ data (mỗi state 1 file); `golden/screens/
<screen>/` chỉ pixel Flutter; `tool/visual-diff/` chỉ so hai phía. Behavior test
(`presentation/features/…`) **giữ nguyên**, không refactor (quyết định #2).

**Vì sao file-per-state (không phải 1 file/màn gộp hết state):** state là đơn vị
thay đổi (thêm/sửa/xoá theo kit) — 1 file/state ⇒ blast-radius = 1 file, review
per-state rõ, không xung đột khi nhiều người sửa các state khác nhau cùng màn.
Barrel `<screen>_fixtures.dart` là chỗ DUY NHẤT gộp — thêm state = `export` + 1
entry map.

---

## 2. Contract của fixture (StateFixture)

```dart
class StateFixture {
  final List<Override> overrides;              // seed store/service cho state
  final Future<void> Function(WidgetTester)? drive;   // tap tới overlay / fake stuck-error
  final List<Rect> contentMask;                // vùng chữ/số bỏ qua khi diff (S2)
}
```
- Mỗi state ở 1 file `<screen>_<state>_fixture.dart` → 1 `StateFixture` const/
  factory. Barrel `<screen>_fixtures.dart` gom `{stateName → fixture}` cho màn đó.
- `state_registry.dart`: `Map<String, Map<String, StateFixture>>` — gộp mọi barrel;
  key ngoài = screen id, key trong = **tên state đúng theo screen-state-matrix.md**.
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

### G.0 — Scaffolder + contract + hiệu chuẩn (Dashboard) *(1 PR, KHÔNG chặn trên VP)*
- [ ] `tool/golden/scaffold.mjs` (§4b): matrix → folders + fail-stub files, idempotent,
      `--check` coverage (§5). Template Dart cho fixture/barrel/golden test.
- [ ] `_fixture.dart` (kiểu `StateFixture`) + `screen_golden.dart` (pump 390×780).
- [ ] Chạy scaffolder → **toàn bộ 22 màn × 126 state** ra khung fail-stub (chưa logic).
- [ ] Điền logic **Dashboard** (6 state) làm mẫu — chứng minh AI chỉ-viết-logic.
- [ ] `diff.mjs` bản đầu + hiệu chuẩn trên 1 cặp ảnh THẬT (shot kit dashboard hiện
      có — dù stale — "calibration only"); chốt downscale/metric/format.
- **DoD:** scaffolder sinh đủ khung + `--check` xanh; Dashboard 6 state đã điền →
      golden xanh; diff phân biệt "khác AA" (PASS) vs "lệch 8px/sai màu" (FAIL).

### G.1 — Điền logic 21 màn còn lại *(theo batch, AI chỉ viết logic)*
- [ ] Với mỗi màn: điền seed + drive + mask cho từng state file (xoá sentinel);
      golden chuyển đỏ→xanh. KHÔNG dựng khung tay — đã có từ scaffolder.
- [ ] Baseline PNG sinh trên CI ubuntu.
- **DoD:** mọi state matrix có golden × 2 theme đã điền; `scaffold.mjs --check` xanh;
      không còn sentinel; baseline commit từ CI.

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

## 4b. Scaffolder — `tool/golden/scaffold.mjs` (máy sinh khung, fail mặc định)

> Nguồn sót lớn nhất là **thêm state bằng tay**. Bỏ hẳn: một tool đọc
> `screen-state-matrix.md` (126 state) và **sinh toàn bộ khung** cho từng
> screen×state; con người/AI **chỉ điền logic**.

**Tool sinh gì (per screen×state):**
- `test/fixtures/<screen>/<screen>_<state>_fixture.dart` — skeleton `StateFixture`
  với import, ký hiệu, và **1 vùng `// TODO(logic):` duy nhất**; giá trị khởi tạo
  là sentinel `_unimplemented('<screen>/<state>')` (fail khi chạy).
- `test/fixtures/<screen>/<screen>_fixtures.dart` — barrel: export + entry map.
- `test/golden/screens/<screen>/<screen>_golden_test.dart` — vòng lặp state×theme
  đã nối vào registry; mỗi state là 1 `testWidgets` gọi `screen_golden`.
- `test/fixtures/state_registry.dart` — gộp mọi barrel.

**3 tính chất bắt buộc:**
1. **Fail mặc định** — stub chưa điền ⇒ `fail("TODO: <screen>/<state> chưa có
   fixture")`. Chưa làm = ĐỎ, không bao giờ xanh nhầm (yêu cầu của bạn).
2. **Idempotent, không đè logic** — chạy lại chỉ TẠO file thiếu; file đã điền
   (không còn sentinel) KHÔNG bị ghi đè. Thêm state kit mới → chạy tool → chỉ mọc
   1 stub mới.
3. **Sinh từ matrix, không tay** — danh sách screen×state×theme lấy 100% từ
   `screen-state-matrix.md`. Matrix là hợp đồng; tool là cái tay máy.

**Quy trình dùng:** đổi/ thêm state ở kit → cập nhật matrix → `node tool/golden/
scaffold.mjs` → stub mới xuất hiện (đỏ) → AI điền logic (seed + mask + xoá
sentinel) → xanh. AI **không** dựng folder/khung/registry bằng tay ⇒ không sót.

## 5. Gate coverage (matrix ↔ fixture ↔ golden)
`scaffold.mjs --check` (chạy trong verify gate): mọi state trong matrix phải có
đủ 3 file (fixture + entry barrel + testWidgets trong golden test); mọi file phải
map về matrix. Thiếu/mồ côi = đỏ. Cùng với "fail mặc định", đây là hai lớp khoá:
**coverage** (đủ file) + **implementation** (file đã điền, hết sentinel).

## 6. Quyết định

| ID | Câu hỏi | Trạng thái |
|---|---|---|
| Đ-G-1 | Metric: pixelmatch (threshold màu) vs SSIM | chốt ở G.0 sau calibrate |
| Đ-G-2 | Downscale ×0.5 đủ dập nhiễu? hay ×0.25 | chốt ở G.0 |
| Đ-G-3 | Ngưỡng khởi điểm per-màn (vd < 2% pixel-khác sau downscale) | chốt ở G.2 |
| Đ-G-4 | Content: tái tạo mock vs mask — mặc định per màn | quyết trong lúc build từng màn |
| Đ-G-5 | Fail-stub tương tác CI: job golden riêng cho-phép-đỏ trong lúc build (worklist), tách khỏi gate chặn — vs skipped+đếm | đề xuất: **job riêng đỏ-được** trong buildout; coverage `--check` thì CHẶN (rẻ, luôn xanh sau scaffold). Màn đã điền xong mới nhập gate chính. |

## 7. Rủi ro

| Rủi ro | Né |
|---|---|
| **Content lệch (S2) làm diff nổ** | fixture tái tạo mock content; mask vùng cố-ý-khác; khai báo per-state |
| Ngưỡng khó chỉnh (nhiễu AA) | downscale trước diff; SSIM nếu pixelmatch quá nhạy; ratchet, calibrate trên ảnh thật |
| Golden nhạy platform | sinh/diff CHỈ trên CI ubuntu (S3); local = update-and-review |
| Shots kit stale/chưa có | G.1 độc lập; G.2 chặn trên VP.2; calibrate G.0 ghi rõ "stale, chỉ thử cơ chế" |
| 2 nguồn fixture lệch nhau (QĐ#2) | gate coverage §5 + đối chiếu định kỳ; chấp nhận đánh đổi có chủ đích |
| Scaffolder đè mất logic đã điền | idempotent: chỉ tạo file thiếu; phát hiện "đã điền" = không còn sentinel → skip file đó |
| Fail-stub làm đỏ CI dài ngày | Đ-G-5: job worklist riêng đỏ-được; gate chính chỉ chặn `--check` coverage |
