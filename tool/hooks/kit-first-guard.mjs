#!/usr/bin/env node
// PreToolUse kit-first guard (AGENTS.md §Golden rules #2).
//
// Fires before Edit/Write/MultiEdit. When the target is a Flutter **UI** file
// (a screen, a widget, a shared Mx composite/primitive, or the app theme), it
// enforces the kit-first workflow: the design kit must define every UI change
// first. It does this **automatically, without asking the user** — it DENIES the
// first edit to a given UI file and hands the agent a directive to investigate
// the kit (spawn a kit-parity sub-agent) itself, then re-issue the edit.
//
// Loop-safety: the guard writes a short-lived marker the moment it denies, so the
// agent's retry of the *same* file passes automatically (the directive has been
// surfaced). The marker has a TTL (KIT_ACK_TTL_MS) — long enough to stay quiet for
// the rest of an active task, short enough to re-fire for a fresh task later. So a
// UI file is gated exactly once per work session, never on every keystroke, and
// the user is never prompted.
//
// Non-UI Dart (providers/logic), generated files, tests, and everything outside
// lib/presentation are allowed silently. Wired in .claude/settings.json.
//
// Hook I/O contract: reads the tool call as JSON on stdin. On a first UI hit it
// writes a PreToolUse hookSpecificOutput with permissionDecision "deny" (fed back
// to the AGENT, not the user) and records the marker; on a re-hit within the TTL
// it allows. Any parse/IO problem exits 0 (allow) so the guard can never wedge
// editing.

import process from 'node:process';
import { existsSync, mkdirSync, writeFileSync, readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import path from 'node:path';

/** How long a kit-first ack stays valid (ms). Within one active task the guard
 *  stays quiet after the first pass; a later task (past the TTL) is gated again. */
const KIT_ACK_TTL_MS = 30 * 60 * 1000; // 30 minutes
const ACK_DIR = path.join('tool', 'hooks', '.kit-acks');

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

  // Already vetted this UI file within the TTL? → allow the edit (this is the
  // agent's retry after it investigated the kit, or a follow-up edit same task).
  if (isAcked(filePath)) {
    process.exit(0);
  }

  // First touch of this UI file: record the ack now (so the retry passes) and
  // DENY this attempt, handing the agent the kit-first directive. This is
  // automatic — the reason goes to the agent, the user is never asked.
  if (!recordAck(filePath)) {
    process.exit(0); // couldn't persist the marker → never wedge, allow
  }

  const reason = [
    `KIT-FIRST GUARD — "${filePath}" is a Flutter UI file (AGENTS.md §Golden rules #2).`,
    'Do NOT ask the user. Handle this automatically, now:',
    '',
    '1. Spawn a kit-parity sub-agent (Agent tool, subagent_type "Explore") to',
    '   investigate the kit (docs/design/MemoX Design System/) for THIS exact',
    '   change: does the kit already define this UI / state / control / placement?',
    '2. Act on the finding:',
    '   • kit already defines it → make Flutter match the kit EXACTLY (same',
    '     placement, control type, and scope);',
    '   • kit does NOT define it → update the kit (.jsx/.d.ts + tokens) and run',
    '     /design-sync FIRST, then implement Flutter to match.',
    '3. Re-issue this same edit — it will now pass automatically (this file is',
    '   marked kit-checked for the next 30 min).',
    '',
    'Never introduce Flutter-only UI or a design that diverges from the kit.',
    '(Non-visual edits — providers/logic/data — never reach this guard.)',
  ].join('\n');

  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: {
        hookEventName: 'PreToolUse',
        permissionDecision: 'deny',
        permissionDecisionReason: reason,
      },
    }),
  );
  process.exit(0);
});

/** Marker path for a UI file (sanitized → a stable hashed filename). */
function ackPathFor(filePath) {
  const key = createHash('sha1').update(filePath).digest('hex').slice(0, 16);
  return path.join(ACK_DIR, key);
}

/** True when this UI file was kit-checked within the TTL. */
function isAcked(filePath) {
  try {
    const p = ackPathFor(filePath);
    if (!existsSync(p)) return false;
    const stamp = Number(readFileSync(p, 'utf8')) || 0;
    return Date.now() - stamp < KIT_ACK_TTL_MS;
  } catch {
    return false;
  }
}

/** Persist the kit-checked marker (timestamped). Returns false on IO failure. */
function recordAck(filePath) {
  try {
    mkdirSync(ACK_DIR, { recursive: true });
    writeFileSync(ackPathFor(filePath), String(Date.now()));
    return true;
  } catch {
    return false;
  }
}

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
