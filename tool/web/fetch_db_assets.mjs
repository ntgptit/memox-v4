#!/usr/bin/env node
// @ts-check
/**
 * fetch_db_assets.mjs — download the web Drift runtime assets pinned to the
 * versions in `pubspec.lock`, into `web/`:
 *   - web/sqlite3.wasm     (from the resolved `sqlite3` package version)
 *   - web/drift_worker.js  (from the resolved `drift` package version)
 *
 * Re-run this whenever the `drift` or `sqlite3` versions change (a mismatch
 * between the Dart package and the wasm/worker can crash the web DB at runtime).
 * Native (mobile/desktop) needs no assets — this is web-only.
 *
 *   node tool/web/fetch_db_assets.mjs
 */
import { createWriteStream, readFileSync } from 'node:fs';
import { get } from 'node:https';
import { join } from 'node:path';

const ROOT = process.cwd();
const WEB = join(ROOT, 'web');

/** Read a package's resolved version from pubspec.lock (line-based, robust). */
function lockedVersion(pkg) {
  const lines = readFileSync(join(ROOT, 'pubspec.lock'), 'utf8').split(/\r?\n/);
  const start = lines.findIndex((l) => l === `  ${pkg}:`);
  if (start === -1) throw new Error(`no ${pkg}: block in pubspec.lock`);
  for (let i = start + 1; i < lines.length; i++) {
    if (/^  \S/.test(lines[i])) break; // next top-level package block
    const m = lines[i].match(/^    version: "([^"]+)"/);
    if (m) return m[1];
  }
  throw new Error(`no version for ${pkg} in pubspec.lock`);
}

/** Download url → dest, following redirects (GitHub release assets redirect). */
function download(url, dest) {
  return new Promise((resolve, reject) => {
    get(url, (res) => {
      if (res.statusCode && res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        res.resume();
        return download(res.headers.location, dest).then(resolve, reject);
      }
      if (res.statusCode !== 200) {
        res.resume();
        return reject(new Error(`HTTP ${res.statusCode} for ${url}`));
      }
      const file = createWriteStream(dest);
      res.pipe(file);
      file.on('finish', () => file.close(() => resolve(dest)));
      file.on('error', reject);
    }).on('error', reject);
  });
}

const drift = lockedVersion('drift');
const sqlite3 = lockedVersion('sqlite3');

const assets = [
  {
    name: 'drift_worker.js',
    url: `https://github.com/simolus3/drift/releases/download/drift-${drift}/drift_worker.js`,
  },
  {
    name: 'sqlite3.wasm',
    url: `https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-${sqlite3}/sqlite3.wasm`,
  },
];

console.log(`drift=${drift}  sqlite3=${sqlite3}`);
for (const a of assets) {
  process.stdout.write(`  ${a.name} … `);
  await download(a.url, join(WEB, a.name));
  console.log('done');
}
console.log('✓ web DB assets up to date');
