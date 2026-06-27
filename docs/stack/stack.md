# Stack — MemoX V4

Detected/seeded stack: **Flutter / Dart 3** (id: `flutter`, source root: `lib/`).

Thêm dependency cần **duyệt** (CLAUDE.md hard rule). Phiên bản chính xác chốt khi
hoàn thiện `pubspec.yaml`.

**Đã trong `pubspec.yaml` (W1 + S0):** `flutter_riverpod ^2.6.1`, `go_router ^14.6.0`,
`drift ^2.34.0` + `sqlite3_flutter_libs` + `path` + `path_provider`, và i18n
`flutter_localizations` (sdk) + `intl` (ghim theo `flutter_localizations`). Các package
còn lại (mocktail, sync…) thêm khi feature tương ứng cần.

> **Riverpod codegen hoãn (S0):** `riverpod_generator` ghim `source_gen ^2` /
> `analyzer 7–8`, xung đột trực tiếp với `drift_dev 2.34` (`source_gen ^3` /
> `analyzer 10–12`); bản `riverpod_generator ^3` lại kéo theo `flutter_riverpod ^3`.
> Để giữ pin `^2` và không nâng major không người giám sát, S0 dùng **`AsyncNotifier`
> viết tay** (vẫn Riverpod, vẫn keepAlive) thay cho `@riverpod`. Xem lại khi nâng
> `drift_dev`/`analyzer` để bật lại codegen.

| Concern | Choice | Version | Notes |
| --- | --- | --- | --- |
| Language / runtime | Dart | 3.x | null-safety, sealed/pattern |
| Framework | Flutter | stable | Material 3 |
| State management | Riverpod | `flutter_riverpod ^2.6.1` | `AsyncNotifier` viết tay; `@riverpod` codegen hoãn (xung đột `drift_dev`, xem ghi chú trên) |
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
