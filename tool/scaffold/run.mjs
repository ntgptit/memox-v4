// scaffold — generate the "Claude Code working skeleton" for a NEW project.
//
// What it produces is a *khung xương* (skeleton): a CLAUDE.md contract, a docs/
// source-of-truth tree of templates, and the tool/ chain (verify + doc_guard +
// prompt_gen) that MemoX uses to keep an AI agent on rails. Every generated doc
// is a structured stub with `<!-- FILL: ... -->` markers, so when you later hand
// a task to Claude Code it only fills the right blanks instead of re-inventing
// the whole information architecture each session.
//
// Design principle (inherited from MemoX `tool/README.md`): deterministic,
// generated + linted indexes beat letting the agent re-explore the repo.
//
// Usage (zero npm dependencies, Node >= 18):
//   node tool/scaffold/run.mjs <target-dir> [options]
//
// Options:
//   --name "<Project Name>"   Human project name              (default: target dir name)
//   --slug <slug>             kebab-case id                    (default: derived from name)
//   --stack <id>              generic|flutter|node-ts|spring-boot|python  (default: generic)
//   --src <dir>              source root override              (default: per-stack)
//   --force                  overwrite files that already exist
//   --dry-run                print what would be written, write nothing
//   --list                   list the template inventory and exit
//   -h, --help               this help
//
// Examples:
//   node tool/scaffold/run.mjs ../my-app --name "My App" --stack node-ts
//   node tool/scaffold/run.mjs . --stack flutter --force      # scaffold in place
//   node tool/scaffold/run.mjs ../x --list

import { readdirSync, statSync, readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { join, resolve, dirname, relative, basename, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const templatesDir = join(here, 'templates');

// ── arg parsing ──────────────────────────────────────────────────────────────
const argv = process.argv.slice(2);
const opts = { stack: 'generic' };
const positionals = [];
for (let i = 0; i < argv.length; i++) {
  const a = argv[i];
  if (a === '-h' || a === '--help') opts.help = true;
  else if (a === '--force') opts.force = true;
  else if (a === '--dry-run') opts.dryRun = true;
  else if (a === '--list') opts.list = true;
  else if (a === '--name') opts.name = argv[++i];
  else if (a === '--slug') opts.slug = argv[++i];
  else if (a === '--stack') opts.stack = argv[++i];
  else if (a === '--src') opts.src = argv[++i];
  else if (a.startsWith('--')) fail(`unknown flag: ${a}`);
  else positionals.push(a);
}

function fail(msg) {
  console.error(`scaffold: ${msg}`);
  process.exit(2);
}

if (opts.help) {
  // The banner above doubles as help; print the usage slice.
  console.log(readFileSync(fileURLToPath(import.meta.url), 'utf8')
    .split('\n').filter((l) => l.startsWith('//')).map((l) => l.slice(3)).join('\n'));
  process.exit(0);
}

// ── stack presets ────────────────────────────────────────────────────────────
// Each preset feeds two things: the generated tool/verify/verify.config.json
// (the real verification chain) and the {{TOKENS}} substituted into the docs.
const STACKS = {
  generic: {
    label: 'Generic (fill in your stack)',
    src: 'src',
    steps: {},
    chains: { quick: [], code: [], full: [], docs: ['doc_guard'] },
  },
  flutter: {
    label: 'Flutter / Dart 3',
    src: 'lib',
    steps: {
      analyze: { cmd: 'flutter analyze' },
      format: { cmd: 'dart format --output=none --set-exit-if-changed .' },
      test: { cmd: 'flutter test' },
    },
    chains: { quick: ['analyze'], code: ['analyze', 'format'], full: ['analyze', 'format', 'test'], docs: ['doc_guard'] },
  },
  'node-ts': {
    label: 'Node.js / TypeScript',
    src: 'src',
    steps: {
      typecheck: { cmd: 'npx tsc --noEmit' },
      lint: { cmd: 'npx eslint .' },
      test: { cmd: 'npm test --silent' },
    },
    chains: { quick: ['typecheck'], code: ['typecheck', 'lint'], full: ['typecheck', 'lint', 'test'], docs: ['doc_guard'] },
  },
  'spring-boot': {
    label: 'Java / Spring Boot',
    src: 'src/main/java',
    steps: {
      compile: { cmd: './mvnw -q -DskipTests compile' },
      test: { cmd: './mvnw -q test' },
    },
    chains: { quick: ['compile'], code: ['compile'], full: ['compile', 'test'], docs: ['doc_guard'] },
  },
  python: {
    label: 'Python',
    src: 'src',
    steps: {
      lint: { cmd: 'ruff check .' },
      types: { cmd: 'mypy .' },
      test: { cmd: 'pytest -q' },
    },
    chains: { quick: ['lint'], code: ['lint', 'types'], full: ['lint', 'types', 'test'], docs: ['doc_guard'] },
  },
};

// ── template walk ────────────────────────────────────────────────────────────
function walk(dir, out = []) {
  for (const e of readdirSync(dir)) {
    const p = join(dir, e);
    if (statSync(p).isDirectory()) walk(p, out);
    else out.push(p);
  }
  return out;
}

if (!existsSync(templatesDir)) fail(`templates dir missing: ${templatesDir}`);
const templateFiles = walk(templatesDir).sort();

if (opts.list) {
  console.log(`scaffold templates (${templateFiles.length}):\n`);
  for (const f of templateFiles) console.log('  ' + relative(templatesDir, f).replaceAll(sep, '/'));
  console.log('\n+ generated: tool/verify/verify.config.json (from --stack)');
  process.exit(0);
}

// ── resolve target + identity ────────────────────────────────────────────────
if (positionals.length === 0) fail('missing <target-dir>. Try --help or --list.');
const target = resolve(positionals[0]);
const stack = STACKS[opts.stack];
if (!stack) fail(`unknown --stack "${opts.stack}". Choices: ${Object.keys(STACKS).join(', ')}`);

const name = opts.name || basename(target);
const slug = opts.slug || slugify(name);
const src = opts.src || stack.src;
const date = new Date().toISOString().slice(0, 10);

function slugify(s) {
  return s.toLowerCase().trim().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '') || 'project';
}

const tokens = {
  PROJECT_NAME: name,
  PROJECT_SLUG: slug,
  STACK: stack.label,
  STACK_ID: opts.stack,
  SRC_DIR: src,
  DATE: date,
  VERIFY_QUICK: 'node tool/verify/run.mjs --quick',
  VERIFY_FULL: 'node tool/verify/run.mjs --full',
};

function substitute(text) {
  return text.replace(/\{\{(\w+)\}\}/g, (m, k) => (k in tokens ? tokens[k] : m));
}

// ── write plan ───────────────────────────────────────────────────────────────
const plan = []; // { out, content }
for (const f of templateFiles) {
  const relPath = relative(templatesDir, f).replaceAll(sep, '/');
  const content = substitute(readFileSync(f, 'utf8'));
  plan.push({ out: join(target, relPath), rel: relPath, content });
}

// Generated (not template-backed): the real verification chain config.
const verifyConfig = {
  $schema: 'see tool/verify/run.mjs',
  stack: opts.stack,
  src,
  steps: stack.steps,
  chains: stack.chains,
  docGuard: 'node tool/doc_guard/run.mjs check',
};
plan.push({
  out: join(target, 'tool/verify/verify.config.json'),
  rel: 'tool/verify/verify.config.json',
  content: JSON.stringify(verifyConfig, null, 2) + '\n',
});

// ── execute ──────────────────────────────────────────────────────────────────
let written = 0, skipped = 0;
for (const p of plan.sort((a, b) => a.rel.localeCompare(b.rel))) {
  const exists = existsSync(p.out);
  if (exists && !opts.force) {
    console.log(`  skip   ${p.rel}  (exists; use --force)`);
    skipped++;
    continue;
  }
  if (opts.dryRun) {
    console.log(`  ${exists ? 'over' : 'write'}  ${p.rel}`);
    written++;
    continue;
  }
  mkdirSync(dirname(p.out), { recursive: true });
  writeFileSync(p.out, p.content);
  console.log(`  ${exists ? 'over ' : 'write'}  ${p.rel}`);
  written++;
}

// ── summary ──────────────────────────────────────────────────────────────────
console.log('');
console.log(`scaffold: ${name} (${slug}) · stack=${opts.stack} · src=${src}`);
console.log(`target:   ${target}`);
console.log(`${opts.dryRun ? 'would write' : 'wrote'} ${written} file(s)${skipped ? `, skipped ${skipped}` : ''}.`);
if (!opts.dryRun) {
  console.log('\nNext:');
  console.log('  1. Read GETTING-STARTED.md in the target — it lists the fill-in order.');
  console.log('  2. git init && git config core.hooksPath .githooks');
  console.log('  3. node tool/doc_guard/run.mjs generate   # build the _generated indexes');
  console.log('  4. node tool/verify/run.mjs --docs        # confirm the chain runs');
}
