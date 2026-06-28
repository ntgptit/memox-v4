/// Speaks card terms aloud. Implemented in the data layer over `flutter_tts`;
/// abstracted so callers (editor / player) stay testable.
abstract interface class TtsService {
  /// Speaks [text] (optionally in [languageCode], BCP-47 best-effort). Stops any
  /// in-flight utterance first; a blank [text] is a no-op.
  Future<void> speak(String text, {String? languageCode});

  /// Stops any in-flight utterance.
  Future<void> stop();
}
