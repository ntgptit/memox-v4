# Visual parity — matching & lệch theo từng state

> **Tự động sinh** bởi `node tool/visual-diff/parity-table.mjs` từ diff kit↔golden
> (`--threshold 0.2`). **KHÔNG sửa tay** phần bảng — sửa số ⇒ regen goldens
> rồi chạy lại script; sửa prose ⇒ sửa HEADER/NOTES trong script.
> Nguồn số: render cục bộ (Windows) — CI ubuntu lệch vài phần mười (AA cross-renderer),
> chốt khi reseed `baseline.json`. % matching = 100 − mismatch (perceptual YIQ).
> Quy ước: `light ≪ dark` ⇒ overlay/scrim; `light ≈ dark` mà thấp ⇒ content/seed;
> `≥ 96%` ⇒ chỉ nhiễu AA cross-renderer (bất khả kháng).

## Đòn bẩy đã áp dụng

- **Bottom nav (shell)** — kit `MxBottomNav` wired vào `_ShellScaffold`; golden 4 tab
  render trong shell (#251). Đòn bẩy lớn nhất — kéo cả dashboard/library/statistics/settings.
- **Heatmap statistics** — seed theo công thức kit `[0.08,0.25,0.45,0.7,1][(w*7+d*3)%5]` (#250).
- **Move picker (deck-detail)** — kit `Move to` radio list + Move button; sibling/current/sub-deck
  rows (#253) → move·light 47%→88%.
- **Hạ tầng inject stats** `FakeStore.deckStats` — chỉ giúp khi lệch là *con số*.

## Gap còn lại đáng làm (kit-first UI, không seed được)

1. **`SubDeckCard` ≠ kit DeckRow**: meta "N decks · N words", badge pill due/✓, icon folder → gap chính deck-detail·loaded.
2. **drawer**: kit có FAQ/Email/Sync — v1 không backend (quyết định scope).
3. **dashboard greeting**: tên "Linh"/avatar/ngày/streak seed khác (content).
4. **statistics streak 12/28 + weekly-bars**: sample kit tự mâu thuẫn / có thể seed weekly như heatmap.

**Tổng thể: mean 93.1% match** · 21 screens · 112 states (× light/dark).

---

## `drawer` — avg 81.9%

| state | light | dark |
|---|--:|--:|
| `remove-language` | 28.8% | 93.7% |
| `open` | 86.4% | 95.4% |
| `add-language` | 90.9% | 96.0% |

**Lệch:** `remove-language` scrim; `open`/`add-language` content. **Lý do:** kit có FAQ/Email/Sync mà v1 bỏ (không backend) + scrim + AA. **Phương án:** quyết định scope v1; nền overlay có thể mask.

## `dashboard` — avg 89.4%

| state | light | dark |
|---|--:|--:|
| `empty` | 83.3% | 83.5% |
| `loaded` | 88.0% | 89.0% |
| `goal-met` | 88.5% | 89.3% |
| `streak-reset` | 88.9% | 89.7% |
| `loading` | 96.4% | 97.3% |

**Lệch:** khối nội dung (greeting/tên/ngày/streak/continue-deck). **Lý do:** seed khác kit ("Linh"/avatar/số). `empty` = onboarding hero. **Phương án:** contentMask greeting+ngày hoặc seed cố định.

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

**Lệch:** `exit`/`answer-save-error` scrim; stage = content giữa phiên (từ Hàn đã render). **Phương án:** chấp nhận (content).

## `game-recall` — avg 90.9%

| state | light | dark |
|---|--:|--:|
| `before-reveal` | 88.3% | 88.5% |
| `forgot` | 89.1% | 89.1% |
| `remembered` | 90.3% | 90.4% |
| `complete` | 92.4% | 92.4% |
| `revealed` | 94.1% | 94.4% |

**Lệch:** content/seed khác kit + AA. **Phương án:** align seed hoặc chấp nhận (content).

## `import` — avg 91.2%

| state | light | dark |
|---|--:|--:|
| `dup-warning` | 87.3% | 86.9% |
| `preview` | 87.7% | 87.4% |
| `source` | 90.9% | 96.3% |
| `done` | 92.8% | 92.6% |
| `mapping` | 95.0% | 94.7% |

**Lệch:** content/seed khác kit + AA. **Phương án:** align seed hoặc chấp nhận (content).

## `theme` — avg 91.4%

| state | light | dark |
|---|--:|--:|
| `accent-size` | 90.5% | 90.8% |
| `dark` | 91.5% | 92.0% |
| `light` | 91.5% | 92.0% |

**Lệch:** preview card content + AA (6 accent đã khớp). **Phương án:** chấp nhận.

## `deck-detail` — avg 91.9%

| state | light | dark |
|---|--:|--:|
| `reset-confirm` | 75.0% | 89.5% |
| `deck-delete-confirm` | 75.4% | 89.9% |
| `delete-confirm` | 77.5% | 91.0% |
| `deck-menu` | 87.6% | 97.2% |
| `move` | 88.2% | 95.6% |
| `loaded` | 88.7% | 89.7% |
| `empty` | 90.8% | 90.6% |
| `card-actions` | 93.4% | 97.5% |
| `add-menu` | 93.5% | 97.0% |
| `error` | 96.2% | 96.4% |
| `no-results` | 97.2% | 97.2% |
| `search` | 97.5% | 97.7% |
| `loading` | 99.1% | 99.4% |

**Lệch:** overlay confirm (`*-confirm` scrim); `loaded` = **`SubDeckCard` ≠ kit DeckRow** (meta/badge/icon). Move đã fix (#253). **Phương án:** kit-first rework `SubDeckCard` — đòn bẩy chính còn lại.

## `game-mc` — avg 92.5%

| state | light | dark |
|---|--:|--:|
| `wrong` | 89.8% | 89.9% |
| `correct` | 91.0% | 91.1% |
| `complete` | 92.2% | 92.3% |
| `waiting` | 96.9% | 97.1% |

**Lệch:** content/seed khác kit + AA. **Phương án:** align seed hoặc chấp nhận (content).

## `export` — avg 93.1%

| state | light | dark |
|---|--:|--:|
| `config` | 89.8% | 89.5% |
| `done` | 91.1% | 91.2% |
| `exporting` | 98.2% | 98.7% |

**Lệch:** content/seed khác kit + AA. **Phương án:** align seed hoặc chấp nhận (content).

## `statistics` — avg 93.2%

| state | light | dark |
|---|--:|--:|
| `loaded` | 85.8% | 92.8% |
| `scope-switch` | 85.8% | 92.8% |
| `insufficient` | 96.2% | 95.9% |
| `loading` | 97.9% | 98.7% |

**Lệch:** `loaded`/`scope-switch` light < dark → weekly-bars + streak + overview. **Lý do:** heatmap đã khớp; streak 12/28 không seed đồng thời (sample kit mâu thuẫn). **Phương án:** seed weekly-bars theo pattern kit.

## `library` — avg 93.8%

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

**Lệch:** menu/sheet scrim; `loaded`/`empty` = danh sách deck + language pair seed khác. **Phương án:** seed danh sách khớp / mask nền.

## `player` — avg 94.0%

| state | light | dark |
|---|--:|--:|
| `end` | 91.3% | 91.5% |
| `speed` | 94.5% | 95.0% |
| `paused` | 94.6% | 95.1% |
| `playing` | 94.6% | 95.1% |

**Lệch:** content/seed khác kit + AA. **Phương án:** align seed hoặc chấp nhận (content).

## `settings` — avg 94.4%

| state | light | dark |
|---|--:|--:|
| `group-expanded` | 93.8% | 93.3% |
| `loaded` | 94.2% | 93.9% |
| `value-picker` | 94.6% | 96.7% |

**Lệch:** row seed + nhóm v1 khác kit + AA. **Phương án:** align seed / quyết định mục v1.

## `flashcard-editor` — avg 94.6%

| state | light | dark |
|---|--:|--:|
| `duplicate` | 93.3% | 92.9% |
| `validation` | 93.8% | 94.3% |
| `audio` | 95.1% | 94.7% |
| `edit` | 95.1% | 94.8% |
| `create` | 95.3% | 95.1% |
| `multi-meaning` | 95.3% | 94.9% |

**Lệch:** content/seed khác kit + AA. **Phương án:** align seed hoặc chấp nhận (content).

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

**Lệch:** content/seed khác kit + AA. **Phương án:** align seed hoặc chấp nhận (content).

## `game-picker` — avg 95.1%

| state | light | dark |
|---|--:|--:|
| `scope-dropdown` | 93.7% | 97.3% |
| `default` | 94.4% | 94.4% |
| `not-enough` | 95.7% | 95.3% |

**Lệch:** dropdown scrim + danh sách deck/scope seed khác. **Phương án:** seed khớp / chấp nhận.

## `review` — avg 95.4%

| state | light | dark |
|---|--:|--:|
| `end` | 91.6% | 91.5% |
| `editing` | 95.2% | 96.0% |
| `audio` | 96.8% | 97.3% |
| `browsing` | 96.9% | 97.5% |

**Lệch:** content/seed khác kit + AA. **Phương án:** align seed hoặc chấp nhận (content).

## `game-typing` — avg 95.4%

| state | light | dark |
|---|--:|--:|
| `complete` | 92.6% | 92.8% |
| `hint` | 94.3% | 96.6% |
| `waiting` | 94.7% | 97.1% |
| `wrong` | 95.6% | 95.5% |
| `correct` | 95.8% | 96.0% |
| `typing` | 97.1% | 97.3% |

**Lệch:** content/seed khác kit + AA. **Phương án:** align seed hoặc chấp nhận (content).

## `game-matching` — avg 96.4%

| state | light | dark |
|---|--:|--:|
| `complete` | 91.9% | 92.0% |
| `wrong` | 96.6% | 96.6% |
| `correct` | 97.0% | 97.0% |
| `selected` | 97.2% | 97.3% |
| `playing` | 97.7% | 97.6% |
| `almost` | 97.8% | 98.2% |

**Lệch:** content/seed khác kit + AA. **Phương án:** align seed hoặc chấp nhận (content).

## `reminder` — avg 96.6%

| state | light | dark |
|---|--:|--:|
| `time-picker` | 95.7% | 97.2% |
| `on` | 96.0% | 96.4% |
| `off` | 97.2% | 97.3% |

**Lệch:** nhãn giờ seed khác nhẹ + AA (chips ngày đã fix). **Phương án:** chấp nhận.

## `search` — avg 97.4%

| state | light | dark |
|---|--:|--:|
| `no-results` | 97.0% | 96.8% |
| `results` | 97.2% | 97.3% |
| `empty-recent` | 97.2% | 97.2% |
| `loading` | 97.8% | 97.8% |
| `filtered` | 97.9% | 98.2% |

**Lệch:** chỉ AA (query/kết quả seed khác nhẹ). **Phương án:** không cần.
