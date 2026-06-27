import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/domain/entities/language_pair.dart';
import 'package:memox_v4/domain/repositories/language_pair_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Creates a language pair after validating its two language codes.
///
/// A pair must name two different, non-empty languages (D-030). Codes are
/// normalized to lower case before storage.
class CreateLanguagePairUseCase {
  const CreateLanguagePairUseCase(this._repository);

  final LanguagePairRepository _repository;

  Future<Result<LanguagePair>> call({
    required String sourceLang,
    required String targetLang,
  }) {
    final source = sourceLang.trim().toLowerCase();
    final target = targetLang.trim().toLowerCase();

    if (source.isEmpty || target.isEmpty) {
      return Future.value(
        const Err(ValidationFailure(message: 'language code is empty')),
      );
    }
    // D-030: a pair must join two different languages.
    if (source == target) {
      return Future.value(
        const Err(ValidationFailure(message: 'source and target must differ')),
      );
    }

    return _repository.create(sourceLang: source, targetLang: target);
  }
}
