// prompt_gen — compose a Claude Code task prompt from the project's dev loop.
//
// Burns no agent tokens re-deriving "what should this prompt say": it stamps out
// the standard task envelope (required reading, acceptance criteria slot, the
// mandatory workflow, the verify command, the report format) so every task you
// hand off is shaped the same way. Fill the bracketed blanks, paste, go.
//
// Usage:
//   node tool/prompt_gen/run.mjs "<task title>" [WBS-ID]
//   node tool/prompt_gen/run.mjs --type screen "Build the Settings screen"
//
// --type adds the task-specific required-reading rows for that kind of work.

import { readFileSync, existsSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..');
const argv = process.argv.slice(2);
let type = 'generic';
const ti = argv.indexOf('--type');
if (ti >= 0) { type = argv[ti + 1]; argv.splice(ti, 2); }
const title = argv[0];
const wbsId = argv[1];

if (!title) {
  console.error('usage: node tool/prompt_gen/run.mjs "<task title>" [WBS-ID] [--type screen|usecase|repo|schema|route]');
  process.exit(2);
}

// task-specific reading (mirror docs/agent/agent-task-template.md + CLAUDE.md "Required reading by task")
const READING = {
  generic: [],
  screen: ['docs/design/_screen-template.md', 'docs/ui-ux/ui-ux-contract.md'],
  usecase: ['docs/contracts/usecase-contracts/_template.md', 'the matching docs/business/** spec', 'docs/decision-tables/core-decision-table.md'],
  repo: ['docs/contracts/repository-contracts/_template.md', 'docs/database/schema-contract.md'],
  schema: ['docs/database/schema-contract.md', 'docs/database/migration-contract.md', 'docs/database/storage-boundaries.md'],
  route: ['docs/business/navigation/navigation-flow.md'],
};

const universal = [
  'docs/_generated/repo-map.md',
  'docs/business/index.md + docs/business/glossary.md',
  'docs/contracts/error-contract.md, docs/contracts/types-catalog.md, docs/contracts/code-style.md',
];
const reading = [...universal, ...(READING[type] || [])];

let wbsLine = '';
if (wbsId) {
  const wbs = join(repoRoot, 'docs', 'project-management', 'wbs.md');
  if (existsSync(wbs)) {
    const row = readFileSync(wbs, 'utf8').split('\n').find((l) => l.includes(wbsId));
    wbsLine = row ? `\nWBS row: ${row.trim()}` : `\nWBS: ${wbsId} (row not found — check docs/project-management/wbs.md)`;
  }
}

const prompt = `# Task: ${title}${wbsId ? `  [${wbsId}]` : ''}${wbsLine}

## 1. Required reading (read BEFORE coding)
${reading.map((r) => `- ${r}`).join('\n')}

## 2. Drift check
Compare the docs above against current code. If docs already lag code, STOP and
report in DRIFT DETECTED format — do not continue the task.

## 3. Acceptance criteria
<!-- FILL: testable bullet criteria. Source from docs/acceptance-criteria/ if present. -->
- [ ] ...

## 4. Implement
Follow the layering in CLAUDE.md (entity -> contract -> use case -> state -> UI).
Reuse existing shared components/tokens; do not hardcode magic values.

## 5. Parity (same commit)
Run the Pre-commit parity check in CLAUDE.md. Update every doc the change touches
(business / decision table / schema / route / WBS) in the SAME commit.

## 6. Verify
Inner loop: ${'`node tool/verify/run.mjs --quick`'}
End of task: ${'`node tool/verify/run.mjs --full`'} (writes the pass-marker)

## 7. Report
- Files changed
- Docs updated (file + reason)
- Verify result
- Anything left out of scope and why
`;

console.log(prompt);
