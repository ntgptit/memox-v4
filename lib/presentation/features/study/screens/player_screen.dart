import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox_v4/app/di/card_providers.dart';
import 'package:memox_v4/app/di/clock_provider.dart';
import 'package:memox_v4/app/di/deck_providers.dart';
import 'package:memox_v4/app/di/srs_providers.dart';
import 'package:memox_v4/app/di/tts_providers.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/domain/models/game_card.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/types/study_entry.dart';
import 'package:memox_v4/domain/usecases/study/build_study_queue.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/language_pair/viewmodels/language_pair_notifier.dart';
import 'package:memox_v4/presentation/shared/layouts/responsive.dart';

/// Auto-play through cards (term + meaning); never changes the schedule (D-014).
/// Speaks each term aloud via TTS as it advances.
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key, required this.nodeId});

  final int nodeId;

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  static const Duration _interval = Duration(seconds: 3);

  List<GameCard>? _cards;
  int _index = 0;
  bool _playing = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final ids =
        (await BuildStudyQueueUseCase(
          ref.read(deckRepositoryProvider),
          ref.read(srsRepositoryProvider),
          ref.read(clockProvider),
        ).call(widget.nodeId, StudyEntry.player)).valueOrNull ??
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

  void _togglePlay() {
    setState(() => _playing = !_playing);
    _timer?.cancel();
    if (_playing) {
      _speakCurrent();
      _timer = Timer.periodic(_interval, (_) => _advance());
    }
  }

  void _advance() {
    final cards = _cards;
    if (cards == null) return;
    if (_index >= cards.length - 1) {
      _timer?.cancel();
      setState(() {
        _playing = false;
        _index = cards.length;
      });
      return;
    }
    setState(() => _index++);
    _speakCurrent();
  }

  void _speakCurrent() {
    final cards = _cards;
    if (cards == null || _index >= cards.length) return;
    final active = ref.read(languagePairProvider).value?.active;
    unawaited(
      ref
          .read(ttsServiceProvider)
          .speak(cards[_index].term, languageCode: active?.sourceLang),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cards = _cards;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.studyPlayer)),
      body: cards == null
          ? const Center(child: CircularProgressIndicator())
          : cards.isEmpty || _index >= cards.length
          ? _end(l10n)
          : _player(l10n, cards),
    );
  }

  Widget _player(AppLocalizations l10n, List<GameCard> cards) {
    final theme = Theme.of(context);
    final card = cards[_index];
    return Padding(
      padding: const EdgeInsets.all(MxSpacing.space5),
      child: Column(
        children: <Widget>[
          Text(
            '${_index + 1} / ${cards.length}',
            style: theme.textTheme.labelMedium,
          ),
          const Spacer(),
          Text(card.term, style: theme.textTheme.headlineMedium),
          const SizedBox(height: MxSpacing.space3),
          Text(card.meaning, style: theme.textTheme.bodyLarge),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton.filled(
                key: const Key('playerToggle'),
                iconSize: MxSpacing.space9,
                onPressed: _togglePlay,
                icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
              ),
              const SizedBox(width: MxSpacing.space4),
              IconButton.outlined(
                key: const Key('playerSpeak'),
                iconSize: MxSpacing.space7,
                onPressed: _speakCurrent,
                icon: const Icon(Icons.volume_up_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _end(AppLocalizations l10n) => MxContentBounds(
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(l10n.playerEnd, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: MxSpacing.space4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              OutlinedButton(
                onPressed: () => setState(() {
                  _index = 0;
                  _playing = false;
                }),
                child: Text(l10n.playerReplay),
              ),
              const SizedBox(width: MxSpacing.space3),
              FilledButton(
                onPressed: () => unawaited(Navigator.of(context).maybePop()),
                child: Text(l10n.commonClose),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
