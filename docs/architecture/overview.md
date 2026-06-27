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

Hợp đồng thư mục do **`tool/flutter_arch/architecture.json`** định nghĩa và
`node tool/flutter_arch/run.mjs init` sinh ra; theme nằm ở `core/theme` (xem
`tool/tool.config.json`). Giữ doc này khớp với tool.

```
lib/
  app/
    bootstrap/       # khởi động app (app_bootstrap.dart) — chỉ wiring, không business
    di/              # composition root: ProviderScope + override
    router/          # route_paths.dart, app_router.dart (hằng số route)
  core/
    constants/       # hằng nền tảng dùng chung (không phải copy l10n)
    error/           # Failure taxonomy (docs/contracts/error-contract.md)
    logging/         # log site (docs/quality/observability-contract.md)
    theme/           # Material 3 + design token (mx_colors.dart, app_theme.dart)
    util/
  domain/
    entities/        # Card, Deck, Folder, SrsState... (thuần, không phụ thuộc framework)
    models/          # model/read-model thuần domain
    repositories/    # interface (port)
    services/        # domain service (logic thuần qua nhiều entity)
    types/           # Result + enum/value object dùng chung (docs/contracts/types-catalog.md)
    usecases/<area>/ # 1 use case = 1 file
  data/
    datasources/
      local/         # Drift: connection, daos, drift, migrations, preferences (docs/database/schema-contract.md)
    mappers/         # ánh xạ DTO/model ↔ entity
    repositories/    # repository impl (implements domain/repositories)
    services/        # service phía data (vd đồng bộ remote — account-sync, W10)
  presentation/
    features/<area>/ # routes/ · screens/ · viewmodels/ (@riverpod) · widgets/
    shared/          # async, dialogs, feedback, hooks, layouts, navigation, sort, widgets/{...}
  l10n/              # ARB + generated
```

Khớp với trigger-map trong `CLAUDE.md` (lib/** domain/usecase/data/presentation).
Sub-domain nghiệp vụ dưới `domain/` và folder per-feature là **nội dung**, thêm theo
từng feature (`node tool/flutter_arch/run.mjs feature <name>`).

## Module boundaries

Mỗi feature là một lát dọc qua domain/usecases + presentation/features; dùng chung core + data.

| Module (feature) | Sở hữu | Phụ thuộc |
| --- | --- | --- |
| flashcard | Thẻ + nghĩa, cờ ẩn | core |
| srs | Lập lịch 8-box Leitner | flashcard |
| study | 5 lối vào, chuỗi NewLearn 5 chặng | srs, game, flashcard |
| game | 4 game luyện (Ghép đôi/Đoán/Nhớ lại/Điền) | flashcard |
| deck | Cây bộ thẻ lồng nhau (chứa thẻ + bộ thẻ con) | flashcard |
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
