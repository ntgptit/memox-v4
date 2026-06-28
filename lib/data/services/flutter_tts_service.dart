import 'package:flutter_tts/flutter_tts.dart';
import 'package:memox_v4/domain/services/tts_service.dart';

/// `flutter_tts`-backed [TtsService].
class FlutterTtsService implements TtsService {
  FlutterTtsService([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;

  @override
  Future<void> speak(String text, {String? languageCode}) async {
    final value = text.trim();
    if (value.isEmpty) return;
    await _tts.stop();
    if (languageCode != null && languageCode.isNotEmpty) {
      await _tts.setLanguage(languageCode);
    }
    await _tts.speak(value);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }
}
