import 'package:memox_v4/app/di/card_providers.dart';
import 'package:memox_v4/app/di/deck_providers.dart';
import 'package:memox_v4/app/di/srs_providers.dart';
import 'package:memox_v4/data/services/table_codec.dart';
import 'package:memox_v4/domain/usecases/flashcard/check_soft_duplicate.dart';
import 'package:memox_v4/domain/usecases/flashcard/create_card.dart';
import 'package:memox_v4/domain/usecases/import_export/export_cards.dart';
import 'package:memox_v4/domain/usecases/import_export/import_cards.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'import_export_providers.g.dart';

/// Composition root for import/export (W8).
@Riverpod(keepAlive: true)
TableCodec tableCodec(Ref ref) => const TableCodec();

@Riverpod(keepAlive: true)
ImportCardsUseCase importCards(Ref ref) => ImportCardsUseCase(
  CreateCardUseCase(ref.watch(cardRepositoryProvider)),
  CheckSoftDuplicateUseCase(ref.watch(cardRepositoryProvider)),
);

@Riverpod(keepAlive: true)
ExportCardsUseCase exportCards(Ref ref) => ExportCardsUseCase(
  ref.watch(cardRepositoryProvider),
  ref.watch(deckRepositoryProvider),
  ref.watch(srsRepositoryProvider),
);
