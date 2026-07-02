import 'package:memox_v4/core/error/result.dart';

/// Reads a term aloud via device text-to-speech (flashcard editor + player),
/// using the pair's source-language voice.
///
/// v1 scope: only live [speak]/[stop] ship. Generating + storing audio files
/// (`card.audioRef`) is deferred, so the DT.7 adapter implements speaking but the
/// persisted-audio path stays a documented gap — the contract is defined so
/// screens depend on the seam, not the plugin.
abstract interface class AudioService {
  Future<Result<void>> speak(String text, {required String languageCode});
  Future<Result<void>> stop();
}
