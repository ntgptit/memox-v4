// doc_guard — docs/process linter + index generator for MemoX V4.
//
// Guards the zone a code linter cannot: claims docs make about the codebase.
// Replaces the recurring manual audit "do the backtick `path/to/file` refs in
// docs actually exist, and do they follow the path convention?" with one
// command, and generates docs/_generated/repo-map.md so a cold agent session
// reads one small file instead of re-exploring the repo.
//
// Usage (zero npm dependencies):
//   node tool/doc_guard/run.mjs check          # all doc/process checks (CI + verify gate)
//   node tool/doc_guard/run.mjs generate       # (re)write docs/_generated/repo-map.md
//   node tool/doc_guard/run.mjs terms <old>    # find leftover refs to a renamed term
//
// Exit codes: 0 = clean (warnings allowed), 1 = errors found, 2 = tool failure.
//
// Suppression: a ref is exempt from the existence check when it is non-literal
// (a glob `src/**`, an angle-bracket placeholder `<entity>.md`, an ellipsis
// `test/...`, or a bare directory `src/`), OR when its +/-2-line window contains a
// negation/target marker ("does not exist", "target", "future", "planned",
// "removed", "TBD", "example"). Docs may describe things that don't exist yet.
// Path-convention checks (leading slash, relative) still apply to every ref.

import { readdirSync, statSync, readFileSync, writeFileSync, existsSync, mkdirSync } from 'node:fs';
import { join, resolve, dirname, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..');
const rel = (p) => p.slice(repoRoot.length + 1).replaceAll(sep, '/');
// `shots`/`specs` are the UI-kit exporter's generated output (tool/ui_kit_shots);
// like `generated`, they are machine artifacts — neither linted nor mapped.
const IGNORE = new Set(['node_modules', '.git', '.dart_tool', 'build', 'dist', 'generated', 'shots', 'specs', '.idea', '.vscode']);

function walk(dir, out = []) {
  if (!existsSync(dir)) return out;
  for (const e of readdirSync(dir)) {
    if (IGNORE.has(e)) continue;
    const p = join(dir, e);
    if (statSync(p).isDirectory()) walk(p, out);
    else out.push(p);
  }
  return out;
}

const docFiles = () => [
  // `docs/agent/kit-to-flutter/**` are GENERATED per-screen conversion prompts
  // (tool/parity/gen_convert_prompts.mjs) that intentionally reference artifacts a
  // run will CREATE (`<screen>.slots.json`, `<screen>_parity_test.dart`) — not doc
  // contracts, so they are exempt from the ref-existence lint.
  ...walk(join(repoRoot, 'docs'))
    .filter((p) => p.endsWith('.md') && !p.split(/[\\/]/).join('/').includes('docs/agent/kit-to-flutter/')),
  ...(existsSync(join(repoRoot, 'CLAUDE.md')) ? [join(repoRoot, 'CLAUDE.md')] : []),
  ...(existsSync(join(repoRoot, 'AGENTS.md')) ? [join(repoRoot, 'AGENTS.md')] : []),
];

// Top-level prefixes a backtick ref may legitimately point at.
const REF_PREFIXES = ['docs/', 'tool/', 'src/', 'lib/', 'app/', 'test/', 'tests/', 'CLAUDE.md', 'AGENTS.md'];
const SUPPRESS = /does not exist|doesn't exist|target|future|planned|proposed|removed|deprecated|tbd|to be|example|placeholder|will be|once we|after we/i;
// A ref is "non-literal" (a pattern/placeholder/directory) and not existence-checkable
// when it contains a glob, an angle-bracket placeholder, an ellipsis, or is a bare
// directory (trailing slash). Path-convention checks still apply to these.
const NONLITERAL = (p) => /[<>*?{}]/.test(p) || p.includes('...') || p.endsWith('/');

const cmd = process.argv[2];

if (cmd === 'terms') {
  const term = process.argv[3];
  if (!term) { console.error('usage: doc_guard terms <old-term>'); process.exit(2); }
  let hits = 0;
  for (const f of docFiles()) {
    const lines = readFileSync(f, 'utf8').split('\n');
    lines.forEach((l, i) => {
      if (l.includes(term)) { console.log(`${rel(f)}:${i + 1}: ${l.trim()}`); hits++; }
    });
  }
  console.log(`\n${hits} line(s) still reference "${term}".`);
  process.exit(0);
}

if (cmd === 'generate') {
  generateRepoMap();
  process.exit(0);
}

if (cmd === 'check' || !cmd) {
  const errors = [];
  const warnings = [];
  const refRe = /`([^`]+)`/g;
  for (const f of docFiles()) {
    const lines = readFileSync(f, 'utf8').split('\n');
    lines.forEach((line, i) => {
      let m;
      while ((m = refRe.exec(line))) {
        const ref = m[1].trim();
        if (!REF_PREFIXES.some((p) => ref === p || ref.startsWith(p))) continue;
        // strip an optional :line / #anchor suffix
        const path = ref.split(/[:#]/)[0];
        if (/\s/.test(path)) continue; // not a path-like token
        // path-convention checks
        if (path.startsWith('/')) errors.push(`${rel(f)}:${i + 1}  leading-slash ref \`${ref}\``);
        if (path.startsWith('../') || path.startsWith('./')) errors.push(`${rel(f)}:${i + 1}  relative ref \`${ref}\``);
        // existence (skip patterns/placeholders; honor the suppression window)
        const win = lines.slice(Math.max(0, i - 2), i + 3).join(' ');
        const suppressed = SUPPRESS.test(win) || NONLITERAL(path);
        if (!existsSync(join(repoRoot, path)) && !suppressed) {
          errors.push(`${rel(f)}:${i + 1}  ref to missing path \`${path}\``);
        }
      }
    });
  }
  // WBS hygiene
  const wbs = join(repoRoot, 'docs', 'project-management', 'wbs.md');
  if (existsSync(wbs)) {
    const body = readFileSync(wbs, 'utf8');
    if (!/Commit Traceability Log/i.test(body)) warnings.push('wbs.md: missing "Commit Traceability Log" section (§10).');
  }

  // UI-kit state-parity (see checkKitParity)
  checkKitParity(errors, warnings);

  for (const w of warnings) console.log(`WARN  ${w}`);
  for (const e of errors) console.log(`ERR   ${e}`);
  console.log(`\ndoc_guard: ${errors.length} error(s), ${warnings.length} warning(s) across ${docFiles().length} doc(s).`);
  process.exit(errors.length ? 1 : 0);
}

console.error(`doc_guard: unknown command "${cmd}". Use check | generate | terms <old>.`);
process.exit(2);

// ── repo-map generator ───────────────────────────────────────────────────────
function generateRepoMap() {
  const outDir = join(repoRoot, 'docs', '_generated');
  mkdirSync(outDir, { recursive: true });
  const tree = treeLines(repoRoot, '', 0, 3);
  const docCount = docFiles().length;
  const body = [
    '<!-- GENERATED by tool/doc_guard/run.mjs generate — do not edit by hand. -->',
    '# Repo map (cold-start snapshot)',
    '',
    `Generated: ${new Date().toISOString().slice(0, 10)} · docs: ${docCount} markdown file(s).`,
    '',
    'Read this first in a new session instead of re-exploring the tree.',
    '',
    '```text',
    ...tree,
    '```',
    '',
  ].join('\n');
  const outPath = join(outDir, 'repo-map.md');
  writeFileSync(outPath, body);
  console.log(`wrote ${rel(outPath)} (depth 3).`);
}

function treeLines(dir, prefix, depth, maxDepth) {
  if (depth > maxDepth) return [];
  const out = [];
  const entries = readdirSync(dir)
    .filter((e) => !IGNORE.has(e) && !e.startsWith('.'))
    .sort((a, b) => {
      const ad = statSync(join(dir, a)).isDirectory(), bd = statSync(join(dir, b)).isDirectory();
      return ad === bd ? a.localeCompare(b) : ad ? -1 : 1;
    });
  entries.forEach((e, i) => {
    const p = join(dir, e);
    const last = i === entries.length - 1;
    const isDir = statSync(p).isDirectory();
    out.push(`${prefix}${last ? '└─ ' : '├─ '}${e}${isDir ? '/' : ''}`);
    if (isDir && depth < maxDepth) out.push(...treeLines(p, prefix + (last ? '   ' : '│  '), depth + 1, maxDepth));
  });
  return out;
}

// ── UI-kit state-parity ──────────────────────────────────────────────────────
// The kit gallery's SCREENS array (index.html) is the source of truth for which
// screens/states exist — it actually renders them. Other docs restate that
// inventory and drift silently: the build queue (tool/preview/kit-build.md)
// lists per-screen state sets, and the design-system readme states a screen
// count. This locks those restatements to SCREENS and verifies every screen
// module the gallery loads exists. If the kit can't be found the check warns and
// skips, so doc_guard stays usable in a scaffolded repo without this kit.
function checkKitParity(errors, warnings) {
  const kitHtml = join(repoRoot, 'docs', 'design', 'MemoX Design System', 'ui_kits', 'memox-app', 'index.html');
  if (!existsSync(kitHtml)) { warnings.push('kit-parity: index.html not found — skipped.'); return; }
  const html = readFileSync(kitHtml, 'utf8');
  const kitDir = dirname(kitHtml);

  // Parse SCREENS: each `{ id: '..', … states: ['a','b',…] }` (one entry per line).
  const screens = new Map();
  const screenRe = /\{\s*id:\s*'([^']+)'[^}]*?states:\s*\[([^\]]*)\]/g;
  let sm;
  while ((sm = screenRe.exec(html))) {
    const states = sm[2].split(',').map((s) => s.trim().replace(/^'|'$/g, '')).filter(Boolean);
    screens.set(sm[1], new Set(states));
  }
  if (screens.size === 0) { warnings.push('kit-parity: no SCREENS parsed from index.html — skipped.'); return; }

  // (C) every screen module the gallery loads must exist on disk.
  const scriptRe = /<script[^>]*\bsrc="([^"]+\.jsx)"/g;
  let cm;
  while ((cm = scriptRe.exec(html))) {
    if (!existsSync(join(kitDir, cm[1]))) errors.push(`kit-parity: index.html loads missing module \`${cm[1]}\``);
  }

  // (A) build-queue state sets must equal SCREENS (set-wise; gallery order is cosmetic).
  const queue = join(repoRoot, 'tool', 'preview', 'kit-build.md');
  if (existsSync(queue)) {
    readFileSync(queue, 'utf8').split('\n').forEach((line, i) => {
      const idM = line.match(/`([a-z0-9-]+)\/`/);
      const stM = line.match(/state:\s*([^\n]+?)\s*$/);
      if (!idM || !stM) return;
      const id = idM[1];
      const at = `${rel(queue)}:${i + 1}`;
      const canon = screens.get(id);
      if (!canon) { errors.push(`kit-parity: ${at} queue lists screen \`${id}\` absent from SCREENS`); return; }
      const listed = new Set(stM[1].split('·').map((s) => s.trim()).filter(Boolean));
      const missing = [...canon].filter((s) => !listed.has(s));
      const extra = [...listed].filter((s) => !canon.has(s));
      if (missing.length || extra.length) {
        errors.push(`kit-parity: ${at} state drift for \`${id}\`` +
          (missing.length ? ` — queue missing ${missing.join('·')}` : '') +
          (extra.length ? ` — queue has extra ${extra.join('·')}` : ''));
      }
    });
  }

  // (B) design-system readme screen count must equal SCREENS size.
  const readme = join(kitDir, '..', '..', 'readme.md');
  if (existsSync(readme)) {
    const cM = readFileSync(readme, 'utf8').match(/gallery\s*\((\d+)\s+screens/i);
    if (cM && Number(cM[1]) !== screens.size) {
      errors.push(`kit-parity: ${rel(readme)} says ${cM[1]} screens but SCREENS has ${screens.size}`);
    }
  }
}
