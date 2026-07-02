import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Suite-wide setup (Flutter auto-discovers `test/flutter_test_config.dart` and
/// wraps every test with it). Loads the real Plus Jakarta Sans font so golden
/// tests render actual glyphs instead of the fallback test font — without this,
/// any text golden would be meaningless.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final bytes = File('assets/fonts/PlusJakartaSans.ttf').readAsBytesSync();
  final loader = FontLoader('Plus Jakarta Sans')
    ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  await loader.load();

  return testMain();
}
