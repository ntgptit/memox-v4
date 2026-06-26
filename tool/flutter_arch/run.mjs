// flutter_arch — scaffold the Flutter Clean-Architecture folder tree.
//
// Reproduces the memox-v3/lib architecture (the contract lives in
// tool/flutter_arch/architecture.json) under the configured source root
// (tool/tool.config.json -> srcDir, default lib/). Two jobs:
//
//   init                 create the base layer skeleton (app/core/data/domain/
//                        presentation/...) with a .gitkeep in each folder.
//   feature <name>       add one feature: presentation/features/<name>/
//                        {routes,screens,viewmodels,widgets} + domain/usecases/
//                        <name>/, with faithful starter stubs (snake_case files,
//                        PascalCase classes, Riverpod-Annotation view model,
//                        go_router route registry).
//
// Usage (zero npm deps):
//   node tool/flutter_arch/run.mjs init [--dry-run] [--force]
//   node tool/flutter_arch/run.mjs feature <name> [--controllers] [--no-stubs] [--dry-run] [--force]
//   node tool/flutter_arch/run.mjs list
//
// Clean-Architecture rule preserved: domain has no outward imports;
// presentation -> domain; data implements domain. Folders only — `flutter create`
// owns main.dart and the platform folders; this never touches them.

import { existsSync, mkdirSync, writeFileSync, readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { PATHS, repoRoot } from '../_config.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const arch = JSON.parse(readFileSync(join(here, 'architecture.json'), 'utf8').replace(/^﻿/, ''));

// ── args ─────────────────────────────────────────────────────────────────────
const argv = process.argv.slice(2);
const flag = (f) => argv.includes(f);
const opts = { dryRun: flag('--dry-run'), force: flag('--force'), controllers: flag('--controllers'), noStubs: flag('--no-stubs') };
const positionals = argv.filter((a) => !a.startsWith('-'));
const cmd = positionals[0];

if (flag('-h') || flag('--help') || !cmd) {
  console.log('flutter_arch — scaffold the Flutter folder architecture (under ' + PATHS.srcDir + '/)\n');
  console.log('  node tool/flutter_arch/run.mjs init [--dry-run] [--force]');
  console.log('  node tool/flutter_arch/run.mjs feature <name> [--controllers] [--no-stubs] [--dry-run] [--force]');
  console.log('  node tool/flutter_arch/run.mjs list');
  process.exit(cmd ? 0 : 1);
}

// ── package name (for stub imports) ──────────────────────────────────────────
function packageName() {
  const p = join(repoRoot, 'pubspec.yaml');
  if (existsSync(p)) {
    const m = readFileSync(p, 'utf8').match(/^name:\s*([A-Za-z_][A-Za-z0-9_]*)/m);
    if (m) return m[1];
  }
  return 'app';
}

// ── naming helpers ───────────────────────────────────────────────────────────
const toSnake = (s) => s.trim().replace(/[\s-]+/g, '_').replace(/[^A-Za-z0-9_]/g, '').replace(/([a-z0-9])([A-Z])/g, '$1_$2').toLowerCase().replace(/_+/g, '_').replace(/^_|_$/g, '');
const toPascal = (snake) => snake.split('_').filter(Boolean).map((w) => w[0].toUpperCase() + w.slice(1)).join('');
const toCamel = (pascal) => pascal[0].toLowerCase() + pascal.slice(1);

// ── fs helpers (respect --dry-run / --force) ─────────────────────────────────
const srcRoot = join(repoRoot, PATHS.srcDir);
let made = 0, skipped = 0;

function ensureDir(relUnderSrc) {
  const dir = join(srcRoot, relUnderSrc);
  if (!existsSync(dir)) {
    console.log(`  dir    ${PATHS.srcDir}/${relUnderSrc}`);
    if (!opts.dryRun) mkdirSync(dir, { recursive: true });
    made++;
  }
  return dir;
}

function writeFile(relUnderSrc, content) {
  const file = join(srcRoot, relUnderSrc);
  if (existsSync(file) && !opts.force) {
    console.log(`  skip   ${PATHS.srcDir}/${relUnderSrc}  (exists; --force to overwrite)`);
    skipped++;
    return;
  }
  console.log(`  ${existsSync(file) ? 'over  ' : 'file  '} ${PATHS.srcDir}/${relUnderSrc}`);
  if (!opts.dryRun) { mkdirSync(dirname(file), { recursive: true }); writeFileSync(file, content); }
  made++;
}

const gitkeep = (relUnderSrc) => writeFile(`${relUnderSrc}/.gitkeep`, '');

// ── list ─────────────────────────────────────────────────────────────────────
if (cmd === 'list') {
  console.log(`Flutter architecture (under ${PATHS.srcDir}/), from tool/flutter_arch/architecture.json:\n`);
  for (const d of arch.dirs) console.log('  ' + d + '/');
  console.log(`\nfeature subdirs: ${arch.featureSubdirs.join(', ')}`);
  process.exit(0);
}

// ── init ─────────────────────────────────────────────────────────────────────
if (cmd === 'init') {
  console.log(`flutter_arch init -> ${PATHS.srcDir}/ (${arch.dirs.length} folders)\n`);
  for (const d of arch.dirs) { ensureDir(d); gitkeep(d); }
  summary();
  process.exit(0);
}

// ── feature ──────────────────────────────────────────────────────────────────
if (cmd === 'feature') {
  const raw = positionals[1];
  if (!raw) { console.error('flutter_arch: feature needs a name, e.g. `feature deck`'); process.exit(2); }
  const name = toSnake(raw);
  const Pascal = toPascal(name);
  const camel = toCamel(Pascal);
  const pkg = packageName();
  const vmDir = opts.controllers ? 'controllers' : 'viewmodels';
  const vmSuffix = opts.controllers ? 'controller' : 'viewmodel';
  const VmSuffix = opts.controllers ? 'Controller' : 'ViewModel';
  const featureBase = `presentation/features/${name}`;

  console.log(`flutter_arch feature "${name}" (${Pascal}) -> ${PATHS.srcDir}/  [pkg: ${pkg}]\n`);

  // folders
  for (const sub of arch.featureSubdirs) ensureDir(`${featureBase}/${sub.replace('viewmodels', vmDir)}`);
  ensureDir(`domain/usecases/${name}`);

  if (opts.noStubs) {
    for (const sub of arch.featureSubdirs) gitkeep(`${featureBase}/${sub.replace('viewmodels', vmDir)}`);
    gitkeep(`domain/usecases/${name}`);
    summary();
    process.exit(0);
  }

  // stubs
  writeFile(`${featureBase}/screens/${name}_screen.dart`, screenStub(name, Pascal));
  writeFile(`${featureBase}/${vmDir}/${name}_${vmSuffix}.dart`, viewModelStub(name, Pascal, vmSuffix, VmSuffix));
  writeFile(`${featureBase}/routes/${name}_routes.dart`, routesStub(name, Pascal, camel, pkg));
  gitkeep(`${featureBase}/widgets`);
  writeFile(`domain/usecases/${name}/load_${name}_usecase.dart`, useCaseStub(Pascal));

  summary();
  if (!opts.noStubs) {
    console.log('\nNote: the view model uses Riverpod Annotation — run codegen before analyze:');
    console.log('  dart run build_runner build --delete-conflicting-outputs');
  }
  process.exit(0);
}

console.error(`flutter_arch: unknown command "${cmd}". Use init | feature <name> | list.`);
process.exit(2);

// ── summary ──────────────────────────────────────────────────────────────────
function summary() {
  console.log('');
  console.log(`flutter_arch: ${opts.dryRun ? 'would create' : 'created'} ${made} item(s)${skipped ? `, skipped ${skipped}` : ''}.`);
}

// ── stubs ────────────────────────────────────────────────────────────────────
function screenStub(name, Pascal) {
  return `import 'package:flutter/material.dart';

/// ${Pascal} screen.
///
/// FILL: build the real UI from the design system (e.g. MxScaffold / MxAppBar)
/// and watch the ${name} ${'view model'}. Handle loading / loaded / empty / error.
class ${Pascal}Screen extends StatelessWidget {
  const ${Pascal}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('${Pascal}')),
    );
  }
}
`;
}

function viewModelStub(name, Pascal, suffix, Suffix) {
  return `import 'package:riverpod_annotation/riverpod_annotation.dart';

part '${name}_${suffix}.g.dart';

/// ${Pascal} ${Suffix.toLowerCase()} (Riverpod Annotation).
///
/// FILL: load state via a domain use case; keep failures in-band (Result) so the
/// screen renders the error state. Generate the .g.dart part with:
///   dart run build_runner build --delete-conflicting-outputs
@riverpod
class ${Pascal}${Suffix} extends _\$${Pascal}${Suffix} {
  @override
  Future<void> build() async {
    // FILL: load initial state.
  }
}
`;
}

function routesStub(name, Pascal, camel, pkg) {
  return `// ${Pascal} route registry.
//
// FILL: register this branch in app/router and replace the constants below with
// your RouteNames / RoutePaths. memox pattern (requires go_router):
//
//   import 'package:go_router/go_router.dart';
//   import 'package:${pkg}/app/router/route_names.dart';
//   import 'package:${pkg}/app/router/route_paths.dart';
//   import 'package:${pkg}/presentation/features/${name}/screens/${name}_screen.dart';
//
//   List<RouteBase> ${camel}BranchRoutes() => <RouteBase>[
//     GoRoute(
//       path: RoutePaths.${camel},
//       name: RouteNames.${camel},
//       builder: (context, state) => const ${Pascal}Screen(),
//     ),
//   ];

/// Placeholder route ids for the ${name} feature until it is wired into app/router.
class ${Pascal}Routes {
  const ${Pascal}Routes._();

  static const String name = '${name}';
  static const String path = '/${name}';
}
`;
}

function useCaseStub(Pascal) {
  return `/// Load${Pascal}UseCase — one responsibility (see docs/contracts/usecase-contracts).
///
/// FILL: depend on a repository INTERFACE (domain), return a Result/Either whose
/// failures come from the error contract. Business logic lives here, not in the
/// view model. domain must not import data or presentation.
class Load${Pascal}UseCase {
  const Load${Pascal}UseCase();

  // Future<Result<Object?>> call() async { ... }
}
`;
}
