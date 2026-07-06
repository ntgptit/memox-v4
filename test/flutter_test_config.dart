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

  // Text font (Plus Jakarta Sans) read straight off disk.
  final bytes = File('assets/fonts/PlusJakartaSans.ttf').readAsBytesSync();
  final loader = FontLoader('Plus Jakarta Sans')
    ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  await loader.load();

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
