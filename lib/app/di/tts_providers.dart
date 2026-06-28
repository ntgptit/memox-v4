import 'package:memox_v4/data/services/flutter_tts_service.dart';
import 'package:memox_v4/domain/services/tts_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_providers.g.dart';

/// Text-to-speech for card terms. Tests override with a fake — the real plugin
/// is platform-channel only.
@Riverpod(keepAlive: true)
TtsService ttsService(Ref ref) => FlutterTtsService();
