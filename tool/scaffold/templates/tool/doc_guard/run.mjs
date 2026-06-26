// doc_guard — docs/process linter + index generator for {{PROJECT_NAME}}.
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
const IGNORE = new Set(['node_modules', '.git', '.dart_tool', 'build', 'dist', 'generated', '.idea', '.vscode']);

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
  ...walk(join(repoRoot, 'docs')).filter((p) => p.endsWith('.md')),
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
