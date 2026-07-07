# Visual parity — matching & lệch theo từng state

> Nguồn: baseline ubuntu CI (`tool/visual-diff/baseline.json`, `bc172ca`) — đúng số cổng ratchet.
> % matching = 100 − mismatch (perceptual YIQ, ngưỡng 0.1). 112 states × light/dark = 224 so sánh.
> **% thấp phần lớn KHÔNG phải bug**: content seed khác + AA cross-renderer + scrim overlay. Bug cấu trúc đã fix (chip, sheet-menu icons, add-title, icon font, Korean font, 6 accents, play-audio, shot cũ).
> Quy ước: light≪dark ⇒ overlay/scrim; light≈dark thấp ⇒ content/seed; ≥96% ⇒ chỉ AA.

## `deck-detail` — avg 75.6%

| state | light | dark | lệch ở đâu | lý do lệch | phương án chỉnh sửa |
|---|--:|--:|---|---|---|
| `move` | 13.2% | 87.8% | Nền sau scrim (light 13% ≪ 88%) | Sheet/dialog phủ scrim lên nền content khác + kit shot bo góc; deck seed 'Food' (3 thẻ) vs kit 'Korean Basics' (có sub-deck) | seed deck khớp kit (có sub-deck) để nền trùng, hoặc contentMask vùng nền |
| `reset-confirm` | 26.2% | 84.1% | Nền sau scrim (light 26% ≪ 84%) | Sheet/dialog phủ scrim lên nền content khác + kit shot bo góc; deck seed 'Food' (3 thẻ) vs kit 'Korean Basics' (có sub-deck) | seed deck khớp kit (có sub-deck) để nền trùng, hoặc contentMask vùng nền |
| `deck-delete-confirm` | 26.7% | 85.4% | Nền sau scrim (light 27% ≪ 85%) | Sheet/dialog phủ scrim lên nền content khác + kit shot bo góc; deck seed 'Food' (3 thẻ) vs kit 'Korean Basics' (có sub-deck) | seed deck khớp kit (có sub-deck) để nền trùng, hoặc contentMask vùng nền |
| `delete-confirm` | 28.1% | 87.6% | Nền sau scrim (light 28% ≪ 88%) | Sheet/dialog phủ scrim lên nền content khác + kit shot bo góc; deck seed 'Food' (3 thẻ) vs kit 'Korean Basics' (có sub-deck) | seed deck khớp kit (có sub-deck) để nền trùng, hoặc contentMask vùng nền |
| `deck-menu` | 37.7% | 96.2% | Nền sau scrim (light 38% ≪ 96%) | Sheet/dialog phủ scrim lên nền content khác + kit shot bo góc; deck seed 'Food' (3 thẻ) vs kit 'Korean Basics' (có sub-deck) | seed deck khớp kit (có sub-deck) để nền trùng, hoặc contentMask vùng nền |
| `add-menu` | 38.1% | 95.8% | Nền sau scrim (light 38% ≪ 96%) | Sheet/dialog phủ scrim lên nền content khác + kit shot bo góc; deck seed 'Food' (3 thẻ) vs kit 'Korean Basics' (có sub-deck) | seed deck khớp kit (có sub-deck) để nền trùng, hoặc contentMask vùng nền |
| `card-actions` | 38.4% | 96.2% | Nền sau scrim (light 38% ≪ 96%) | Sheet/dialog phủ scrim lên nền content khác + kit shot bo góc; deck seed 'Food' (3 thẻ) vs kit 'Korean Basics' (có sub-deck) | seed deck khớp kit (có sub-deck) để nền trùng, hoặc contentMask vùng nền |
| `loaded` | 85.9% | 88.7% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); deck seed 'Food' (3 thẻ) vs kit 'Korean Basics' (có sub-deck) | seed deck khớp kit (có sub-deck) để nền trùng, hoặc contentMask vùng nền |
| `empty` | 89.5% | 88.3% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); deck seed 'Food' (3 thẻ) vs kit 'Korean Basics' (có sub-deck) | seed deck khớp kit (có sub-deck) để nền trùng, hoặc contentMask vùng nền |
| `error` | 94.4% | 94.5% | Text nội dung + AA | Nhãn/số seed khác + AA; deck seed 'Food' (3 thẻ) vs kit 'Korean Basics' (có sub-deck) | seed deck khớp kit (có sub-deck) để nền trùng, hoặc contentMask vùng nền |
| `search` | 95.9% | 96.2% | Cạnh chữ / anti-alias | Khác renderer (Skia vs trình duyệt) — không lệch cấu trúc | Không cần (nhiễu AA) |
| `no-results` | 96.6% | 95.9% | Cạnh chữ / anti-alias | Khác renderer (Skia vs trình duyệt) — không lệch cấu trúc | Không cần (nhiễu AA) |
| `loading` | 98.8% | 99.2% | Cạnh chữ / anti-alias | Khác renderer (Skia vs trình duyệt) — không lệch cấu trúc | Không cần (nhiễu AA) |

## `drawer` — avg 79.8%

| state | light | dark | lệch ở đâu | lý do lệch | phương án chỉnh sửa |
|---|--:|--:|---|---|---|
| `remove-language` | 28.4% | 91.4% | Nền sau scrim (light 28% ≪ 91%) | Sheet/dialog phủ scrim lên nền content khác + kit shot bo góc; danh sách nav; kit có thêm FAQ/Email us/Sync — Flutter bỏ (v1 không backend) | quyết định v1 scope: Sync cần backend (defer); FAQ/Email có thể thêm link tĩnh nếu muốn |
| `open` | 85.7% | 94.9% | Text nội dung + AA | Nhãn/số seed khác + AA; danh sách nav; kit có thêm FAQ/Email us/Sync — Flutter bỏ (v1 không backend) | quyết định v1 scope: Sync cần backend (defer); FAQ/Email có thể thêm link tĩnh nếu muốn |
| `add-language` | 87.7% | 90.7% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); danh sách nav; kit có thêm FAQ/Email us/Sync — Flutter bỏ (v1 không backend) | quyết định v1 scope: Sync cần backend (defer); FAQ/Email có thể thêm link tĩnh nếu muốn |

## `library` — avg 81.6%

| state | light | dark | lệch ở đâu | lý do lệch | phương án chỉnh sửa |
|---|--:|--:|---|---|---|
| `sort-menu` | 29.1% | 95.5% | Nền sau scrim (light 29% ≪ 96%) | Sheet/dialog phủ scrim lên nền content khác + kit shot bo góc; danh sách deck + language pair seed khác kit | seed danh sách khớp kit / contentMask nền |
| `overflow-menu` | 35.2% | 95.9% | Nền sau scrim (light 35% ≪ 96%) | Sheet/dialog phủ scrim lên nền content khác + kit shot bo góc; danh sách deck + language pair seed khác kit | seed danh sách khớp kit / contentMask nền |
| `pair-picker` | 35.4% | 95.5% | Nền sau scrim (light 35% ≪ 96%) | Sheet/dialog phủ scrim lên nền content khác + kit shot bo góc; danh sách deck + language pair seed khác kit | seed danh sách khớp kit / contentMask nền |
| `play-sheet` | 45.0% | 94.8% | Nền sau scrim (light 45% ≪ 95%) | Sheet/dialog phủ scrim lên nền content khác + kit shot bo góc; danh sách deck + language pair seed khác kit | seed danh sách khớp kit / contentMask nền |
| `drawer` | 85.7% | 94.9% | Text nội dung + AA | Nhãn/số seed khác + AA; danh sách deck + language pair seed khác kit | seed danh sách khớp kit / contentMask nền |
| `loaded` | 89.0% | 86.1% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); danh sách deck + language pair seed khác kit | seed danh sách khớp kit / contentMask nền |
| `empty` | 89.7% | 88.1% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); danh sách deck + language pair seed khác kit | seed danh sách khớp kit / contentMask nền |
| `search-active` | 95.1% | 92.5% | Text nội dung + AA | Nhãn/số seed khác + AA; danh sách deck + language pair seed khác kit | seed danh sách khớp kit / contentMask nền |
| `error` | 94.3% | 93.7% | Text nội dung + AA | Nhãn/số seed khác + AA; danh sách deck + language pair seed khác kit | seed danh sách khớp kit / contentMask nền |
| `loading` | 98.6% | 98.4% | Cạnh chữ / anti-alias | Khác renderer (Skia vs trình duyệt) — không lệch cấu trúc | Không cần (nhiễu AA) |

## `settings` — avg 82.5%

| state | light | dark | lệch ở đâu | lý do lệch | phương án chỉnh sửa |
|---|--:|--:|---|---|---|
| `value-picker` | 33.4% | 94.8% | Nền sau scrim (light 33% ≪ 95%) | Sheet/dialog phủ scrim lên nền content khác + kit shot bo góc; danh sách row seed khác; nhóm setting v1 khác kit vài mục | align seed / quyết định mục v1 |
| `group-expanded` | 92.1% | 89.4% | Text nội dung + AA | Nhãn/số seed khác + AA; danh sách row seed khác; nhóm setting v1 khác kit vài mục | align seed / quyết định mục v1 |
| `loaded` | 92.6% | 92.4% | Text nội dung + AA | Nhãn/số seed khác + AA; danh sách row seed khác; nhóm setting v1 khác kit vài mục | align seed / quyết định mục v1 |

## `game-picker` — avg 82.6%

| state | light | dark | lệch ở đâu | lý do lệch | phương án chỉnh sửa |
|---|--:|--:|---|---|---|
| `scope-dropdown` | 37.2% | 94.0% | Nền sau scrim (light 37% ≪ 94%) | Sheet/dialog phủ scrim lên nền content khác + kit shot bo góc; danh sách deck/scope seed khác | seed danh sách khớp / mask nền overlay |
| `not-enough` | 92.9% | 88.0% | Text nội dung + AA | Nhãn/số seed khác + AA; danh sách deck/scope seed khác | seed danh sách khớp / mask nền overlay |
| `default` | 90.8% | 92.6% | Text nội dung + AA | Nhãn/số seed khác + AA; danh sách deck/scope seed khác | seed danh sách khớp / mask nền overlay |

## `dashboard` — avg 82.9%

| state | light | dark | lệch ở đâu | lý do lệch | phương án chỉnh sửa |
|---|--:|--:|---|---|---|
| `empty` | 78.6% | 77.1% | Toàn màn (khác thiết kế cũ) | shot cũ (not-studied) → đã RE-EXPORT sang onboarding (#248); phần dư là lời chào/ngày + AA | Đã xử lý (shot mới); dư là content/AA — không cần thêm |
| `loaded` | 79.9% | 80.8% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); lời chào/tên/ngày/streak seed khác kit (Flutter 'Good morning · Fri 3 Jul' vs kit 'Good evening, Linh · Sat 27 Jun') | contentMask vùng lời chào + ngày, hoặc seed cố định trùng kit |
| `goal-met` | 80.5% | 81.0% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); lời chào/tên/ngày/streak seed khác kit (Flutter 'Good morning · Fri 3 Jul' vs kit 'Good evening, Linh · Sat 27 Jun') | contentMask vùng lời chào + ngày, hoặc seed cố định trùng kit |
| `streak-reset` | 81.0% | 81.5% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); lời chào/tên/ngày/streak seed khác kit (Flutter 'Good morning · Fri 3 Jul' vs kit 'Good evening, Linh · Sat 27 Jun') | contentMask vùng lời chào + ngày, hoặc seed cố định trùng kit |
| `loading` | 92.9% | 96.0% | Text nội dung + AA | Nhãn/số seed khác + AA; lời chào/tên/ngày/streak seed khác kit (Flutter 'Good morning · Fri 3 Jul' vs kit 'Good evening, Linh · Sat 27 Jun') | contentMask vùng lời chào + ngày, hoặc seed cố định trùng kit |

## `study-session` — avg 83.6%

| state | light | dark | lệch ở đâu | lý do lệch | phương án chỉnh sửa |
|---|--:|--:|---|---|---|
| `answer-save-error` | 23.7% | 86.6% | Nền sau scrim (light 24% ≪ 87%) | Sheet/dialog phủ scrim lên nền content khác + kit shot bo góc; từ Hàn (학교/사과…) nay đã render đúng; nội dung stage giữa phiên seed khác | chấp nhận (content) — font CJK đã fix; align seed nếu muốn |
| `exit` | 26.8% | 89.9% | Nền sau scrim (light 27% ≪ 90%) | Sheet/dialog phủ scrim lên nền content khác + kit shot bo góc; từ Hàn (학교/사과…) nay đã render đúng; nội dung stage giữa phiên seed khác | chấp nhận (content) — font CJK đã fix; align seed nếu muốn |
| `stage4-recall` | 82.0% | 84.4% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); từ Hàn (학교/사과…) nay đã render đúng; nội dung stage giữa phiên seed khác | chấp nhận (content) — font CJK đã fix; align seed nếu muốn |
| `stage1-review` | 82.4% | 84.5% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); từ Hàn (학교/사과…) nay đã render đúng; nội dung stage giữa phiên seed khác | chấp nhận (content) — font CJK đã fix; align seed nếu muốn |
| `due-review` | 90.0% | 83.3% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); từ Hàn (학교/사과…) nay đã render đúng; nội dung stage giữa phiên seed khác | chấp nhận (content) — font CJK đã fix; align seed nếu muốn |
| `relearn` | 94.1% | 86.4% | Text nội dung + AA | Nhãn/số seed khác + AA; từ Hàn (학교/사과…) nay đã render đúng; nội dung stage giữa phiên seed khác | chấp nhận (content) — font CJK đã fix; align seed nếu muốn |
| `stage5-typing` | 90.2% | 91.5% | Text nội dung + AA | Nhãn/số seed khác + AA; từ Hàn (학교/사과…) nay đã render đúng; nội dung stage giữa phiên seed khác | chấp nhận (content) — font CJK đã fix; align seed nếu muốn |
| `resume-error` | 93.7% | 93.0% | Text nội dung + AA | Nhãn/số seed khác + AA; từ Hàn (학교/사과…) nay đã render đúng; nội dung stage giữa phiên seed khác | chấp nhận (content) — font CJK đã fix; align seed nếu muốn |
| `stage3-choice` | 95.6% | 97.0% | Cạnh chữ / anti-alias | Khác renderer (Skia vs trình duyệt) — không lệch cấu trúc | Không cần (nhiễu AA) |
| `stage2-matching` | 98.2% | 97.9% | Cạnh chữ / anti-alias | Khác renderer (Skia vs trình duyệt) — không lệch cấu trúc | Không cần (nhiễu AA) |

## `reminder` — avg 85.7%

| state | light | dark | lệch ở đâu | lý do lệch | phương án chỉnh sửa |
|---|--:|--:|---|---|---|
| `time-picker` | 40.5% | 95.6% | Nền sau scrim (light 40% ≪ 96%) | Sheet/dialog phủ scrim lên nền content khác + kit shot bo góc; chips ngày đã fix inline; nhãn giờ seed khác nhẹ | chấp nhận (content nhẹ) |
| `on` | 93.3% | 93.2% | Text nội dung + AA | Nhãn/số seed khác + AA; chips ngày đã fix inline; nhãn giờ seed khác nhẹ | chấp nhận (content nhẹ) |
| `off` | 95.1% | 96.2% | Text nội dung + AA | Nhãn/số seed khác + AA; chips ngày đã fix inline; nhãn giờ seed khác nhẹ | chấp nhận (content nhẹ) |

## `import` — avg 89.0%

| state | light | dark | lệch ở đâu | lý do lệch | phương án chỉnh sửa |
|---|--:|--:|---|---|---|
| `dup-warning` | 85.7% | 86.2% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); nội dung dán/mapping/preview seed khác | align seed hoặc chấp nhận |
| `preview` | 86.3% | 87.2% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); nội dung dán/mapping/preview seed khác | align seed hoặc chấp nhận |
| `source` | 88.7% | 90.0% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); nội dung dán/mapping/preview seed khác | align seed hoặc chấp nhận |
| `done` | 91.9% | 90.6% | Text nội dung + AA | Nhãn/số seed khác + AA; nội dung dán/mapping/preview seed khác | align seed hoặc chấp nhận |
| `mapping` | 91.3% | 92.4% | Text nội dung + AA | Nhãn/số seed khác + AA; nội dung dán/mapping/preview seed khác | align seed hoặc chấp nhận |

## `game-recall` — avg 89.4%

| state | light | dark | lệch ở đâu | lý do lệch | phương án chỉnh sửa |
|---|--:|--:|---|---|---|
| `forgot` | 88.0% | 85.2% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); từ prompt seed khác; feedback tone | chấp nhận (content) |
| `before-reveal` | 87.5% | 87.8% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); từ prompt seed khác; feedback tone | chấp nhận (content) |
| `remembered` | 88.9% | 87.9% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); từ prompt seed khác; feedback tone | chấp nhận (content) |
| `complete` | 91.6% | 90.2% | Text nội dung + AA | Nhãn/số seed khác + AA; từ prompt seed khác; feedback tone | chấp nhận (content) |
| `revealed` | 93.2% | 93.7% | Text nội dung + AA | Nhãn/số seed khác + AA; từ prompt seed khác; feedback tone | chấp nhận (content) |

## `statistics` — avg 89.4%

| state | light | dark | lệch ở đâu | lý do lệch | phương án chỉnh sửa |
|---|--:|--:|---|---|---|
| `loaded` | 82.3% | 84.0% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); heatmap seed chỉ 5 ngày → thưa vs kit dày; số liệu seed khác | seed hoạt động ~14 tuần cho heatmap dày khớp kit |
| `scope-switch` | 82.3% | 84.0% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); heatmap seed chỉ 5 ngày → thưa vs kit dày; số liệu seed khác | seed hoạt động ~14 tuần cho heatmap dày khớp kit |
| `insufficient` | 96.0% | 93.7% | Text nội dung + AA | Nhãn/số seed khác + AA; heatmap seed chỉ 5 ngày → thưa vs kit dày; số liệu seed khác | seed hoạt động ~14 tuần cho heatmap dày khớp kit |
| `loading` | 95.5% | 97.6% | Cạnh chữ / anti-alias | Khác renderer (Skia vs trình duyệt) — không lệch cấu trúc | Không cần (nhiễu AA) |

## `theme` — avg 90.0%

| state | light | dark | lệch ở đâu | lý do lệch | phương án chỉnh sửa |
|---|--:|--:|---|---|---|
| `accent-size` | 88.2% | 89.7% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); 6 accent đã thêm khớp kit; preview card content seed khác | chấp nhận (content) |
| `light` | 89.9% | 91.0% | Text nội dung + AA | Nhãn/số seed khác + AA; 6 accent đã thêm khớp kit; preview card content seed khác | chấp nhận (content) |
| `dark` | 89.9% | 91.0% | Text nội dung + AA | Nhãn/số seed khác + AA; 6 accent đã thêm khớp kit; preview card content seed khác | chấp nhận (content) |

## `game-mc` — avg 91.4%

| state | light | dark | lệch ở đâu | lý do lệch | phương án chỉnh sửa |
|---|--:|--:|---|---|---|
| `wrong` | 89.2% | 87.9% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); prompt + đáp án seed khác | chấp nhận (content) |
| `correct` | 90.5% | 89.5% | Text nội dung + AA | Nhãn/số seed khác + AA; prompt + đáp án seed khác | chấp nhận (content) |
| `complete` | 91.4% | 90.1% | Text nội dung + AA | Nhãn/số seed khác + AA; prompt + đáp án seed khác | chấp nhận (content) |
| `waiting` | 96.7% | 95.9% | Cạnh chữ / anti-alias | Khác renderer (Skia vs trình duyệt) — không lệch cấu trúc | Không cần (nhiễu AA) |

## `export` — avg 91.4%

| state | light | dark | lệch ở đâu | lý do lệch | phương án chỉnh sửa |
|---|--:|--:|---|---|---|
| `config` | 86.3% | 87.3% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); giá trị form/scope/format seed khác | align seed hoặc chấp nhận (AA) |
| `done` | 90.1% | 89.0% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); giá trị form/scope/format seed khác | align seed hoặc chấp nhận (AA) |
| `exporting` | 97.5% | 98.4% | Cạnh chữ / anti-alias | Khác renderer (Skia vs trình duyệt) — không lệch cấu trúc | Không cần (nhiễu AA) |

## `flashcard-editor` — avg 91.9%

| state | light | dark | lệch ở đâu | lý do lệch | phương án chỉnh sửa |
|---|--:|--:|---|---|---|
| `duplicate` | 90.5% | 87.6% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); giá trị field (term/meaning) seed khác; gender chips đã fix flow inline | align seed / chấp nhận AA |
| `validation` | 91.5% | 91.8% | Text nội dung + AA | Nhãn/số seed khác + AA; giá trị field (term/meaning) seed khác; gender chips đã fix flow inline | align seed / chấp nhận AA |
| `audio` | 93.2% | 91.9% | Text nội dung + AA | Nhãn/số seed khác + AA; giá trị field (term/meaning) seed khác; gender chips đã fix flow inline | align seed / chấp nhận AA |
| `multi-meaning` | 93.3% | 92.0% | Text nội dung + AA | Nhãn/số seed khác + AA; giá trị field (term/meaning) seed khác; gender chips đã fix flow inline | align seed / chấp nhận AA |
| `edit` | 93.3% | 92.0% | Text nội dung + AA | Nhãn/số seed khác + AA; giá trị field (term/meaning) seed khác; gender chips đã fix flow inline | align seed / chấp nhận AA |
| `create` | 93.4% | 92.1% | Text nội dung + AA | Nhãn/số seed khác + AA; giá trị field (term/meaning) seed khác; gender chips đã fix flow inline | align seed / chấp nhận AA |

## `player` — avg 92.8%

| state | light | dark | lệch ở đâu | lý do lệch | phương án chỉnh sửa |
|---|--:|--:|---|---|---|
| `end` | 90.2% | 89.2% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); nội dung media/thẻ seed khác | chấp nhận (content) |
| `speed` | 93.1% | 94.5% | Text nội dung + AA | Nhãn/số seed khác + AA; nội dung media/thẻ seed khác | chấp nhận (content) |
| `paused` | 93.2% | 94.7% | Text nội dung + AA | Nhãn/số seed khác + AA; nội dung media/thẻ seed khác | chấp nhận (content) |
| `playing` | 93.2% | 94.7% | Text nội dung + AA | Nhãn/số seed khác + AA; nội dung media/thẻ seed khác | chấp nhận (content) |

## `study-result` — avg 93.1%

| state | light | dark | lệch ở đâu | lý do lệch | phương án chỉnh sửa |
|---|--:|--:|---|---|---|
| `goal-met` | 89.7% | 85.5% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); số liệu kết quả (words/min/streak) seed khác | chấp nhận (content số) |
| `goal-missed` | 91.1% | 86.3% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); số liệu kết quả (words/min/streak) seed khác | chấp nhận (content số) |
| `finalize-error` | 92.7% | 91.2% | Text nội dung + AA | Nhãn/số seed khác + AA; số liệu kết quả (words/min/streak) seed khác | chấp nhận (content số) |
| `many-wrong` | 92.8% | 92.5% | Text nội dung + AA | Nhãn/số seed khác + AA; số liệu kết quả (words/min/streak) seed khác | chấp nhận (content số) |
| `standard` | 93.9% | 94.0% | Text nội dung + AA | Nhãn/số seed khác + AA; số liệu kết quả (words/min/streak) seed khác | chấp nhận (content số) |
| `finalizing` | 98.1% | 98.4% | Cạnh chữ / anti-alias | Khác renderer (Skia vs trình duyệt) — không lệch cấu trúc | Không cần (nhiễu AA) |
| `retry-finalize` | 98.2% | 98.4% | Cạnh chữ / anti-alias | Khác renderer (Skia vs trình duyệt) — không lệch cấu trúc | Không cần (nhiễu AA) |

## `review` — avg 94.0%

| state | light | dark | lệch ở đâu | lý do lệch | phương án chỉnh sửa |
|---|--:|--:|---|---|---|
| `end` | 90.6% | 89.3% | Khối nội dung chính | Seed khác đáng kể (text/số/layout theo dữ liệu); nội dung thẻ seed khác | chấp nhận (content) |
| `editing` | 93.0% | 94.7% | Text nội dung + AA | Nhãn/số seed khác + AA; nội dung thẻ seed khác | chấp nhận (content) |
| `audio` | 94.9% | 96.5% | Text nội dung + AA | Nhãn/số seed khác + AA; nội dung thẻ seed khác | chấp nhận (content) |
| `browsing` | 96.0% | 96.7% | Cạnh chữ / anti-alias | Khác renderer (Skia vs trình duyệt) — không lệch cấu trúc | Không cần (nhiễu AA) |

## `game-typing` — avg 94.1%

| state | light | dark | lệch ở đâu | lý do lệch | phương án chỉnh sửa |
|---|--:|--:|---|---|---|
| `complete` | 91.8% | 90.5% | Text nội dung + AA | Nhãn/số seed khác + AA; từ prompt + input seed khác | chấp nhận (content) |
| `hint` | 93.3% | 93.4% | Text nội dung + AA | Nhãn/số seed khác + AA; từ prompt + input seed khác | chấp nhận (content) |
| `correct` | 94.2% | 95.6% | Text nội dung + AA | Nhãn/số seed khác + AA; từ prompt + input seed khác | chấp nhận (content) |
| `waiting` | 94.2% | 94.2% | Text nội dung + AA | Nhãn/số seed khác + AA; từ prompt + input seed khác | chấp nhận (content) |
| `wrong` | 94.4% | 94.8% | Text nội dung + AA | Nhãn/số seed khác + AA; từ prompt + input seed khác | chấp nhận (content) |
| `typing` | 96.3% | 96.9% | Cạnh chữ / anti-alias | Khác renderer (Skia vs trình duyệt) — không lệch cấu trúc | Không cần (nhiễu AA) |

## `game-matching` — avg 95.1%

| state | light | dark | lệch ở đâu | lý do lệch | phương án chỉnh sửa |
|---|--:|--:|---|---|---|
| `complete` | 91.1% | 89.8% | Text nội dung + AA | Nhãn/số seed khác + AA; cặp từ prompt seed khác (Latin means/term) | chấp nhận (content) |
| `correct` | 96.8% | 92.0% | Text nội dung + AA | Nhãn/số seed khác + AA; cặp từ prompt seed khác (Latin means/term) | chấp nhận (content) |
| `wrong` | 96.3% | 93.5% | Text nội dung + AA | Nhãn/số seed khác + AA; cặp từ prompt seed khác (Latin means/term) | chấp nhận (content) |
| `selected` | 96.9% | 95.3% | Cạnh chữ / anti-alias | Khác renderer (Skia vs trình duyệt) — không lệch cấu trúc | Không cần (nhiễu AA) |
| `playing` | 97.5% | 96.9% | Cạnh chữ / anti-alias | Khác renderer (Skia vs trình duyệt) — không lệch cấu trúc | Không cần (nhiễu AA) |
| `almost` | 97.7% | 97.3% | Cạnh chữ / anti-alias | Khác renderer (Skia vs trình duyệt) — không lệch cấu trúc | Không cần (nhiễu AA) |

## `search` — avg 96.1%

| state | light | dark | lệch ở đâu | lý do lệch | phương án chỉnh sửa |
|---|--:|--:|---|---|---|
| `empty-recent` | 96.4% | 94.6% | Text nội dung + AA | Nhãn/số seed khác + AA; query + kết quả seed khác (con mèo/chó vs kit 하다…) | chấp nhận (content) — đã rất khớp |
| `no-results` | 96.5% | 95.0% | Text nội dung + AA | Nhãn/số seed khác + AA; query + kết quả seed khác (con mèo/chó vs kit 하다…) | chấp nhận (content) — đã rất khớp |
| `results` | 95.3% | 95.6% | Text nội dung + AA | Nhãn/số seed khác + AA; query + kết quả seed khác (con mèo/chó vs kit 하다…) | chấp nhận (content) — đã rất khớp |
| `loading` | 96.8% | 96.2% | Cạnh chữ / anti-alias | Khác renderer (Skia vs trình duyệt) — không lệch cấu trúc | Không cần (nhiễu AA) |
| `filtered` | 97.0% | 97.2% | Cạnh chữ / anti-alias | Khác renderer (Skia vs trình duyệt) — không lệch cấu trúc | Không cần (nhiễu AA) |
