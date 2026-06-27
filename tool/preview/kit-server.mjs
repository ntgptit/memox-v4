// Minimal static server for previewing the MemoX UI kit gallery over HTTP.
// Needed because the gallery loads screen modules via <script type="text/babel"
// src="*.jsx">, and Babel-standalone cannot fetch those files over file:// (CORS).
// Root is the design-system folder; "/" redirects to the gallery so the preview
// panel lands on it directly.
import http from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import { join, extname, normalize, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const ROOT = join(HERE, '..', '..', 'docs', 'design', 'MemoX Design System');
const GALLERY = '/ui_kits/memox-app/index.html';
const PORT = process.env.PORT || 4599;
const TYPES = {
  '.html': 'text/html; charset=utf-8', '.js': 'application/javascript; charset=utf-8',
  '.jsx': 'application/javascript; charset=utf-8', '.css': 'text/css; charset=utf-8',
  '.ttf': 'font/ttf', '.png': 'image/png', '.json': 'application/json; charset=utf-8', '.svg': 'image/svg+xml',
};

http.createServer(async (req, res) => {
  const url = decodeURIComponent(req.url.split('?')[0]);
  if (url === '/' || url === '') { res.writeHead(302, { Location: GALLERY }); res.end(); return; }
  const file = join(ROOT, normalize(url).replace(/^[/\\]+/, ''));
  if (!file.startsWith(ROOT)) { res.writeHead(403); res.end('forbidden'); return; }
  try {
    if ((await stat(file)).isDirectory()) { res.writeHead(404); res.end('dir'); return; }
    res.writeHead(200, { 'Content-Type': TYPES[extname(file).toLowerCase()] || 'application/octet-stream', 'Access-Control-Allow-Origin': '*' });
    res.end(await readFile(file));
  } catch { res.writeHead(404); res.end('not found'); }
}).listen(PORT, () => console.log('MemoX kit preview → http://localhost:' + PORT + GALLERY));
