# Architecture overview — MemoX V4

## Layering

Kiến trúc đã chọn: **Clean Architecture phân tầng** + **Riverpod (annotation)** cho state. Phụ thuộc hướng vào trong:

```
presentation ─▶ domain ◀─ data
                 ▲
            (domain has no outward imports)
```

- **domain** — entities, use case contracts, repository interfaces. Imports nothing outward.
- **data** — repository implementations, data sources. Implements domain interfaces.
- **presentation** — UI + state. Depends on domain only; never imports data directly.

Dependencies point inward. Any reverse import is a hard-rule violation (CLAUDE.md).
Chuỗi gọi: **UseCase → Repository (interface) → DataSource (DAO/remote)**.

## Bố cục thư mục (lib/)

```
lib/
  app/
    router/          # route_paths.dart, app_router.dart (hằng số route)
    theme/           # design tokens, light/dark/system
    di/              # khởi tạo provider/DI
  core/
    error/           # Failure taxonomy (docs/contracts/error-contract.md)
    types/           # enum/value object dùng chung (docs/contracts/types-catalog.md)
    util/
  domain/
    entities/        # Card, Deck, Folder, SrsState... (thuần, không phụ thuộc framework)
    repositories/    # interface (port)
    usecases/<area>/ # 1 use case = 1 file
  data/
    models/          # DTO/model + ánh xạ entity
    datasources/
      local/         # Drift: app_database.dart, DAO (docs/database/schema-contract.md)
      remote/        # Google Drive sync (account-sync)
    repositories/    # repository impl (implements domain/repositories)
  presentation/
    features/<area>/
      screens/       # màn hình
      widgets/       # widget tái dùng nội bộ feature
      providers/     # Riverpod (annotation) — state cho UI
  l10n/              # ARB + generated
```

Khớp với trigger-map trong `CLAUDE.md` (lib/** domain/usecase/data/presentation) và
where-is (`docs/_generated/where-is.md`) — cột Source trỏ vào các thư mục này.

## Module boundaries

Mỗi feature là một lát dọc qua domain/usecases + presentation/features; dùng chung core + data.

| Module (feature) | Sở hữu | Phụ thuộc |
| --- | --- | --- |
| flashcard | Thẻ + nghĩa, cờ ẩn | core |
| srs | Lập lịch 8-box Leitner | flashcard |
| study | 5 lối vào, chuỗi NewLearn 5 chặng | srs, game, flashcard |
| game | 4 game luyện (Ghép đôi/Đoán/Nhớ lại/Điền) | flashcard |
| folder | Cây thư mục | core |
| deck | Bộ thẻ | folder, flashcard |
| search | Tìm theo term + nghĩa | flashcard |
| import-export | CSV/Excel/clipboard | deck, flashcard |
| statistics | Chỉ số học | srs, engagement |
| account-sync | Đồng bộ Google Drive | (data) |
| engagement | Hoạt động ngày / mục tiêu / streak | study |
| settings | Cài đặt, backup cục bộ | core |
| personalization | Theme | settings |

## Cross-cutting

- Error handling: see `docs/contracts/error-contract.md`.
- State management: see `docs/state/state-management-contract.md`.
- Persistence boundary: see `docs/database/storage-boundaries.md`.

## Non-negotiables

- One responsibility per class/file.
- No business logic in controllers/UI.
- No invented layers/factories beyond what this doc declares.

## Related

- `docs/business/index.md` — features that live in these layers
- `docs/state/state-management-contract.md` — how presentation state is produced
- `docs/database/storage-boundaries.md` — what persists where
- `docs/contracts/error-contract.md` — cross-cutting failures
