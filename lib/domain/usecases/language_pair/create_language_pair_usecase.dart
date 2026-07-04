import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/ids.dart';
import 'package:memox_v4/domain/entities/language_pair.dart';
import 'package:memox_v4/domain/services/language_pair_service.dart';

/// Creates a new language pair: validates via [LanguagePair.create] (D-030 —
/// empty code or source == target is rejected before anything is written), then
/// persists it through the [LanguagePairService].
class CreateLanguagePairUseCase {
  const CreateLanguagePairUseCase(this._service);

  final LanguagePairService _service;

  Future<Result<LanguagePair>> call({
    required LanguagePairId id,
    required String learningLanguage,
    required String nativeLanguage,
  }) async {
    final created = LanguagePair.create(
      id: id,
      learningLanguage: learningLanguage,
      nativeLanguage: nativeLanguage,
    );
    if (created case Err(:final failure)) return Err(failure);
    return _service.add((created as Ok<LanguagePair>).value);
  }
}
