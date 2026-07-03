import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/theme/mx_sizes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/flashcard-editor/providers/editor_providers.dart';
import 'package:memox_v4/presentation/features/flashcard-editor/widgets/dup_banner.dart';
import 'package:memox_v4/presentation/features/flashcard-editor/widgets/field.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_chip.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_switch.dart';

/// The flashcard editor (S.12): create (no [cardId]) or edit a card. Reads/mutates
/// through [editorControllerProvider] (DM.6 card use cases; DM.8 audio). The field
/// text controllers are not app state (form + validity live in the provider); no
/// `setState`. Copy is from ARB.
class FlashcardEditorScreen extends ConsumerStatefulWidget {
  const FlashcardEditorScreen({this.cardId, super.key});

  final String? cardId;

  @override
  ConsumerState<FlashcardEditorScreen> createState() =>
      _FlashcardEditorScreenState();
}

class _FlashcardEditorScreenState extends ConsumerState<FlashcardEditorScreen> {
  final TextEditingController _term = TextEditingController();
  final TextEditingController _meaning = TextEditingController();
  final TextEditingController _secondary = TextEditingController();
  bool _initialized = false;

  EditorController get _controller =>
      ref.read(editorControllerProvider(widget.cardId).notifier);

  @override
  void dispose() {
    _term.dispose();
    _meaning.dispose();
    _secondary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(editorControllerProvider(widget.cardId));

    return async.when(
      loading: () => MxScaffold(
        appBar: MxAppBar(title: l10n.editorNewTitle),
        children: const [MxCard(child: MxSkeleton(height: 120))],
      ),
      error: (_, _) => MxScaffold(
        appBar: MxAppBar(title: l10n.editorEditTitle),
        children: [
          SizedBox(
            height: MxSizes.size4xl,
            child: MxEmptyState(
              icon: Icons.error_outline,
              tone: MxIconTileTone.error,
              title: l10n.editorErrorTitle,
              text: l10n.editorErrorText,
            ),
          ),
        ],
      ),
      data: (data) {
        if (!_initialized) {
          _term.text = data.term;
          _meaning.text = data.meaning;
          _secondary.text = data.secondary ?? '';
          _initialized = true;
        }
        return _form(l10n, data);
      },
    );
  }

  Widget _form(AppLocalizations l10n, EditorData data) {
    return MxScaffold(
      appBar: MxAppBar(
        title: data.isEditing ? l10n.editorEditTitle : l10n.editorNewTitle,
        leading: MxButton(
          label: l10n.editorCancel,
          variant: MxButtonVariant.ghost,
          size: MxButtonSize.small,
          onPressed: () => context.pop(),
        ),
        trailing: MxButton(
          label: l10n.editorSave,
          size: MxButtonSize.small,
          onPressed: data.canSave ? _save : null,
        ),
      ),
      children: [
        if (data.duplicate) const DupBanner(),
        Field(
          label: l10n.editorTermLabel,
          controller: _term,
          required: true,
          placeholder: l10n.editorTermPlaceholder,
          error: data.termTouched && data.term.trim().isEmpty
              ? l10n.editorTermRequired
              : null,
          onChanged: _controller.setTerm,
        ),
        Field(
          label: l10n.editorMeaningLabel,
          controller: _meaning,
          required: true,
          multiline: true,
          placeholder: l10n.editorMeaningPlaceholder,
          error: data.meaningTouched && data.meaning.trim().isEmpty
              ? l10n.editorMeaningRequired
              : null,
          onChanged: _controller.setMeaning,
        ),
        if (data.showSecondary)
          Field(
            label: l10n.editorSecondaryLabel,
            controller: _secondary,
            placeholder: l10n.editorSecondaryPlaceholder,
            onChanged: _controller.setSecondary,
          )
        else
          MxButton(
            label: l10n.editorAddSecondary,
            variant: MxButtonVariant.ghost,
            icon: Icons.add,
            block: true,
            onPressed: _controller.showSecondary,
          ),
        _gender(l10n, data),
        Field(
          label: l10n.editorAudioLabel,
          value: l10n.editorAudioAuto,
          trailing: MxIconButton(
            icon: Icons.volume_up,
            semanticLabel: l10n.editorAudioPlay,
            size: MxIconButtonSize.small,
            onPressed: _controller.playAudio,
          ),
        ),
        MxCard(
          padding: MxCardPadding.small,
          child: MxListRow(
            icon: Icons.visibility_off,
            title: l10n.editorHideTitle,
            subtitle: l10n.editorHideSub,
            last: true,
            trailing: MxSwitch(
              value: data.hidden,
              semanticLabel: l10n.editorHideTitle,
              onChanged: _controller.setHidden,
            ),
          ),
        ),
      ],
    );
  }

  Widget _gender(AppLocalizations l10n, EditorData data) {
    final options = <(String?, String)>[
      (null, l10n.editorGenderNone),
      ('masc', l10n.editorGenderMasc),
      ('fem', l10n.editorGenderFem),
      ('neutral', l10n.editorGenderNeutral),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.editorGenderLabel,
          style: TextStyle(
            fontFamily: MxTypography.fontFamily,
            fontSize: MxTypography.sizeSm,
            fontWeight: MxTypography.bold,
            color: MxTheme.of(context).textSecondary,
          ),
        ),
        const SizedBox(height: MxSpacing.space2),
        Wrap(
          spacing: MxSpacing.space2,
          runSpacing: MxSpacing.space2,
          children: [
            for (final (value, label) in options)
              MxChip(
                label: label,
                selected: data.gender == value,
                onPressed: () => _controller.setGender(value),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _save() async {
    final saved = await _controller.save();
    if (saved && mounted) context.pop();
  }
}
