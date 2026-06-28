import 'package:memox_v4/app/di/database_provider.dart';
import 'package:memox_v4/data/datasources/local/daos/review_outcome_dao.dart';
import 'package:memox_v4/data/repositories/review_outcome_repository_impl.dart';
import 'package:memox_v4/domain/repositories/review_outcome_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'review_outcome_providers.g.dart';

/// Composition root for review-outcome recording (W9 accuracy stats).
@Riverpod(keepAlive: true)
ReviewOutcomeRepository reviewOutcomeRepository(Ref ref) =>
    ReviewOutcomeRepositoryImpl(ReviewOutcomeDao(ref.watch(databaseProvider)));
