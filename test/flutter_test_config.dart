import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Suite-wide setup (Flutter auto-discovers `test/flutter_test_config.dart` and
/// wraps every test with it). Loads the real fonts so golden tests render actual
/// glyphs instead of the fallback test font — without this, any text/icon golden
/// would be meaningless.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Text font (Plus Jakarta Sans). Plus Jakarta has no CJK glyphs, so seeded
  // Korean terms (학교, 사과 …) would render as tofu boxes in goldens. Flutter test
  // does NOT fall back across families for a widget's explicit `fontFamily`, so we
  // load a per-weight font that MERGES Plus Jakarta's Latin with a tiny OFL Noto
  // Sans KR subset (only the Hangul the fixtures use) — the glyphs live in the SAME
  // family the widgets request, so both render at the right weight. Test-only
  // assets (test/fonts/pjs-cjk-*.ttf), NOT bundled in the app; regenerate with
  // `python tool/design/build_cjk_test_font.py` if new Korean fixtures appear.
  // Falls back to the plain app font if the merged set is absent.
  final pjs = FontLoader('Plus Jakarta Sans');
  var loadedMerged = false;
  for (final weight in [400, 500, 600, 700, 800]) {
    final f = File('test/fonts/pjs-cjk-$weight.ttf');
    if (!f.existsSync()) continue;
    pjs.addFont(Future<ByteData>.value(ByteData.sublistView(f.readAsBytesSync())));
    loadedMerged = true;
  }
  if (!loadedMerged) {
    final bytes = File('assets/fonts/PlusJakartaSans.ttf').readAsBytesSync();
    pjs.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  }
  await pjs.load();

  // Every font declared in the built asset manifest — crucially MaterialIcons
  // (bundled via `uses-material-design: true`). Without it, icon glyphs render as
  // tofu boxes in goldens and pollute the kit↔Flutter visual diff.
  await _loadManifestFonts();

  return testMain();
}

Future<void> _loadManifestFonts() async {
  final String manifestJson;
  try {
    manifestJson = await rootBundle.loadString('FontManifest.json');
  } catch (_) {
    return; // no manifest in this test bundle — nothing to load
  }
  final manifest = json.decode(manifestJson) as List<dynamic>;
  for (final entry in manifest) {
    final family = entry['family'] as String;
    final loader = FontLoader(family);
    for (final font in entry['fonts'] as List<dynamic>) {
      final asset = font['asset'] as String?;
      if (asset != null) loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
}
