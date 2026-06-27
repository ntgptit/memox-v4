import 'package:memox_v4/domain/entities/language_pair.dart';

/// App-wide pair context read-model: every pair, the resolved active pair, and
/// the display direction. Pure domain read-model assembled by
/// `GetPairContextUseCase`; the presentation layer exposes it as provider state.
class LanguagePairContext {
  const LanguagePairContext({
    this.pairs = const <LanguagePair>[],
    this.active,
    this.displaySwapped = false,
  });

  /// Every pair, ordered for display.
  final List<LanguagePair> pairs;

  /// The active learning context, or null when no pair exists yet.
  final LanguagePair? active;

  /// Whether the active pair shows the target language as the question side.
  final bool displaySwapped;

  bool get isEmpty => pairs.isEmpty;
}
