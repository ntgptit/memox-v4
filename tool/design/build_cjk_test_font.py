#!/usr/bin/env python3
"""Build the per-weight CJK test fonts used by golden tests (test/fonts/pjs-cjk-*.ttf).

Plus Jakarta Sans has no CJK glyphs, and `flutter test` does not fall back across
font families for a widget's explicit `fontFamily`. So seeded Korean terms (학교 …)
would render as tofu boxes in goldens. This script bakes the Hangul the fixtures
actually use INTO Plus Jakarta (same family, per weight) so both render.

These are TEST-ONLY assets (not bundled in the app — the app relies on the OS CJK
fallback at runtime). Re-run this only when new Korean fixtures appear (the visual
diff will flag the tofu). Requires: fonttools, network (downloads Noto Sans KR OFL).

    python tool/design/build_cjk_test_font.py

Deps: pip install fonttools ; source font: Noto Sans KR (SIL OFL 1.1).
"""
import os
import sys
import urllib.request
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont
from fontTools.merge import Merger

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PJS = os.path.join(ROOT, "assets", "fonts", "PlusJakartaSans.ttf")
OUT_DIR = os.path.join(ROOT, "test", "fonts")
WEIGHTS = [400, 500, 600, 700, 800]
NOTO_URL = "https://github.com/google/fonts/raw/main/ofl/notosanskr/NotoSansKR%5Bwght%5D.ttf"
# Minimal, identical table set on both fonts so fontTools.merge can reconcile them.
KEEP = {"glyf", "loca", "cmap", "hmtx", "head", "hhea", "maxp", "name", "OS/2", "post", "GlyphOrder"}


def hangul_used():
    """Every Hangul codepoint appearing in test/ + lib/ Dart sources."""
    chars = set()
    for base in ("test", "lib"):
        for dp, _, files in os.walk(os.path.join(ROOT, base)):
            for f in files:
                if not f.endswith(".dart"):
                    continue
                try:
                    text = open(os.path.join(dp, f), encoding="utf-8").read()
                except OSError:
                    continue
                for ch in text:
                    if "가" <= ch <= "힣" or "ᄀ" <= ch <= "ᇿ":
                        chars.add(ch)
    return "".join(sorted(chars))


def minimize(font):
    for tag in list(font.keys()):
        if tag not in KEEP:
            del font[tag]
    return font


def main():
    chars = hangul_used()
    if not chars:
        print("no Hangul in fixtures — nothing to build")
        return
    print(f"Hangul used by fixtures ({len(chars)}): {chars}")

    cache = os.path.join(OUT_DIR, "_NotoSansKR-src.ttf")
    os.makedirs(OUT_DIR, exist_ok=True)
    if not os.path.exists(cache):
        print("downloading Noto Sans KR (OFL) …")
        urllib.request.urlretrieve(NOTO_URL, cache)

    # Noto → static Regular, subset to the used Hangul, minimize tables.
    noto = TTFont(cache)
    instantiateVariableFont(noto, {"wght": 400}, inplace=True)
    from fontTools.subset import Subsetter, Options
    ss = Subsetter(options=Options(hinting=False, desubroutinize=True))
    ss.populate(unicodes=[ord(c) for c in chars])
    ss.subset(noto)
    noto = minimize(noto)
    noto_path = os.path.join(OUT_DIR, "_noto-min.ttf")
    noto.save(noto_path)

    for w in WEIGHTS:
        pjs = TTFont(PJS)
        instantiateVariableFont(pjs, {"wght": w}, inplace=True)
        pjs = minimize(pjs)
        pjs_path = os.path.join(OUT_DIR, f"_pjs-{w}.ttf")
        pjs.save(pjs_path)
        out = os.path.join(OUT_DIR, f"pjs-cjk-{w}.ttf")
        Merger().merge([pjs_path, noto_path]).save(out)
        os.remove(pjs_path)
        print(f"  wght {w}: {os.path.getsize(out)} bytes → {os.path.relpath(out, ROOT)}")

    os.remove(noto_path)
    print("done. (delete test/fonts/_NotoSansKR-src.ttf to force a fresh download)")


if __name__ == "__main__":
    sys.exit(main())
