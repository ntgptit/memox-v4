# Types catalog — MemoX V4

Shared enums and value objects used across layers. Define once; reference by name.

## Enums

| Enum | Values | Used by |
| --- | --- | --- |
| `CardStatus` | new · learning · due · mastered · hidden | flashcard, srs, search |
| `LastResult` | correct · wrong | srs (`srs_state.last_result`, **lưu**) |
| `GameType` | matching · multipleChoice · recall · typing | game (Ghép đôi/Đoán/Nhớ lại/Điền) |
| `StudyEntry` | dueReview · newLearn · review · game · player | study (menu Play) |
| `SortBy` | alphabet · createdAt · lastStudied | deck |
| `SortDirection` | asc · desc | deck |
| `GameScope` | spaced · all · notMastered | game ("Chế độ lặp lại giãn cách") |
| `ImportFormat` | csv · excel · clipboard | import-export |
| `Separator` | tab · comma · semicolon · custom | import-export |
| `ThemeMode` | light · dark · system | personalization |

`CardStatus` là **suy ra** từ `srs_state.box` + cờ `hidden` (không lưu riêng).
Enum **lưu** (`LastResult`) phải có encoding ổn định trong `docs/database/schema-contract.md`.

## Value objects

| Type | Shape | Invariants |
| --- | --- | --- |
| `CardMeaning` | lang + text (văn bản tự do) | text không rỗng |
| `LeitnerBox` | int 0..8 | 0 = mới; chuyển: Đúng +1 (trần 8), Sai −1 (sàn 1) |
| `DailyGoal` | minutes? / words? | ≥1 trường > 0 |
| `Streak` | int ≥ 0 | reset 0 khi một ngày không đạt |
| `Reminder` | time + weekdays | time hợp lệ; ≥1 thứ trong tuần |
| `BoxInterval` | box → số ngày | 1·3·7·14·30·60·120; ô8 = đã thuộc (không xếp lịch) |

## Rules

- A persisted enum's stored representation never changes silently — that's a migration.
- Prefer a value object over a primitive when there are invariants to protect.

## Related

- `docs/contracts/error-contract.md` — failure types
- `docs/database/schema-contract.md` — persisted enum encodings
