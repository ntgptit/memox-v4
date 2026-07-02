import 'package:equatable/equatable.dart';
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/ids.dart';

/// A learning context (`Cặp ngôn ngữ`): the language being learned plus the
/// learner's own language. Every piece of content belongs to one pair; the
/// display direction can be reversed but both directions share one SRS schedule
/// (D-011), so direction is not modeled here.
class LanguagePair extends Equatable {
  const LanguagePair._({
    required this.id,
    required this.learningLanguage,
    required this.nativeLanguage,
  });

  /// Validated construction (D-030): both language codes must be non-empty and
  /// they must differ — a pair can't learn a language into itself. Either case
  /// yields a [ValidationFailure] and no pair is created.
  static Result<LanguagePair> create({
    required LanguagePairId id,
    required String learningLanguage,
    required String nativeLanguage,
  }) {
    final learning = learningLanguage.trim();
    final native = nativeLanguage.trim();
    if (learning.isEmpty || native.isEmpty) {
      return const Err(
        ValidationFailure('A language pair needs both a learning and a native language'),
      );
    }
    if (learning.toLowerCase() == native.toLowerCase()) {
      return const Err(
        ValidationFailure('A language pair cannot learn a language into itself'),
      );
    }
    return Ok(
      LanguagePair._(
        id: id,
        learningLanguage: learning,
        nativeLanguage: native,
      ),
    );
  }

  final LanguagePairId id;

  /// The language on the term (question) side — the one being learned.
  final String learningLanguage;

  /// The learner's language — the default meaning side.
  final String nativeLanguage;

  @override
  List<Object> get props => [id.value, learningLanguage, nativeLanguage];
}
