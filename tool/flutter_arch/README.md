# flutter_arch — Flutter folder-architecture generator

Scaffolds the Clean-Architecture folder tree (derived from `memox-v3/lib`) under the
configured source root (`tool/tool.config.json` → `srcDir`, default `lib/`). The
architecture contract is data: [architecture.json](architecture.json) — edit it once
and the tool follows.

## Commands

```bash
node tool/flutter_arch/run.mjs list                 # print the architecture
node tool/flutter_arch/run.mjs init                 # create the base layer skeleton
node tool/flutter_arch/run.mjs feature <name>       # add one feature (folders + stubs)
```

Flags: `--dry-run` (plan only), `--force` (overwrite files), `--controllers` (use
`controllers/` instead of `viewmodels/`), `--no-stubs` (feature folders only).

## What `init` creates

The layer skeleton — `app/{bootstrap,di,router}`, `core/{constants,error,logging,theme,util}`,
`data/datasources/local/{connection,daos,drift,migrations,preferences}` + `mappers/repositories/services`,
`domain/{entities,models,repositories,services,types,usecases}`, `l10n/`,
`presentation/features` + `presentation/shared/{async,dialogs,feedback,hooks,layouts,navigation,sort,widgets/{buttons,feedback,inputs,navigation,states,surfaces}}`
— each with a `.gitkeep`. It never touches `main.dart` or the platform folders
(`flutter create` owns those). Business sub-domains (`domain/srs`, `domain/study`, …)
and features are content — add them per feature.

## What `feature <name>` creates

```
presentation/features/<name>/
  routes/<name>_routes.dart        # route ids + commented go_router branch pattern
  screens/<name>_screen.dart       # StatelessWidget (compiles immediately)
  viewmodels/<name>_viewmodel.dart # @riverpod notifier (run build_runner)
  widgets/.gitkeep
domain/usecases/<name>/load_<name>_usecase.dart   # domain use-case skeleton
```

Names follow memox conventions: snake_case files, PascalCase classes (`card_history`
→ `CardHistoryScreen`). The package name in stub imports is read from `pubspec.yaml`.

After scaffolding a feature, run codegen for the Riverpod part:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Clean-Architecture rule preserved

domain has no outward imports · presentation → domain · data implements domain.
The generated stubs encode this (the use case lives in `domain/`, depends on a
repository interface, not on data/presentation).
