#!/usr/bin/env node
// PreToolUse kit-first guard (AGENTS.md §Golden rules #2).
//
// Fires before Edit/Write/MultiEdit. When the target is a Flutter **UI** file
// (a screen, a widget, a shared Mx composite/primitive, or the app theme), it
// forces the kit-first check: the design kit must define every UI change first.
// It asks for confirmation and injects the directive to investigate the kit
// (spawn a kit-parity sub-agent) before diverging.
//
// Non-UI Dart (providers/logic), generated files, tests, and everything outside
// lib/presentation are allowed silently. Wired in .claude/settings.json.
//
// Hook I/O contract: reads the tool call as JSON on stdin; on a UI hit it writes
// a PreToolUse hookSpecificOutput to stdout (permissionDecision "ask"). Any parse
// problem or non-UI path exits 0 (allow) so the guard can never wedge editing.

import process from 'node:process';

let raw = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (chunk) => (raw += chunk));
process.stdin.on('end', () => {
  let input;
  try {
    input = JSON.parse(raw || '{}');
  } catch {
    process.exit(0); // never block on a malformed payload
  }

  const filePath = String(input?.tool_input?.file_path ?? '').replace(/\\/g, '/');
  if (!filePath || !isFlutterUi(filePath)) {
    process.exit(0); // not a Flutter UI file → allow silently
  }

  const reason = [
    `KIT-FIRST GUARD — "${filePath}" is a Flutter UI file.`,
    'The design kit (docs/design/MemoX Design System/) is the source of truth and',
    'MUST define every UI change first (AGENTS.md §Golden rules #2).',
    '',
    'Before this edit lands you MUST have investigated the kit for THIS change —',
    'if you have not, DENY and first spawn a kit-parity sub-agent (Agent tool,',
    'subagent_type "Explore") to answer: does the kit already define this UI/state?',
    '  • kit already defines it → make Flutter match the kit EXACTLY',
    '    (same placement, control type, and scope);',
    '  • kit does NOT define it → update the kit (.jsx/.d.ts + tokens) and',
    '    /design-sync FIRST, then implement Flutter.',
    'Never introduce Flutter-only UI or a design that diverges from the kit.',
    '(Non-visual edits — providers/logic/data — are exempt and can be allowed.)',
  ].join('\n');

  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: {
        hookEventName: 'PreToolUse',
        permissionDecision: 'ask',
        permissionDecisionReason: reason,
      },
    }),
  );
  process.exit(0);
});

/** A Flutter UI file whose pixels the kit owns: screens, widgets, shared Mx
 *  composites/primitives/layouts, and the app theme. Providers (state/logic),
 *  generated files, and tests are NOT UI. */
function isFlutterUi(fp) {
  if (!fp.endsWith('.dart')) return false;
  if (/\.(g|freezed|drift)\.dart$/.test(fp)) return false;
  if (fp.endsWith('_test.dart') || fp.includes('/test/')) return false;
  if (fp.includes('/providers/')) return false; // logic, not visuals
  return (
    /lib\/presentation\/features\/[^/]+\/(screens|widgets)\//.test(fp) ||
    /lib\/presentation\/shared\/(primitives|composites|layouts|screens)\//.test(fp) ||
    /lib\/core\/theme\/app_theme\.dart$/.test(fp)
  );
}
