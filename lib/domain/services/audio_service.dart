import 'package:memox_v4/core/error/result.dart';

/// Reads a term aloud via device text-to-speech (flashcard editor + player),
/// using the pair's source-language voice.
///
/// v1 scope: only live [speak]/[stop] ship. Generating + storing audio files
/// (`card.audioRef`) is deferred, so the DT.7 adapter implements speaking but the
/// persisted-audio path stays a documented gap — the contract is defined so
/// screens depend on the seam, not the plugin.
abstract interface class AudioService {
  /// Speak [text] in [languageCode]. [rate] is the relative playback speed
  /// (`1.0` = normal; the player passes the learner's chosen rate). The real
  /// flutter_tts adapter maps it to `setSpeechRate`; the no-op adapter accepts it.
  Future<Result<void>> speak(
    String text, {
    required String languageCode,
    double rate = 1.0,
  });
  Future<Result<void>> stop();
}
