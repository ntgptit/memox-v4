import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/routes/app_routes.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/review/providers/review_providers.dart';
import 'package:memox_v4/presentation/features/review/widgets/meaning_card.dart';
import 'package:memox_v4/presentation/features/review/widgets/term_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_progress_header.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_progress_bar.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

/// Fixed height for the end / empty / error boxes.
const double _stateBoxHeight = 420;

/// The Review browse (S.18): flip through every card in the library — a meaning
/// card (editable inline) and a term card (with audio) — via prev/next or a
/// horizontal swipe, ending on an "All reviewed" state. Reads the browse through
/// [reviewControllerProvider], rendered with `AsyncValue.when`. The edit draft
/// lives in a local [TextEditingController]; the browse state is Riverpod-owned —
/// no `setState`. Copy is from ARB.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final TextEditingController _meaningEdit = TextEditingController();

  @override
  void dispose() {
    _meaningEdit.dispose();
    super.dispose();
  }

  ReviewController get _controller =>
      ref.read(reviewControllerProvider.notifier);

  void _startEdit(String meaning) {
    _meaningEdit.text = meaning;
    _controller.startEdit();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appBar = MxAppBar(
      title: l10n.reviewTitle,
      leading: MxIconButton(
        icon: Icons.arrow_back,
        semanticLabel: l10n.reviewBack,
        onPressed: () => context.pop(),
      ),
    );
    final async = ref.watch(reviewControllerProvider);

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
              title: l10n.reviewErrorTitle,
              text: l10n.reviewErrorText,
              action: MxButton(
                label: l10n.actionRetry,
                icon: Icons.refresh,
                onPressed: () => ref.invalidate(reviewControllerProvider),
              ),
            ),
          ),
        ],
      ),
      data: (state) => _content(context, appBar, state),
    );
  }

  Widget _content(BuildContext context, MxAppBar appBar, ReviewState state) {
    final l10n = AppLocalizations.of(context);

    if (state.isEmpty) {
      return MxScaffold(
        appBar: appBar,
        children: [
          _StateBox(
            child: MxEmptyState(
              icon: Icons.style,
              title: l10n.reviewEmptyTitle,
              text: l10n.reviewEmptyText,
            ),
          ),
        ],
      );
    }

    if (state.isEnd) {
      return MxScaffold(
        appBar: appBar,
        children: [
          _StateBox(
            child: MxEmptyState(
              icon: Icons.done_all,
              tone: MxIconTileTone.success,
              title: l10n.reviewEndTitle,
              text: l10n.reviewEndText,
              action: SizedBox(
                width: MxSizes.size3xl,
                child: Column(
                  children: [
                    MxButton(
                      label: l10n.reviewStudyNow,
                      icon: Icons.school,
                      block: true,
                      onPressed: () => context.push(Routes.study),
                    ),
                    const SizedBox(height: MxSpacing.space3),
                    MxButton(
                      label: l10n.reviewBackToDeck,
                      icon: Icons.arrow_back,
                      variant: MxButtonVariant.ghost,
                      block: true,
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Invariant: past the isEmpty / isEnd guards above the index is in range
    // (init at 0, prev clamps at 0), so ReviewState.current is present here.
    final card = state.current!;
    return MxScaffold(
      appBar: appBar,
      children: [
        MxProgressHeader(done: state.position, total: state.total),
        GestureDetector(
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity < 0) _controller.next();
            if (velocity > 0) _controller.prev();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MeaningCard(
                meaning: card.meanings.first.text,
                editing: state.editing,
                controller: _meaningEdit,
                onEdit: () => _startEdit(card.meanings.first.text),
                onCancel: _controller.cancelEdit,
                onSave: () => _controller.saveEdit(_meaningEdit.text),
              ),
              const SizedBox(height: MxSpacing.space5),
              TermCard(
                term: card.term,
                playing: state.playing,
                onAudio: _controller.playAudio,
              ),
            ],
          ),
        ),
        _NavRow(
          onPrev: _controller.prev,
          onNext: _controller.next,
          hint: l10n.reviewSwipeHint,
        ),
      ],
    );
  }
}

/// The prev / hint / next control row (kit `review/prev` · `review/next`).
class _NavRow extends StatelessWidget {
  const _NavRow({required this.onPrev, required this.onNext, required this.hint});

  final VoidCallback onPrev;
  final VoidCallback onNext;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mx = MxTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MxIconButton(
          icon: Icons.chevron_left,
          semanticLabel: l10n.reviewPrev,
          onPressed: onPrev,
        ),
        const SizedBox(width: MxSpacing.space4),
        Text(
          hint,
          style: TextStyle(
            fontFamily: MxTypography.fontFamily,
            fontSize: MxTypography.sizeSm,
            color: mx.textTertiary,
          ),
        ),
        const SizedBox(width: MxSpacing.space4),
        MxIconButton(
          icon: Icons.chevron_right,
          semanticLabel: l10n.reviewNext,
          onPressed: onNext,
        ),
      ],
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
