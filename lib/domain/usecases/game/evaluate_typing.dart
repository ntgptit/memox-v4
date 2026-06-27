import 'dart:math';

/// Tolerant match for the Typing game: case/whitespace-insensitive, accepting a
/// single-character typo (Levenshtein ≤ 1) (`docs/business/game/game-modes.md`).
class EvaluateTypingUseCase {
  const EvaluateTypingUseCase();

  bool call(String input, String target) {
    final a = _normalize(input);
    final b = _normalize(target);
    if (a.isEmpty) return false;
    if (a == b) return true;
    return _levenshtein(a, b) <= 1;
  }

  String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  int _levenshtein(String a, String b) {
    final previous = List<int>.generate(b.length + 1, (i) => i);
    final current = List<int>.filled(b.length + 1, 0);
    for (var i = 0; i < a.length; i++) {
      current[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final cost = a[i] == b[j] ? 0 : 1;
        current[j + 1] = [
          current[j] + 1,
          previous[j + 1] + 1,
          previous[j] + cost,
        ].reduce(min);
      }
      previous.setAll(0, current);
    }
    return previous[b.length];
  }
}
