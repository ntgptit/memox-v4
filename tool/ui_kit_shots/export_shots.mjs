// Exports every screen x state x theme frame of the MemoX app UI kit as PNGs.
//
// The kit (PATHS.uiKitDir → docs/design/MemoX Design System/ui_kits/memox-app/index.html)
// renders a gallery: one `.mxg-row` per screen, a stepper cycling its states, each
// state framed light + dark in a `.mxg-frame[data-theme]` device frame. This script
// steps through ALL states of every row and screenshots the light and dark frames
// separately, then writes shots/INDEX.md as the agent-facing manifest.
//
// Shots are named `<screen-id>--<state>--<theme>.png` where <screen-id> is the row's
// `data-screen-label` (e.g. `dashboard`, `deck-detail`) — the same id the parity
// contracts (tool/parity/contracts/<id>.gen.json) and parity-map.json key on.
//
// Usage:  cd tool/ui_kit_shots && npm install && npm run export
// Requires: Google Chrome installed (path auto-detected; or set CHROME_PATH) +
// network access (the kit loads React/Babel from unpkg + Material Symbols font).

import { existsSync, mkdirSync, writeFileSync, readdirSync, unlinkSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import puppeteer from 'puppeteer-core';
import { startKitServer } from './serve_kit.mjs';
import { PATHS } from '../_config.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(here, '..', '..');
const kitDir = join(repoRoot, PATHS.uiKitDir);
const kitHtml = join(kitDir, 'index.html');
const outDir = join(kitDir, 'shots');

// Serve from the design-system root so the kit's `../../styles.css` + `../../_ds_bundle.js`
// resolve; navigate to the kit index path *relative to that root* (derived from PATHS,
// so retargeting the kit in tool.config.json needs no edit here).
const serveRoot = resolve(kitDir, '..', '..');
const navPath = '/' + PATHS.kitHtml.slice(PATHS.designSystemDir.length).replace(/^[/\\]+/, '');

const chromeCandidates = [
  process.env.CHROME_PATH,
  'C:/Program Files/Google/Chrome/Application/chrome.exe',
  'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe',
  `${process.env.LOCALAPPDATA}/Google/Chrome/Application/chrome.exe`,
  '/usr/bin/google-chrome',
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
];
const chromePath = chromeCandidates.find((p) => p && existsSync(p));
if (!chromePath) {
  console.error('Chrome not found. Set CHROME_PATH or install Google Chrome.');
  process.exit(1);
}

const slug = (s) =>
  String(s)
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function main() {
  if (!existsSync(kitHtml)) throw new Error(`Kit not found: ${kitHtml}`);
  mkdirSync(outDir, { recursive: true });
  // Clean stale shots so renames/removed states do not leave orphans behind.
  for (const f of readdirSync(outDir)) {
    if (f.endsWith('.png') || f === 'INDEX.md') unlinkSync(join(outDir, f));
  }

  const browser = await puppeteer.launch({
    executablePath: chromePath,
    headless: 'new',
    args: ['--allow-file-access-from-files', '--force-device-scale-factor=1'],
    defaultViewport: { width: 1400, height: 1000 },
  });
  const page = await browser.newPage();

  page.on('pageerror', (e) => console.warn('pageerror:', e.message));
  const kitServer = await startKitServer(serveRoot);
  await page.goto(`${kitServer.origin}${navPath}`, { waitUntil: 'networkidle2', timeout: 120000 });

  // Babel-in-browser compile can take a while; wait for the rows to render.
  await page.waitForSelector('.mxg-row .mxg-frame', { timeout: 120000 });

  // Freeze animations/transitions so screenshots are deterministic.
  await page.addStyleTag({
    content: '*,*::before,*::after{animation:none!important;transition:none!important;caret-color:transparent!important}',
  });

  const rowCount = await page.$$eval('.mxg-row', (rows) => rows.length);
  console.log(`rows: ${rowCount}`);

  const manifest = [];
  let shotCount = 0;

  for (let r = 0; r < rowCount; r++) {
    const row = (await page.$$('.mxg-row'))[r];
    await row.evaluate((el) => el.scrollIntoView({ block: 'center' }));
    await sleep(350); // settle fonts/icons

    const head = await row.evaluate((el) => {
      const id = el.getAttribute('data-screen-label') ?? '';
      const title = el.querySelector('.mxg-row__title')?.textContent.trim() ?? '';
      const sub = el.querySelector('.mxg-row__sub')?.textContent.trim() ?? '';
      const total = Number(sub.match(/(\d+)\s*state/)?.[1] ?? 1);
      return { id, title, total };
    });
    const screenId = head.id || slug(head.title);
    const entry = { id: screenId, title: head.title, states: [] };
    console.log(`[${screenId}] ${head.title} — ${head.total} state(s)`);

    for (let s = 0; s < head.total; s++) {
      const stateLabel = await row.evaluate((el) => el.querySelector('.mxg-label')?.textContent.trim() ?? '');
      const stateSlug = slug(stateLabel) || `state-${s + 1}`;
      await sleep(400); // icons/skeleton re-render after each state remount

      const frames = await row.$$('.mxg-frame-wrap');
      const files = {};
      for (const wrap of frames) {
        const frame = await wrap.$('.mxg-frame');
        const theme = await frame.evaluate((el) => el.getAttribute('data-theme') || 'light');
        const file = `${screenId}--${stateSlug}--${theme}.png`;
        await frame.screenshot({ path: join(outDir, file) });
        files[theme] = file;
        shotCount++;
      }
      entry.states.push({ label: stateLabel, ...files });

      if (s < head.total - 1) {
        const next = await row.$('.mxg-stepper button[aria-label="Next state"]');
        await next.evaluate((el) => el.click());
        // No numeric counter in the new gallery — wait for the label text to change.
        await page.waitForFunction(
          (el, prev) => el.querySelector('.mxg-label')?.textContent.trim() !== prev,
          { timeout: 15000 },
          row,
          stateLabel,
        );
      }
    }
    manifest.push(entry);
  }

  // Agent-facing manifest: which file is the mock for which screen/state.
  const lines = [
    '# UI Kit Screenshots — Manifest',
    '',
    'Auto-generated by `tool/ui_kit_shots/export_shots.mjs`. Do not edit by hand;',
    're-run the exporter after any change to the kit `index.html` / screen `.jsx`.',
    '',
    'Every screen state ships as a light + dark PNG pair at 390px width. These PNGs',
    'are the canonical visual mock reference for UI tasks — read the PNG, not the',
    'kit JSX source. Files are named `<screen-id>--<state>--<theme>.png`.',
    '',
  ];
  for (const e of manifest) {
    lines.push(`## ${e.id} — ${e.title}`, '');
    lines.push('| State | Light | Dark |');
    lines.push('| --- | --- | --- |');
    for (const st of e.states) {
      lines.push(`| ${st.label} | \`${st.light ?? '—'}\` | \`${st.dark ?? '—'}\` |`);
    }
    lines.push('');
  }
  const totalStates = manifest.reduce((n, e) => n + e.states.length, 0);
  lines.push(`Total: ${manifest.length} screens · ${totalStates} states · ${shotCount} PNGs.`, '');
  writeFileSync(join(outDir, 'INDEX.md'), lines.join('\n'));

  console.log(`done: ${manifest.length} screens, ${totalStates} states, ${shotCount} shots -> ${outDir}`);
  await browser.close();
  await kitServer.close();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
