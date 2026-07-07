# Visual parity — matching & lệch theo từng state

> **Nguồn:** regen goldens cục bộ (Windows) sau khi merge #250 + #251, diff qua
> `tool/visual-diff/diff.mjs --threshold 0.2` vs kit shots đã commit. 112 states ×
> light/dark = 224 so sánh. Số CI ubuntu sẽ lệch nhẹ (font/AA cross-renderer) — sẽ
> chốt khi reseed `baseline.json`.
> **% matching = 100 − mismatch** (perceptual YIQ). Ngưỡng đổi 0.1 → **0.2** để hấp
> thụ AA cross-renderer (kit = Blink/CSS, golden = Skia — khác renderer là lệch bất
> khả kháng, không phải bug).
> **Tổng thể: mean 92.9% match** (21 screens).
> Quy ước đọc: `light ≪ dark` ⇒ overlay/scrim phủ nền content khác; `light ≈ dark`
> mà thấp ⇒ content/seed khác; `≥ 96%` ⇒ chỉ còn nhiễu AA.

## Đã fix trong đợt này (#250, #251)

- **Bottom nav (shell)** — 4 tab (dashboard/library/statistics/settings) trước render
  trần (không nav) vs kit shot có nav. Đã wire kit `MxBottomNav` vào `_ShellScaffold`
  (thay `NavigationBar`) + render golden tab trong shell. **Đây là đòn bẩy lớn nhất**:
  statistics·loaded 82.6→88.0, kéo cả 4 tab lên cùng lúc (#251).
- **Heatmap statistics** — seed hoạt động theo đúng công thức kit
  `[0.08,0.25,0.45,0.7,1][(w*7+d*3)%5]` → lịch nhiệt khớp từng ô (#250).
- **Hạ tầng inject stats** — `FakeStore.deckStats` override → golden seed đúng số kit
  (chỉ giúp khi lệch là *con số*, không giúp khi lệch là *widget*).
- Trước đó: chip/sheet-menu icons, add-title, icon font, Korean font, 6 accents,
  play-audio, shot dashboard--empty cũ.

## Gap còn lại đáng làm (kit-first UI, không seed được)

1. **`SubDeckCard` ≠ kit DeckRow** (deck-detail): meta "N decks · N words" (Flutter
   "N words · N due"), badge (kit pill due / ✓ mastered vs Flutter vòng đếm), icon
   folder (`style`/layers), tiến độ. → gap chính của deck-detail·loaded.
2. **drawer**: kit có FAQ / Email us / Sync — Flutter bỏ (v1 không backend). Quyết định
   scope v1 (Sync defer; FAQ/Email có thể link tĩnh).
3. **dashboard greeting/seed**: tên "Linh" + avatar "LT" + ngày + streak kit ≠ seed
   Flutter → content, cân nhắc contentMask hoặc seed cố định.
4. **statistics streak 12/28**: sample kit tự mâu thuẫn (heatmap không thể sinh streak
   12) → không khớp đồng thời; đã ưu tiên heatmap (mảng lớn hơn).

---

## `drawer` — avg 81.9%

| state | light | dark |
|---|--:|--:|
| `remove-language` | 28.8% | 93.7% |
| `open` | 86.4% | 95.4% |
| `add-language` | 90.9% | 96.0% |

- **Lệch:** `remove-language` light ≪ dark → sheet/scrim phủ nền; `open`/`add-language` là content.
- **Lý do:** danh sách nav; kit có FAQ/Email us/Sync mà Flutter bỏ (v1 không backend) + scrim + AA.
- **Phương án:** quyết định scope v1 (Sync cần backend → defer; FAQ/Email link tĩnh nếu muốn); nền overlay có thể contentMask.

## `dashboard` — avg 89.4% *(nav ✓)*

| state | light | dark |
|---|--:|--:|
| `empty` | 83.3% | 83.5% |
| `loaded` | 88.0% | 89.0% |
| `goal-met` | 88.5% | 89.3% |
| `streak-reset` | 88.9% | 89.7% |
| `loading` | 96.4% | 97.3% |

- **Lệch:** khối nội dung chính (lời chào/tên/ngày/streak/continue-deck).
- **Lý do:** seed khác kit ('Good morning · Fri 3 Jul' vs kit 'Good evening, Linh · Sat 27 Jun' + avatar "LT" + số continue-deck). `empty` thấp cả 2 theme = onboarding hero content nặng.
- **Phương án:** contentMask vùng greeting+ngày, hoặc seed cố định trùng kit; phần dư là AA.

## `deck-detail` — avg 90.1% *(màn push — KHÔNG có nav, đúng kit)*

| state | light | dark |
|---|--:|--:|
| `move` | 47.2% | 91.2% |
| `reset-confirm` | 75.0% | 89.5% |
| `deck-delete-confirm` | 75.4% | 89.9% |
| `delete-confirm` | 77.5% | 91.0% |
| `deck-menu` | 87.6% | 97.2% |
| `loaded` | 88.7% | 89.7% |
| `empty` | 90.8% | 90.6% |
| `card-actions` | 93.4% | 97.5% |
| `add-menu` | 93.5% | 97.0% |
| `error` | 96.2% | 96.4% |
| `no-results` | 97.2% | 97.2% |
| `search` | 97.5% | 97.7% |
| `loading` | 99.1% | 99.4% |

- **Lệch:** overlay (`move`/`*-confirm` light ≪ dark = scrim); `loaded`/`empty` = khối nội dung.
- **Lý do:** **`SubDeckCard` diverge kit DeckRow** (meta "N decks · N words", badge pill due/✓, icon folder) — gap chính; store đã seed 'Korean Basics' 2 sub-deck khớp kit; số sub-deck inject đúng (412/28/56%, 180/100%) nhưng format widget còn lệch.
- **Phương án:** **kit-first rework `SubDeckCard`** (meta/badge/icon/✓) — đòn bẩy lớn nhất còn lại; overlay nền chấp nhận scrim/AA.

## `study-session` — avg 90.7%

| state | light | dark |
|---|--:|--:|
| `exit` | 76.0% | 91.6% |
| `answer-save-error` | 77.3% | 89.7% |
| `stage4-recall` | 84.7% | 85.3% |
| `stage1-review` | 84.8% | 85.1% |
| `due-review` | 91.2% | 91.4% |
| `stage5-typing` | 91.8% | 92.3% |
| `resume-error` | 94.7% | 94.4% |
| `relearn` | 95.7% | 96.2% |
| `stage3-choice` | 97.0% | 97.7% |
| `stage2-matching` | 98.4% | 98.7% |

- **Lệch:** `exit`/`answer-save-error` light ≪ dark = scrim; các stage = content giữa phiên.
- **Lý do:** nội dung stage seed khác (từ Hàn 학교/사과… nay render đúng nhờ font CJK).
- **Phương án:** chấp nhận (content); align seed nếu muốn nâng thêm.

## `game-recall` — avg 90.9%

| state | light | dark |
|---|--:|--:|
| `before-reveal` | 88.3% | 88.5% |
| `forgot` | 89.1% | 89.1% |
| `remembered` | 90.3% | 90.4% |
| `complete` | 92.4% | 92.4% |
| `revealed` | 94.1% | 94.4% |

- **Lệch:** khối nội dung (prompt + feedback tone). **Lý do:** từ prompt seed khác. **Phương án:** chấp nhận (content).

## `import` — avg 91.2%

| state | light | dark |
|---|--:|--:|
| `dup-warning` | 87.3% | 86.9% |
| `preview` | 87.7% | 87.4% |
| `source` | 90.9% | 96.3% |
| `done` | 92.8% | 92.6% |
| `mapping` | 95.0% | 94.7% |

- **Lệch:** khối nội dung dán/mapping/preview. **Lý do:** nội dung seed khác. **Phương án:** align seed hoặc chấp nhận.

## `theme` — avg 91.4% *(6 accent ✓)*

| state | light | dark |
|---|--:|--:|
| `accent-size` | 90.5% | 90.8% |
| `dark` | 91.5% | 92.0% |
| `light` | 91.5% | 92.0% |

- **Lệch:** preview card content + AA. **Lý do:** 6 accent đã khớp kit; nội dung card preview seed khác. **Phương án:** chấp nhận (content/AA).

## `game-mc` — avg 92.5%

| state | light | dark |
|---|--:|--:|
| `wrong` | 89.8% | 89.9% |
| `correct` | 91.0% | 91.1% |
| `complete` | 92.2% | 92.3% |
| `waiting` | 96.9% | 97.1% |

- **Lệch:** prompt + đáp án seed khác. **Phương án:** chấp nhận (content).

## `export` — avg 93.1%

| state | light | dark |
|---|--:|--:|
| `config` | 89.8% | 89.5% |
| `done` | 91.1% | 91.2% |
| `exporting` | 98.2% | 98.7% |

- **Lệch:** giá trị form/scope/format seed khác. **Phương án:** align seed hoặc chấp nhận (AA).

## `statistics` — avg 93.2% *(nav ✓, heatmap ✓)*

| state | light | dark |
|---|--:|--:|
| `loaded` | 85.8% | 92.8% |
| `scope-switch` | 85.8% | 92.8% |
| `insufficient` | 96.2% | 95.9% |
| `loading` | 97.9% | 98.7% |

- **Lệch:** `loaded`/`scope-switch` light 85.8 vs dark 92.8 → light còn lệch ở weekly-bars + streak + overview (dark hấp thụ tốt hơn).
- **Lý do:** heatmap đã khớp; streak kit 12/28 không seed đồng thời được (sample kit mâu thuẫn); weekly-bars/overview số liệu seed khác.
- **Phương án:** có thể seed weekly-bars theo pattern kit (như heatmap) để nâng light; streak chấp nhận.

## `library` — avg 93.8% *(nav ✓)*

| state | light | dark |
|---|--:|--:|
| `sort-menu` | 82.6% | 97.0% |
| `drawer` | 85.9% | 94.7% |
| `overflow-menu` | 88.9% | 97.3% |
| `empty` | 90.6% | 90.1% |
| `loaded` | 93.7% | 93.8% |
| `play-sheet` | 94.2% | 96.3% |
| `pair-picker` | 94.8% | 97.0% |
| `error` | 95.4% | 95.5% |
| `search-active` | 95.5% | 95.5% |
| `loading` | 98.4% | 98.7% |

- **Lệch:** menu/sheet light ≪ dark = scrim; `loaded`/`empty` = danh sách deck + language pair seed khác.
- **Phương án:** seed danh sách khớp kit / contentMask nền overlay.

## `player` — avg 94.0%

| state | light | dark |
|---|--:|--:|
| `end` | 91.3% | 91.5% |
| `speed` | 94.5% | 95.0% |
| `paused` | 94.6% | 95.1% |
| `playing` | 94.6% | 95.1% |

- **Lệch:** nội dung media/thẻ seed khác. **Phương án:** chấp nhận (content).

## `settings` — avg 94.4% *(nav ✓)*

| state | light | dark |
|---|--:|--:|
| `group-expanded` | 93.8% | 93.3% |
| `loaded` | 94.2% | 93.9% |
| `value-picker` | 94.6% | 96.7% |

- **Lệch:** row seed + nhóm setting v1 khác kit vài mục + AA. **Phương án:** align seed / quyết định mục v1.

## `flashcard-editor` — avg 94.6%

| state | light | dark |
|---|--:|--:|
| `duplicate` | 93.3% | 92.9% |
| `validation` | 93.8% | 94.3% |
| `audio` | 95.1% | 94.7% |
| `edit` | 95.1% | 94.8% |
| `create` | 95.3% | 95.1% |
| `multi-meaning` | 95.3% | 94.9% |

- **Lệch:** giá trị field (term/meaning) seed khác + AA; gender chips đã fix inline. **Phương án:** align seed / chấp nhận AA.

## `study-result` — avg 94.8%

| state | light | dark |
|---|--:|--:|
| `goal-met` | 90.5% | 90.4% |
| `goal-missed` | 91.8% | 91.7% |
| `finalize-error` | 93.8% | 93.6% |
| `many-wrong` | 94.7% | 94.6% |
| `standard` | 95.7% | 95.7% |
| `finalizing` | 98.6% | 98.7% |
| `retry-finalize` | 98.6% | 98.7% |

- **Lệch:** số liệu kết quả (words/min/streak) seed khác. **Phương án:** chấp nhận (content số).

## `game-picker` — avg 95.1%

| state | light | dark |
|---|--:|--:|
| `scope-dropdown` | 93.7% | 97.3% |
| `default` | 94.4% | 94.4% |
| `not-enough` | 95.7% | 95.3% |

- **Lệch:** danh sách deck/scope seed khác + dropdown scrim. **Phương án:** seed danh sách khớp / chấp nhận.

## `review` — avg 95.4%

| state | light | dark |
|---|--:|--:|
| `end` | 91.6% | 91.5% |
| `editing` | 95.2% | 96.0% |
| `audio` | 96.8% | 97.3% |
| `browsing` | 96.9% | 97.5% |

- **Lệch:** nội dung thẻ seed khác + AA. **Phương án:** chấp nhận (content).

## `game-typing` — avg 95.4%

| state | light | dark |
|---|--:|--:|
| `complete` | 92.6% | 92.8% |
| `hint` | 94.3% | 96.6% |
| `waiting` | 94.7% | 97.1% |
| `wrong` | 95.6% | 95.5% |
| `correct` | 95.8% | 96.0% |
| `typing` | 97.1% | 97.3% |

- **Lệch:** từ prompt + input seed khác + AA. **Phương án:** chấp nhận (content).

## `game-matching` — avg 96.4%

| state | light | dark |
|---|--:|--:|
| `complete` | 91.9% | 92.0% |
| `wrong` | 96.6% | 96.6% |
| `correct` | 97.0% | 97.1% |
| `selected` | 97.2% | 97.3% |
| `playing` | 97.7% | 97.6% |
| `almost` | 97.8% | 98.2% |

- **Lệch:** `complete` = summary content; còn lại chỉ AA. **Phương án:** chấp nhận.

## `reminder` — avg 96.6% *(chips ngày ✓)*

| state | light | dark |
|---|--:|--:|
| `time-picker` | 95.7% | 97.2% |
| `on` | 96.0% | 96.4% |
| `off` | 97.2% | 97.3% |

- **Lệch:** nhãn giờ seed khác nhẹ + AA. **Phương án:** chấp nhận (đã rất khớp).

## `search` — avg 97.4%

| state | light | dark |
|---|--:|--:|
| `no-results` | 97.0% | 96.8% |
| `results` | 97.2% | 97.3% |
| `empty-recent` | 97.2% | 97.2% |
| `loading` | 97.8% | 97.8% |
| `filtered` | 97.9% | 98.2% |

- **Lệch:** chỉ AA (query/kết quả seed khác nhẹ). **Phương án:** không cần — đã rất khớp.
