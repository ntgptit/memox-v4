#!/usr/bin/env node
// @ts-check
/**
 * tool/design/export_kit_shot.mjs — regenerate a single kit shot PNG from the kit
 * SOURCE (a lightweight stand-in for the removed `ui_kit_shots` exporter).
 *
 * The kit gallery (ui_kits/memox-app/index.html) renders every screen-state
 * client-side (React + Babel). This derives a one-state page from it, serves the
 * kit over http, and headless-screenshots the 390×780 `.app` frame to
 * `shots/<screen>--<state>--<theme>.png` for BOTH themes. Use it when a shot goes
 * stale after a kit change (e.g. the diff flags a state whose Flutter is correct).
 *
 *   node tool/design/export_kit_shot.mjs <screen> <state>
 *   node tool/design/export_kit_shot.mjs dashboard empty
 *
 * Requires: Chrome or Edge installed (headless). Network (the gallery loads
 * React/Babel from unpkg). Writes plain 390×780 PNGs (matches Flutter goldens;
 * the kit's original bezel/rounded-corner styling is intentionally dropped — it
 * only ever added a corner mismatch against the square Flutter render).
 */

import { readFileSync, writeFileSync, rmSync, existsSync } from 'node:fs';
import { createServer } from 'node:http';
import { spawnSync } from 'node:child_process';
import { join, dirname, extname } from 'node:path';
import { fileURLToPath } from 'node:url';

const [screen, state] = process.argv.slice(2);
if (!screen || !state) {
  console.error('usage: node tool/design/export_kit_shot.mjs <screen> <state>');
  process.exit(2);
}

const REPO = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const KIT = join(REPO, 'docs', 'design', 'MemoX Design System');
const APP = join(KIT, 'ui_kits', 'memox-app');
const SHOTS = join(APP, 'shots');
const SHOT_HTML = join(APP, '_shot.html');

const CHROMES = [
  'C:/Program Files/Google/Chrome/Application/chrome.exe',
  'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe',
  'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',
  'google-chrome', 'chromium', 'chromium-browser',
];
const chrome = CHROMES.find((c) => c.includes('/') ? existsSync(c) : true);

// ── derive the one-state page from index.html ────────────────────────────────
const index = readFileSync(join(APP, 'index.html'), 'utf8');
const head = index.slice(0, index.indexOf('function Frame({'));
const render = `function ShotOne() {
  const p = new URLSearchParams(location.search);
  const screen = SCREENS.find(s => s.id === (p.get('screen') || 'dashboard'));
  const Comp = screen && screen.Comp();
  const state = p.get('state') || 'loaded';
  return (
    <div data-theme={p.get('theme') || 'light'} style={{ width: '390px', height: '780px', overflow: 'hidden', background: 'var(--memox-bg)' }}>
      <ErrorBoundary><div className="app" style={{ width: '100%', height: '100%' }}>{Comp ? <Comp state={state} /> : 'no comp'}</div></ErrorBoundary>
    </div>
  );
}
const _t = new URLSearchParams(location.search).get('theme') || 'light';
document.documentElement.setAttribute('data-theme', _t);
document.body.setAttribute('data-theme', _t);
document.body.style.cssText = 'margin:0;padding:0;background:var(--memox-bg)';
Array.prototype.slice.call(document.body.children).forEach(function (el) { if (el.id !== 'root') el.remove(); });
ReactDOM.createRoot(document.getElementById('root')).render(<ShotOne />);
</script></body></html>`;
writeFileSync(SHOT_HTML, head + render, 'utf8');

// ── static server over the design dir (so ../../ asset paths resolve) ────────
const MIME = { '.html': 'text/html', '.js': 'text/javascript', '.jsx': 'text/babel', '.css': 'text/css', '.json': 'application/json', '.png': 'image/png', '.ttf': 'font/ttf', '.woff2': 'font/woff2' };
const server = createServer((req, res) => {
  const rel = decodeURIComponent((req.url || '/').split('?')[0]);
  const file = join(KIT, rel.replace(/^\/MemoX%20Design%20System/i, '').replace(/^\/MemoX Design System/i, ''));
  try {
    const body = readFileSync(file);
    res.writeHead(200, { 'content-type': MIME[extname(file)] || 'application/octet-stream' });
    res.end(body);
  } catch {
    res.writeHead(404); res.end('not found');
  }
});

await new Promise((r) => server.listen(0, r));
const port = /** @type {any} */ (server.address()).port;
const base = `http://localhost:${port}/ui_kits/memox-app/_shot.html?screen=${screen}&state=${state}`;

let failed = 0;
for (const theme of ['light', 'dark']) {
  const out = join(SHOTS, `${screen}--${state}--${theme}.png`);
  const res = spawnSync(chrome, [
    '--headless=new', '--disable-gpu', '--hide-scrollbars',
    '--force-device-scale-factor=1', '--window-size=390,780',
    '--virtual-time-budget=8000', `--screenshot=${out}`, `${base}&theme=${theme}`,
  ], { stdio: 'ignore', shell: false });
  if (res.status === 0 && existsSync(out)) {
    console.log(`✓ ${screen}--${state}--${theme}.png`);
  } else {
    console.error(`✗ failed: ${screen}--${state}--${theme} (chrome: ${chrome})`);
    failed++;
  }
}

server.close();
rmSync(SHOT_HTML, { force: true });
process.exit(failed ? 1 : 0);
