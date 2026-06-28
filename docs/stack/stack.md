# Stack — MemoX V4

Detected/seeded stack: **Flutter / Dart 3** (id: `flutter`, source root: `lib/`).

Thêm dependency cần **duyệt** (CLAUDE.md hard rule). Phiên bản chính xác chốt khi
hoàn thiện `pubspec.yaml`.

**Đã trong `pubspec.yaml` (W1 + S0):** `flutter_riverpod ^3.3.1` + `riverpod_annotation ^4.0.2`,
`go_router ^14.6.0`, `drift >=2.28.1 <2.34.0` + `sqlite3_flutter_libs` + `path` +
`path_provider`, và i18n `flutter_localizations` (sdk) + `intl` (ghim theo
`flutter_localizations`). Codegen: `build_runner` + `drift_dev >=2.28.1 <2.34.0` +
`riverpod_generator ^4.0.3`. Các package còn lại (mocktail, sync…) thêm khi feature cần.

> **Riverpod codegen ĐÃ BẬT (nâng Riverpod 2→3):** Lúc S0, `riverpod_generator` (trần
> `analyzer ≤9`) xung đột với `drift_dev 2.34` (`analyzer ≥10`) — `flutter pub get` thất
> bại, không có vùng giao. Cách gỡ: **ghim `drift`/`drift_dev` ở `>=2.28.1 <2.34.0`**
> (vẫn `source_gen ^3` nhưng `analyzer 9`, tương thích) + nâng `flutter_riverpod` lên `^3`
> với `riverpod_annotation ^4` / `riverpod_generator ^4`. Tổ hợp resolve: drift 2.31 +
> riverpod 3.3.1 + generator 4.0.3 (analyzer 9.0.0). **Ràng buộc:** không nâng `drift_dev`
> ≥2.34 cho tới khi `riverpod_generator` hỗ trợ `analyzer ≥10`. **Toàn bộ** notifier +
> `Provider` DI khai báo bằng `@riverpod` (chạy `dart run build_runner build`; `*.g.dart`
> được commit). Tên provider sinh ra **bỏ hậu tố `Notifier`** (vd `libraryProvider`). Riverpod
> 3: `AsyncValue.valueOrNull` → `.value`; `Override` (overrides) export ở
> `package:flutter_riverpod/misc.dart`.

| Concern | Choice | Version | Notes |
| --- | --- | --- | --- |
| Language / runtime | Dart | 3.x | null-safety, sealed/pattern |
| Framework | Flutter | stable | Material 3 |
| State management | Riverpod 3 | `flutter_riverpod ^3.3.1` + `riverpod_annotation ^4.0.2` | `@riverpod` codegen (generator `^4.0.3`); **toàn bộ** notifier + DI dùng codegen |
| Persistence | Drift (SQLite) | `drift >=2.28.1 <2.34.0` | DB cục bộ; ghim <2.34 để analyzer 9 tương thích riverpod_generator |
| Routing | go_router | `go_router ^14.6.0` | hằng ở `route_paths.dart` |
| i18n | flutter_localizations + ARB | — | `gen_l10n` |
| Testing | flutter_test + mocktail | — | Drift in-memory |
| Lint / format | flutter_lints + `dart format` | — | `analysis_options.yaml` |

## Verification chain

The build/test commands for this stack live in `tool/verify/verify.config.json`
and run only through `node tool/verify/run.mjs`. Update that file, not ad-hoc scripts.

## Related

- `docs/architecture/overview.md` — the layering this stack implements
- `docs/testing/test-strategy.md` — how this stack is verified
