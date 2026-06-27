import 'package:memox_v4/core/util/clock.dart';
import 'package:memox_v4/domain/models/play_menu.dart';
import 'package:memox_v4/domain/repositories/deck_repository.dart';
import 'package:memox_v4/domain/repositories/srs_repository.dart';
import 'package:memox_v4/domain/types/result.dart';

/// Computes the Play menu for a node: due + new counts over the subtree (D-009),
/// gating "Lặp lại"/"Học" (D-001/D-016). Read-only.
class BuildPlayMenuUseCase {
  const BuildPlayMenuUseCase(
    this._deckRepository,
    this._srsRepository,
    this._clock,
  );

  final DeckRepository _deckRepository;
  final SrsRepository _srsRepository;
  final Clock _clock;

  Future<Result<PlayMenu>> call(int nodeId) async {
    final ids =
        (await _deckRepository.subtreeCardIds(nodeId)).valueOrNull ??
        const <int>[];
    final infos =
        (await _srsRepository.scheduleInfo(ids)).valueOrNull ?? const [];
    final now = _clock.now().millisecondsSinceEpoch;
    var due = 0;
    var fresh = 0;
    for (final info in infos) {
      if (info.hidden) continue;
      if (info.isNew) {
        fresh++;
      } else if (info.box != null &&
          info.box! >= 1 &&
          info.box! < 8 &&
          info.dueAt != null &&
          info.dueAt! <= now) {
        due++;
      }
    }
    return Ok(PlayMenu(dueCount: due, newCount: fresh));
  }
}
