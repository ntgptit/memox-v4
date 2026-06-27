# Stack — MemoX V4

Detected/seeded stack: **Flutter / Dart 3** (id: `flutter`, source root: `lib/`).

Thêm dependency cần **duyệt** (CLAUDE.md hard rule). Phiên bản chính xác chốt khi
hoàn thiện `pubspec.yaml`.

**Đã trong `pubspec.yaml` (W1):** `flutter_riverpod ^2.6.1`, `go_router ^14.6.0`
(ghim theo major đã chốt ở bảng dưới). Các package còn lại (Drift, codegen, mocktail,
sync…) thêm khi feature tương ứng cần.

| Concern | Choice | Version | Notes |
| --- | --- | --- | --- |
| Language / runtime | Dart | 3.x | null-safety, sealed/pattern |
| Framework | Flutter | stable | Material 3 |
| State management | Riverpod (annotation) | `flutter_riverpod ^2.6.1` | codegen (`riverpod_generator`) thêm cùng provider `@riverpod` đầu tiên (W2) |
| Persistence | Drift (SQLite) | ^2 | DB cục bộ |
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
