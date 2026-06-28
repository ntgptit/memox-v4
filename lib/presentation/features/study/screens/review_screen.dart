import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/app/di/card_providers.dart';
import 'package:memox_v4/app/di/clock_provider.dart';
import 'package:memox_v4/app/di/deck_providers.dart';
import 'package:memox_v4/app/di/srs_providers.dart';
import 'package:memox_v4/app/router/route_paths.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/domain/models/game_card.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/types/study_entry.dart';
import 'package:memox_v4/domain/usecases/study/build_study_queue.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/shared/layouts/responsive.dart';
import 'package:memox_v4/presentation/shared/widgets/buttons/mx_button.dart';
import 'package:memox_v4/presentation/shared/widgets/display/mx_text.dart';
import 'package:memox_v4/presentation/shared/widgets/states/mx_state_view.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox_v4/presentation/shared/widgets/surfaces/mx_scaffold.dart';

/// Browse cards (term + meaning); never changes the schedule (D-007).
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, required this.nodeId});

  final int nodeId;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  List<GameCard>? _cards;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final ids =
        (await BuildStudyQueueUseCase(
          ref.read(deckRepositoryProvider),
          ref.read(srsRepositoryProvider),
          ref.read(clockProvider),
        ).call(widget.nodeId, StudyEntry.review)).valueOrNull ??
        const <int>[];
    final cards = <GameCard>[];
    for (final id in ids) {
      final card =
          (await ref.read(cardRepositoryProvider).getById(id)).valueOrNull;
      if (card != null) {
        cards.add(
          GameCard(
            cardId: card.id,
            term: card.term,
            meaning: card.meanings.isEmpty ? '' : card.meanings.first.content,
          ),
        );
      }
    }
    if (!mounted) return;
    setState(() => _cards = cards);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cards = _cards;
    return MxScaffold(
      appBar: MxAppBar(title: l10n.studyReview),
      flush: true,
      body: cards == null
          ? const MxStateView.loading()
          : cards.isEmpty || _index >= cards.length
          ? _end(l10n)
          : _card(l10n, cards),
    );
  }

  Widget _card(AppLocalizations l10n, List<GameCard> cards) {
    final card = cards[_index];
    return Column(
      children: <Widget>[
        LinearProgressIndicator(value: (_index + 1) / cards.length),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(MxSpacing.space5),
            child: Column(
              children: <Widget>[
                MxCard(
                  padding: MxCardPadding.lg,
                  child: MxText(card.meaning, role: MxTextRole.bodyLarge),
                ),
                const SizedBox(height: MxSpacing.space4),
                MxCard(
                  padding: MxCardPadding.lg,
                  child: MxText.headline(card.term),
                ),
                const Spacer(),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: MxButton(
                        label: l10n.commonBack,
                        variant: MxButtonVariant.outline,
                        block: true,
                        onPressed: _index == 0
                            ? null
                            : () => setState(() => _index--),
                      ),
                    ),
                    const SizedBox(width: MxSpacing.space3),
                    Expanded(
                      child: MxButton(
                        key: const Key('reviewNext'),
                        label: l10n.studyContinue,
                        block: true,
                        onPressed: () => setState(() => _index++),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _end(AppLocalizations l10n) => MxContentBounds(
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MxText.title(l10n.reviewEnd),
          const SizedBox(height: MxSpacing.space4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MxButton(
                label: l10n.reviewStudyNow,
                variant: MxButtonVariant.outline,
                onPressed: () => context.push(
                  RoutePaths.studyLocation(widget.nodeId, StudyEntry.newLearn),
                ),
              ),
              const SizedBox(width: MxSpacing.space3),
              MxButton(
                label: l10n.studyToLibrary,
                onPressed: () => context.go(RoutePaths.root),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
