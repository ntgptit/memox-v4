import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/game-typing/providers/typing_providers.dart';
import 'package:memox_v4/presentation/features/game-typing/widgets/char_compare.dart';
import 'package:memox_v4/presentation/features/game-typing/widgets/input_box.dart';
import 'package:memox_v4/presentation/shared/composites/mx_action_callout.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_progress_bar.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_section_label.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_text_field.dart';

/// Fixed height for the complete / empty / error boxes.
const double _stateBoxHeight = 400;

/// The Typing game (S.17): the meaning is prompted, the learner types the term,
/// then checks it — a correct answer advances, a near-miss can be self-accepted
/// or retried. Reads the round through [typingControllerProvider], rendered with
/// `AsyncValue.when` (waiting · typing · hint · correct · wrong · complete). The
/// answer lives in a local [TextEditingController] (not app state); the game
/// state is Riverpod-owned — no `setState`. Copy is from ARB.
class GameTypingScreen extends ConsumerStatefulWidget {
  const GameTypingScreen({super.key});

  @override
  ConsumerState<GameTypingScreen> createState() => _GameTypingScreenState();
}

class _GameTypingScreenState extends ConsumerState<GameTypingScreen> {
  final TextEditingController _answer = TextEditingController();

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  void _check() => ref.read(typingControllerProvider.notifier).check(_answer.text);

  void _next() {
    _answer.clear();
    ref.read(typingControllerProvider.notifier).next();
  }

  void _accept() {
    _answer.clear();
    ref.read(typingControllerProvider.notifier).acceptAsCorrect();
  }

  void _retry() {
    _answer.clear();
    ref.read(typingControllerProvider.notifier).retry();
  }

  void _nextRound() {
    _answer.clear();
    ref.read(typingControllerProvider.notifier).nextRound();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appBar = MxAppBar(
      title: l10n.typingTitle,
      leading: MxIconButton(
        icon: Icons.arrow_back,
        semanticLabel: l10n.typingBack,
        onPressed: () => context.pop(),
      ),
    );
    final async = ref.watch(typingControllerProvider);

    return async.when(
      loading: () => MxScaffold(appBar: appBar, children: const [
        MxProgressBar(value: 0),
        SizedBox(height: MxSpacing.space5),
        MxSkeleton(height: 200),
      ]),
      error: (_, _) => MxScaffold(
        appBar: appBar,
        children: [
          _StateBox(
            child: MxEmptyState(
              icon: Icons.error_outline,
              tone: MxIconTileTone.error,
              title: l10n.typingErrorTitle,
              text: l10n.typingErrorText,
              action: MxButton(
                label: l10n.actionRetry,
                icon: Icons.refresh,
                onPressed: () => ref.invalidate(typingControllerProvider),
              ),
            ),
          ),
        ],
      ),
      data: (state) => _content(context, appBar, state),
    );
  }

  Widget _content(BuildContext context, MxAppBar appBar, TypingState state) {
    final l10n = AppLocalizations.of(context);

    if (state.isEmpty) {
      return MxScaffold(
        appBar: appBar,
        children: [
          _StateBox(
            child: MxEmptyState(
              icon: Icons.style,
              title: l10n.typingEmptyTitle,
              text: l10n.typingEmptyText,
            ),
          ),
        ],
      );
    }

    if (state.isComplete) {
      return MxScaffold(
        appBar: appBar,
        children: [
          const MxProgressBar(value: 1),
          _StateBox(
            child: MxEmptyState(
              icon: Icons.celebration,
              tone: MxIconTileTone.success,
              title: l10n.typingCompleteTitle,
              text: l10n.typingCompleteText,
              action: MxButton(
                label: l10n.typingNextRound,
                icon: Icons.arrow_forward,
                onPressed: _nextRound,
              ),
            ),
          ),
        ],
      );
    }

    // Invariant: past the isEmpty / isComplete guards above the queue is
    // non-empty, so TypingState.current is always present here.
    final card = state.current!;
    return MxScaffold(
      appBar: appBar,
      children: [
        MxProgressBar(value: state.progress),
        _MeaningCard(meaning: card.meaning),
        Text(
          l10n.typingPrompt,
          style: TextStyle(
            fontFamily: MxTypography.fontFamily,
            fontSize: MxTypography.sizeSm,
            fontWeight: MxTypography.bold,
            color: MxTheme.of(context).textSecondary,
          ),
        ),
        InputBox(tone: _tone(state), child: _inputChild(context, state, card)),
        if (state.hintShown && !state.isGraded)
          MxActionCallout(
            icon: Icons.lightbulb,
            text: l10n.typingHint(card.term.characters.length, _firstChar(card.term)),
          ),
        if (state.outcome == TypingOutcome.wrong) _answerReveal(context, card),
        _controls(context, state),
      ],
    );
  }

  InputBoxTone _tone(TypingState state) => switch (state.outcome) {
        TypingOutcome.none => InputBoxTone.neutral,
        TypingOutcome.correct => InputBoxTone.correct,
        TypingOutcome.wrong => InputBoxTone.wrong,
      };

  Widget _inputChild(BuildContext context, TypingState state, TypingCard card) {
    final scheme = Theme.of(context).colorScheme;
    final answerStyle = TextStyle(
      fontFamily: MxTypography.fontFamily,
      fontSize: MxTypography.size2xl,
      fontWeight: MxTypography.extrabold,
      color: scheme.onSurface,
    );

    if (state.outcome == TypingOutcome.wrong) {
      return CharCompare(typed: state.submitted, correct: card.term);
    }
    if (state.outcome == TypingOutcome.correct) {
      return Text(card.term, textAlign: TextAlign.center, style: answerStyle);
    }
    return MxTextField(
      controller: _answer,
      textAlign: TextAlign.center,
      style: answerStyle,
      onSubmitted: (_) => _check(),
      hintText: AppLocalizations.of(context).typingPlaceholder,
      hintStyle: TextStyle(
        fontFamily: MxTypography.fontFamily,
        fontSize: MxTypography.sizeBase,
        fontWeight: MxTypography.semibold,
        color: MxTheme.of(context).textTertiary,
      ),
    );
  }

  Widget _answerReveal(BuildContext context, TypingCard card) {
    final l10n = AppLocalizations.of(context);
    final mx = MxTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${l10n.typingAnswerLabel} ',
          style: TextStyle(
            fontFamily: MxTypography.fontFamily,
            fontSize: MxTypography.sizeBase,
            color: mx.textSecondary,
          ),
        ),
        Text(
          card.term,
          style: TextStyle(
            fontFamily: MxTypography.fontFamily,
            fontSize: MxTypography.sizeBase,
            fontWeight: MxTypography.bold,
            color: mx.success,
          ),
        ),
      ],
    );
  }

  Widget _controls(BuildContext context, TypingState state) {
    final l10n = AppLocalizations.of(context);

    if (state.outcome == TypingOutcome.correct) {
      return MxButton(
        label: l10n.typingNext,
        icon: Icons.arrow_forward,
        block: true,
        onPressed: _next,
      );
    }

    if (state.outcome == TypingOutcome.wrong) {
      return Row(
        children: [
          Expanded(
            child: MxButton(
              label: l10n.typingCorrectAction,
              variant: MxButtonVariant.outline,
              onPressed: _accept,
            ),
          ),
          const SizedBox(width: MxSpacing.space3),
          Expanded(
            child: MxButton(label: l10n.typingRetry, onPressed: _retry),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: MxButton(
            label: l10n.typingHelp,
            icon: Icons.lightbulb_outline,
            variant: MxButtonVariant.ghost,
            onPressed: state.hintShown
                ? null
                : ref.read(typingControllerProvider.notifier).showHint,
          ),
        ),
        const SizedBox(width: MxSpacing.space3),
        Expanded(
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _answer,
            builder: (context, value, _) => MxButton(
              label: l10n.typingCheck,
              onPressed: value.text.trim().isEmpty ? null : _check,
            ),
          ),
        ),
      ],
    );
  }

  String _firstChar(String term) =>
      term.characters.isEmpty ? '' : term.characters.first;
}

/// The prompted meaning (kit `game-typing/meaning`): a centered eyebrow + meaning.
class _MeaningCard extends StatelessWidget {
  const _MeaningCard({required this.meaning});

  final String meaning;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      child: Column(
        children: [
          MxSectionLabel(text: l10n.typingMeaningLabel, uppercase: true),
          const SizedBox(height: MxSpacing.space2),
          Text(
            meaning,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: MxTypography.fontFamily,
              fontSize: MxTypography.size2xl,
              fontWeight: MxTypography.extrabold,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _StateBox extends StatelessWidget {
  const _StateBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: _stateBoxHeight, child: child);
}
