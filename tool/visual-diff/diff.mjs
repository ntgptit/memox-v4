#!/usr/bin/env node
// @ts-check
/**
 * tool/visual-diff/diff.mjs — kit ↔ Flutter visual-parity diff (golden-parity G.2).
 *
 * Compares each Flutter screen golden against the committed KIT shot of the same
 * `<screen>--<state>--<theme>` name. The kit shot is the source of truth (frozen,
 * exported from Claude Design at 390×780 — the same size the goldens render at),
 * so this is the visual-parity check: does the Flutter build actually look like
 * the kit?
 *
 * It is a PERCEPTUAL diff (not exact): kit shots are browser-rendered and goldens
 * are Skia-rendered, so anti-aliasing / font hinting differ pixel-for-pixel even
 * when visually identical. We port pixelmatch's YIQ colour delta so those
 * sub-threshold differences don't count; only real divergences (missing element,
 * wrong layout/colour, absent state) push a state's mismatch % up. The output is
 * a worst-first ranking so you triage the biggest divergences.
 *
 * Dependency-free by design (repo convention): PNG decode/encode via node:zlib.
 * Supports 8-bit non-interlaced greyscale/RGB/RGBA PNGs (what both sides emit).
 *
 * Usage:
 *   node tool/visual-diff/diff.mjs                 # compare, print ranked table
 *   node tool/visual-diff/diff.mjs --html out.html # + write a visual HTML report
 *   node tool/visual-diff/diff.mjs --fail-over 8   # exit 1 if any state > 8% mismatch (CI gate)
 *   node tool/visual-diff/diff.mjs --filter statistics   # only names containing "statistics"
 *   node tool/visual-diff/diff.mjs --threshold 0.1 --kit <dir> --goldens <dir>
 */

import { readFileSync, writeFileSync, readdirSync, existsSync, mkdirSync } from 'node:fs';
import { inflateSync, deflateSync } from 'node:zlib';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const REPO = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const DEFAULT_KIT = join(
  REPO, 'docs', 'design', 'MemoX Design System', 'ui_kits', 'memox-app', 'shots',
);
const DEFAULT_GOLDENS = join(REPO, 'test', 'golden', 'goldens', 'screens');

// ── args ────────────────────────────────────────────────────────────────────
const argv = process.argv.slice(2);
const flag = (name, fallback = null) => {
  const i = argv.indexOf(name);
  return i >= 0 && i + 1 < argv.length ? argv[i + 1] : fallback;
};
const KIT_DIR = flag('--kit', DEFAULT_KIT);
const GOLDENS_DIR = flag('--goldens', DEFAULT_GOLDENS);
const THRESHOLD = Number(flag('--threshold', '0.1')); // pixelmatch colour threshold
const FAIL_OVER = flag('--fail-over') != null ? Number(flag('--fail-over')) : null;
const HTML = flag('--html');
const FILTER = flag('--filter');
const LIMIT = flag('--limit') != null ? Number(flag('--limit')) : null;
// Ratchet gate: strict cross-renderer pixel parity is impossible (Skia vs browser
// AA + intentionally different seeded content), so instead of an absolute
// threshold we compare each state to a committed per-state baseline and fail only
// when it diverges MORE than baseline + tolerance — catching regressions (a
// Flutter change that pulls a screen further from the kit) while accepting the
// existing, expected noise. Baselines are platform-specific (Skia render), so they
// must be written from the SAME platform CI runs on (ubuntu) — never Windows.
const WRITE_BASELINE = flag('--write-baseline');
const BASELINE = flag('--baseline');
const TOLERANCE = Number(flag('--tolerance', '2')); // extra % a state may drift before failing

// ── PNG signature ─────────────────────────────────────────────────────────────
const PNG_SIG = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);

// ── PNG decode → {width, height, data(RGBA)} ─────────────────────────────────
function decodePng(path) {
  const buf = readFileSync(path);
  if (!buf.subarray(0, 8).equals(PNG_SIG)) throw new Error(`not a PNG: ${path}`);
  let pos = 8;
  let width = 0, height = 0, bitDepth = 0, colorType = 0, interlace = 0;
  const idat = [];
  while (pos + 8 <= buf.length) {
    const len = buf.readUInt32BE(pos);
    const type = buf.toString('ascii', pos + 4, pos + 8);
    const data = buf.subarray(pos + 8, pos + 8 + len);
    pos += 12 + len; // len(4) + type(4) + data + crc(4)
    if (type === 'IHDR') {
      width = data.readUInt32BE(0);
      height = data.readUInt32BE(4);
      bitDepth = data[8];
      colorType = data[9];
      interlace = data[12];
    } else if (type === 'IDAT') {
      idat.push(data);
    } else if (type === 'IEND') {
      break;
    }
  }
  if (bitDepth !== 8) throw new Error(`unsupported bitDepth ${bitDepth}: ${path}`);
  if (interlace !== 0) throw new Error(`interlaced PNG unsupported: ${path}`);
  const channels = { 0: 1, 2: 3, 6: 4 }[colorType];
  if (!channels) throw new Error(`unsupported colorType ${colorType}: ${path}`);

  const raw = inflateSync(Buffer.concat(idat));
  const bpp = channels;
  const stride = width * bpp;
  const out = Buffer.alloc(width * height * 4);
  let line = Buffer.alloc(stride);
  let prev = Buffer.alloc(stride);
  let rp = 0;
  for (let y = 0; y < height; y++) {
    const filter = raw[rp++];
    for (let x = 0; x < stride; x++) {
      const rb = raw[rp++];
      const a = x >= bpp ? line[x - bpp] : 0;
      const b = prev[x];
      const c = x >= bpp ? prev[x - bpp] : 0;
      let v;
      switch (filter) {
        case 0: v = rb; break;
        case 1: v = rb + a; break;
        case 2: v = rb + b; break;
        case 3: v = rb + ((a + b) >> 1); break;
        case 4: v = rb + paeth(a, b, c); break;
        default: throw new Error(`bad PNG filter ${filter}: ${path}`);
      }
      line[x] = v & 0xff;
    }
    for (let x = 0; x < width; x++) {
      const si = x * bpp;
      const di = (y * width + x) * 4;
      if (channels === 4) {
        out[di] = line[si]; out[di + 1] = line[si + 1];
        out[di + 2] = line[si + 2]; out[di + 3] = line[si + 3];
      } else if (channels === 3) {
        out[di] = line[si]; out[di + 1] = line[si + 1];
        out[di + 2] = line[si + 2]; out[di + 3] = 255;
      } else {
        out[di] = out[di + 1] = out[di + 2] = line[si]; out[di + 3] = 255;
      }
    }
    const swap = prev; prev = line; line = swap; // reuse buffers; prev := this line
  }
  return { width, height, data: out };
}

function paeth(a, b, c) {
  const p = a + b - c;
  const pa = Math.abs(p - a), pb = Math.abs(p - b), pc = Math.abs(p - c);
  if (pa <= pb && pa <= pc) return a;
  if (pb <= pc) return b;
  return c;
}

// ── PNG encode (RGBA, filter 0) — for the diff heatmap ───────────────────────
const CRC_TABLE = (() => {
  const t = new Int32Array(256);
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    t[n] = c;
  }
  return t;
})();
function crc32(buf) {
  let c = ~0;
  for (let i = 0; i < buf.length; i++) c = CRC_TABLE[(c ^ buf[i]) & 0xff] ^ (c >>> 8);
  return ~c;
}
function pngChunk(type, data) {
  const t = Buffer.from(type, 'ascii');
  const len = Buffer.alloc(4); len.writeUInt32BE(data.length, 0);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(Buffer.concat([t, data])) >>> 0, 0);
  return Buffer.concat([len, t, data, crc]);
}
function encodePng(width, height, rgba) {
  const stride = width * 4;
  const raw = Buffer.alloc((stride + 1) * height);
  for (let y = 0; y < height; y++) {
    raw[y * (stride + 1)] = 0; // filter: none
    rgba.copy(raw, y * (stride + 1) + 1, y * stride, y * stride + stride);
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8; ihdr[9] = 6; // 8-bit RGBA
  return Buffer.concat([
    PNG_SIG,
    pngChunk('IHDR', ihdr),
    pngChunk('IDAT', deflateSync(raw)),
    pngChunk('IEND', Buffer.alloc(0)),
  ]);
}

// ── pixelmatch YIQ colour delta ──────────────────────────────────────────────
const rgb2y = (r, g, b) => r * 0.29889531 + g * 0.58662247 + b * 0.11448223;
const rgb2i = (r, g, b) => r * 0.59597799 - g * 0.27417610 - b * 0.32180189;
const rgb2q = (r, g, b) => r * 0.21147017 - g * 0.52261711 + b * 0.31114694;
const MAX_YIQ = 35215; // max possible YIQ delta (pixelmatch constant)

/** Squared YIQ distance between pixel `k*4` of a and b (alpha blended on white). */
function colorDelta(a, b, k) {
  const i = k * 4;
  let r1 = a[i], g1 = a[i + 1], b1 = a[i + 2];
  let r2 = b[i], g2 = b[i + 1], b2 = b[i + 2];
  const al1 = a[i + 3], al2 = b[i + 3];
  if (al1 < 255) { const f = al1 / 255; r1 = 255 + (r1 - 255) * f; g1 = 255 + (g1 - 255) * f; b1 = 255 + (b1 - 255) * f; }
  if (al2 < 255) { const f = al2 / 255; r2 = 255 + (r2 - 255) * f; g2 = 255 + (g2 - 255) * f; b2 = 255 + (b2 - 255) * f; }
  const y = rgb2y(r1, g1, b1) - rgb2y(r2, g2, b2);
  const iq = rgb2i(r1, g1, b1) - rgb2i(r2, g2, b2);
  const q = rgb2q(r1, g1, b1) - rgb2q(r2, g2, b2);
  return 0.5053 * y * y + 0.299 * iq * iq + 0.1957 * q * q;
}

/** Compare two decoded images → {diff, total, pct, heatmap(RGBA)}. */
function comparePixels(kit, gold) {
  const { width, height } = kit;
  const total = width * height;
  const maxDelta = MAX_YIQ * THRESHOLD * THRESHOLD;
  const heatmap = Buffer.alloc(total * 4);
  let diff = 0;
  for (let k = 0; k < total; k++) {
    const delta = colorDelta(kit.data, gold.data, k);
    const di = k * 4;
    if (delta > maxDelta) {
      diff++;
      heatmap[di] = 255; heatmap[di + 1] = 40; heatmap[di + 2] = 40; heatmap[di + 3] = 255;
    } else {
      // faded greyscale of the golden, so divergences pop against context
      const g = (gold.data[di] * 0.3 + gold.data[di + 1] * 0.59 + gold.data[di + 2] * 0.11);
      const v = Math.round(255 - (255 - g) * 0.25);
      heatmap[di] = heatmap[di + 1] = heatmap[di + 2] = v; heatmap[di + 3] = 255;
    }
  }
  return { diff, total, pct: (diff / total) * 100, heatmap, width, height };
}

// ── run ──────────────────────────────────────────────────────────────────────
if (!existsSync(GOLDENS_DIR)) {
  console.error(`✗ goldens dir not found: ${GOLDENS_DIR}`);
  console.error('  Generate them first: flutter test --tags golden-parity --update-goldens');
  process.exit(2);
}
const pngs = (dir) => new Set(readdirSync(dir).filter((f) => f.endsWith('.png')));
const kitSet = pngs(KIT_DIR);
const goldSet = pngs(GOLDENS_DIR);

let names = [...goldSet].filter((f) => kitSet.has(f)).sort();
if (FILTER) names = names.filter((f) => f.includes(FILTER));
if (LIMIT != null) names = names.slice(0, LIMIT);

const onlyGold = [...goldSet].filter((f) => !kitSet.has(f) && (!FILTER || f.includes(FILTER)));
const onlyKit = [...kitSet].filter((f) => !goldSet.has(f) && (!FILTER || f.includes(FILTER)));

if (!names.length) {
  console.error('✗ no shared <screen>--<state>--<theme>.png names between kit and goldens.');
  process.exit(2);
}

const results = [];
for (const name of names) {
  try {
    const kit = decodePng(join(KIT_DIR, name));
    const gold = decodePng(join(GOLDENS_DIR, name));
    if (kit.width !== gold.width || kit.height !== gold.height) {
      results.push({ name, pct: 100, note: `size ${gold.width}x${gold.height} vs kit ${kit.width}x${kit.height}` });
      continue;
    }
    const r = comparePixels(kit, gold);
    results.push({ name, pct: r.pct, diff: r.diff, total: r.total, heatmap: r.heatmap, width: r.width, height: r.height });
  } catch (e) {
    results.push({ name, pct: 100, note: `error: ${e.message}` });
  }
}

results.sort((a, b) => b.pct - a.pct);

// ── text report ───────────────────────────────────────────────────────────────
const mean = results.reduce((s, r) => s + r.pct, 0) / results.length;
console.log(`\nvisual-parity diff — ${results.length} states compared (threshold ${THRESHOLD})`);
console.log(`kit:     ${KIT_DIR}`);
console.log(`goldens: ${GOLDENS_DIR}`);
console.log(`mean mismatch: ${mean.toFixed(2)}%   (worst-first)\n`);
for (const r of results.slice(0, LIMIT ?? 40)) {
  const bar = '█'.repeat(Math.min(30, Math.round(r.pct))) || '·';
  console.log(`  ${r.pct.toFixed(2).padStart(6)}%  ${bar.padEnd(30)}  ${r.name}${r.note ? '  (' + r.note + ')' : ''}`);
}
if (onlyGold.length) console.log(`\n  ${onlyGold.length} golden(s) with no kit shot (skipped): ${onlyGold.slice(0, 6).join(', ')}${onlyGold.length > 6 ? '…' : ''}`);
if (onlyKit.length) console.log(`  ${onlyKit.length} kit shot(s) with no golden (skipped)`);

// ── HTML report ───────────────────────────────────────────────────────────────
if (HTML) {
  const dataUri = (path) => `data:image/png;base64,${readFileSync(path).toString('base64')}`;
  const heatUri = (r) => `data:image/png;base64,${encodePng(r.width, r.height, r.heatmap).toString('base64')}`;
  // Embedding every state's 3 full-res PNGs would be huge; the report is for
  // triage, so show the worst `--html-top` (default 24) states.
  const htmlTop = flag('--html-top') != null ? Number(flag('--html-top')) : 24;
  const shown = results.slice(0, htmlTop);
  const rows = shown.map((r) => {
    const kitImg = existsSync(join(KIT_DIR, r.name)) ? `<img src="${dataUri(join(KIT_DIR, r.name))}">` : '—';
    const goldImg = existsSync(join(GOLDENS_DIR, r.name)) ? `<img src="${dataUri(join(GOLDENS_DIR, r.name))}">` : '—';
    const heat = r.heatmap ? `<img src="${heatUri(r)}">` : `<div class="err">${r.note || ''}</div>`;
    const cls = r.pct > 8 ? 'high' : r.pct > 3 ? 'mid' : 'low';
    return `<tr class="${cls}"><td class="pct">${r.pct.toFixed(2)}%</td><td class="nm">${r.name}${r.note ? `<br><small>${r.note}</small>` : ''}</td><td>${kitImg}</td><td>${goldImg}</td><td>${heat}</td></tr>`;
  }).join('\n');
  const html = `<!doctype html><meta charset="utf-8"><title>Visual parity — kit ↔ Flutter</title>
<style>
 body{font:13px system-ui,sans-serif;margin:24px;background:#fafafa;color:#1a1a1a}
 h1{font-size:18px} .meta{color:#666;margin-bottom:16px}
 table{border-collapse:collapse;width:100%} th,td{border-bottom:1px solid #e5e5e5;padding:8px;vertical-align:top;text-align:left}
 th{position:sticky;top:0;background:#fff}
 img{width:180px;height:auto;border:1px solid #ddd;background:#fff;image-rendering:pixelated}
 .pct{font-weight:700;font-variant-numeric:tabular-nums} .nm{font-family:ui-monospace,monospace;white-space:nowrap}
 tr.high .pct{color:#c62828} tr.mid .pct{color:#e07800} tr.low .pct{color:#2e7d32}
 .err{color:#c62828;font-family:monospace} small{color:#888}
</style>
<h1>Visual parity — kit ↔ Flutter</h1>
<div class="meta">${results.length} states · threshold ${THRESHOLD} · mean ${mean.toFixed(2)}% · showing worst ${shown.length}.
Red = pixels exceeding the perceptual threshold (real divergence); grey = matches. Cross-renderer AA + intentionally different seeded content inflate the score — use this to TRIAGE the biggest divergences, not as a pass/fail.</div>
<table><thead><tr><th>mismatch</th><th>state</th><th>kit shot</th><th>flutter golden</th><th>diff</th></tr></thead>
<tbody>${rows}</tbody></table>`;
  mkdirSync(dirname(HTML), { recursive: true });
  writeFileSync(HTML, html, 'utf8');
  console.log(`\n✓ HTML report → ${HTML}`);
}

// ── write baseline (seed the ratchet — run on ubuntu/CI only) ─────────────────
if (WRITE_BASELINE) {
  const baseline = {};
  for (const r of results) baseline[r.name] = Number(r.pct.toFixed(3));
  mkdirSync(dirname(WRITE_BASELINE), { recursive: true });
  writeFileSync(WRITE_BASELINE, JSON.stringify(baseline, null, 2) + '\n', 'utf8');
  console.log(`\n✓ baseline (${results.length} states) → ${WRITE_BASELINE}`);
}

// ── ratchet gate against a committed baseline ─────────────────────────────────
if (BASELINE && !existsSync(BASELINE)) {
  // Non-fatal: the ratchet just isn't armed yet. Seed it on ubuntu/CI with
  // --write-baseline (workflow_dispatch), then this gate activates.
  console.log(`\n• baseline not seeded yet (${BASELINE}) — ratchet skipped. Seed it on CI with --write-baseline.`);
} else if (BASELINE) {
  const base = JSON.parse(readFileSync(BASELINE, 'utf8'));
  const regressions = results.filter((r) => base[r.name] != null && r.pct > base[r.name] + TOLERANCE);
  const novel = results.filter((r) => base[r.name] == null);
  if (novel.length) console.log(`\n  ${novel.length} state(s) not in baseline (add via --write-baseline): ${novel.slice(0, 6).map((r) => r.name).join(', ')}${novel.length > 6 ? '…' : ''}`);
  if (regressions.length) {
    console.error(`\n✗ ${regressions.length} state(s) diverged > baseline + ${TOLERANCE}%:`);
    for (const r of regressions) console.error(`    ${r.pct.toFixed(2)}% (was ${base[r.name]}%)  ${r.name}`);
    process.exit(1);
  }
  console.log(`\n✓ no visual regression: all ${results.length} states within baseline + ${TOLERANCE}%`);
}

// ── absolute catastrophic gate (cross-platform-safe: a blank/errored/mis-sized
// screen is ~100% on any renderer) ──────────────────────────────────────────
if (FAIL_OVER != null) {
  const over = results.filter((r) => r.pct > FAIL_OVER);
  if (over.length) {
    console.error(`\n✗ ${over.length} state(s) exceed ${FAIL_OVER}% mismatch:`);
    for (const r of over) console.error(`    ${r.pct.toFixed(2)}%  ${r.name}${r.note ? '  (' + r.note + ')' : ''}`);
    process.exit(1);
  }
  console.log(`\n✓ all ${results.length} states within ${FAIL_OVER}% mismatch`);
}
