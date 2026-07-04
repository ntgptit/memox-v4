import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/core/routes/app_routes.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';
import 'package:memox_v4/domain/entities/language_pair.dart';
import 'package:memox_v4/l10n/app_localizations.dart';
import 'package:memox_v4/presentation/features/drawer/providers/drawer_providers.dart';
import 'package:memox_v4/presentation/features/drawer/widgets/drawer_item.dart';
import 'package:memox_v4/presentation/features/drawer/widgets/drawer_panel.dart';
import 'package:memox_v4/presentation/features/drawer/widgets/lang_card.dart';
import 'package:memox_v4/presentation/features/drawer/widgets/remove_language_dialog.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/composites/mx_sheet.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';

/// Minutes → "H:MM" for the drawer activity header.
const int _minutesPerHour = 60;

/// Fixed height for the full-screen empty / error boxes.
const double _stateBoxHeight = 400;

/// The Drawer + language-pair manager (S.06). One route hosting three sub-views —
/// the nav menu, add-language, and remove-language — switched by
/// [drawerViewStateProvider] (no `setState`). Language pairs are read/mutated via
/// DM.8 (`LanguagePairService`, D-030). Copy is from ARB.
class DrawerScreen extends ConsumerWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(drawerViewStateProvider)) {
      DrawerView.menu => _Menu(),
      DrawerView.addLanguage => _AddLanguage(),
      DrawerView.removeLanguage => _RemoveLanguage(),
    };
  }
}

// ── Menu ───────────────────────────────────────────────────────────────────────

class _Menu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final activity = ref.watch(drawerActivityProvider);

    return MxScaffold(
      appBar: MxAppBar(
        title: l10n.drawerTitle,
        leading: MxIconButton(
          icon: Icons.close,
          semanticLabel: l10n.drawerClose,
          onPressed: () => context.pop(),
        ),
      ),
      children: [
        DrawerPanel(
          activity: activity.when(
            loading: () => const MxSkeleton(width: 180, height: 20),
            error: (_, _) => const SizedBox.shrink(),
            data: (a) => DrawerActivityRow(
              time: _formatTime(a.minutes),
              words: l10n.drawerActivityWords(a.words),
            ),
          ),
          items: [
            DrawerItem(
              icon: Icons.add,
              label: l10n.drawerAddLanguage,
              onPressed: () => ref
                  .read(drawerViewStateProvider.notifier)
                  .show(DrawerView.addLanguage),
            ),
            DrawerItem(
              icon: Icons.delete,
              label: l10n.drawerRemoveLanguage,
              onPressed: () => ref
                  .read(drawerViewStateProvider.notifier)
                  .show(DrawerView.removeLanguage),
            ),
            DrawerItem(
              icon: Icons.upload_file,
              label: l10n.drawerImport,
              onPressed: () => context.push(Routes.import_),
            ),
            DrawerItem(
              icon: Icons.download,
              label: l10n.drawerExport,
              onPressed: () => context.push(Routes.export_),
            ),
            DrawerItem(
              icon: Icons.insights,
              label: l10n.drawerStats,
              onPressed: () => context.go(Routes.stats),
            ),
            DrawerItem(
              icon: Icons.palette,
              label: l10n.drawerTheme,
              onPressed: () => context.push(Routes.theme),
            ),
            DrawerItem(
              icon: Icons.settings,
              label: l10n.drawerSettings,
              onPressed: () => context.go(Routes.profile),
            ),
            DrawerItem(
              icon: Icons.backup,
              label: l10n.drawerBackup,
              onPressed: () => context.push(Routes.export_),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTime(int minutes) {
    final h = minutes ~/ _minutesPerHour;
    final m = minutes % _minutesPerHour;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}

// ── Add language ─────────────────────────────────────────────────────────────

class _AddLanguage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(addLanguageDraftProvider);
    final learning = draft.learning;
    final native = draft.native;
    // Mirrors LanguageDraft.canAdd, but on promotable locals so the add
    // callback can read the non-null names without a null-assertion.
    final canAdd = learning != null && native != null && learning != native;

    void back() {
      ref.read(addLanguageDraftProvider.notifier).reset();
      ref.read(drawerViewStateProvider.notifier).show(DrawerView.menu);
    }

    return MxScaffold(
      appBar: MxAppBar(
        title: l10n.drawerAddLanguage,
        leading: MxIconButton(
          icon: Icons.arrow_back,
          semanticLabel: l10n.drawerBack,
          onPressed: back,
        ),
      ),
      children: [
        _Label(l10n.drawerSectionLearning),
        LangCard(
          icon: Icons.language,
          name: learning ?? l10n.drawerChooseLanguage,
          subtitle: l10n.drawerSectionLearning,
          onPressed: () => _pick(context, ref, learning: true),
        ),
        Center(
          child: Icon(
            Icons.arrow_downward,
            color: MxTheme.of(context).textTertiary,
          ),
        ),
        _Label(l10n.drawerSectionNative),
        LangCard(
          icon: Icons.translate,
          name: native ?? l10n.drawerChooseLanguage,
          subtitle: l10n.drawerNativeHint,
          onPressed: () => _pick(context, ref, learning: false),
        ),
        MxButton(
          label: l10n.drawerAddPair,
          icon: Icons.add,
          block: true,
          onPressed: canAdd
              ? () {
                  ref
                      .read(languagePairControllerProvider.notifier)
                      .addPair(
                        learning: learning,
                        native: native,
                      );
                  back();
                  ref
                      .read(drawerViewStateProvider.notifier)
                      .show(DrawerView.removeLanguage);
                }
              : null,
        ),
      ],
    );
  }

  void _pick(BuildContext context, WidgetRef ref, {required bool learning}) {
    final l10n = AppLocalizations.of(context);
    showMxSheet<void>(
      context: context,
      title: l10n.drawerLanguagePicker,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, option) in drawerLanguages.indexed)
            MxListRow(
              icon: Icons.translate,
              title: option.name,
              subtitle: option.subtitle,
              last: index == drawerLanguages.length - 1,
              onPressed: () {
                Navigator.of(context).pop();
                final notifier = ref.read(addLanguageDraftProvider.notifier);
                learning
                    ? notifier.setLearning(option.name)
                    : notifier.setNative(option.name);
              },
            ),
        ],
      ),
    );
  }
}

// ── Remove language ────────────────────────────────────────────────────────────

class _RemoveLanguage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(languagePairControllerProvider);

    final appBar = MxAppBar(
      title: l10n.drawerRemoveLanguage,
      leading: MxIconButton(
        icon: Icons.arrow_back,
        semanticLabel: l10n.drawerBack,
        onPressed: () =>
            ref.read(drawerViewStateProvider.notifier).show(DrawerView.menu),
      ),
    );

    return async.when(
      loading: () => MxScaffold(
        appBar: appBar,
        children: const [
          MxCard(padding: MxCardPadding.small, child: MxSkeleton(height: 48)),
        ],
      ),
      error: (_, _) => MxScaffold(
        appBar: appBar,
        children: [
          SizedBox(
            height: _stateBoxHeight,
            child: MxEmptyState(
              icon: Icons.error_outline,
              tone: MxIconTileTone.error,
              title: l10n.drawerErrorTitle,
              text: l10n.drawerErrorText,
              action: MxButton(
                label: l10n.actionRetry,
                icon: Icons.refresh,
                onPressed: () => ref.invalidate(languagePairControllerProvider),
              ),
            ),
          ),
        ],
      ),
      data: (pairs) => MxScaffold(
        appBar: appBar,
        children: [
          pairs.isEmpty
              ? SizedBox(
                  height: _stateBoxHeight,
                  child: MxEmptyState(
                    icon: Icons.translate,
                    title: l10n.drawerRemoveEmptyTitle,
                    text: l10n.drawerRemoveEmptyText,
                  ),
                )
              : MxCard(
                  padding: MxCardPadding.small,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final (index, pair) in pairs.indexed)
                        MxListRow(
                          icon: Icons.translate,
                          title: _label(pair),
                          last: index == pairs.length - 1,
                          trailing: MxIconButton(
                            icon: Icons.delete,
                            semanticLabel: l10n.drawerRemovePairLabel(
                              _label(pair),
                            ),
                            onPressed: () => _confirmRemove(context, ref, pair),
                          ),
                        ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  String _label(LanguagePair pair) =>
      '${pair.learningLanguage} → ${pair.nativeLanguage}';

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    LanguagePair pair,
  ) async {
    final confirmed = await showRemoveLanguageDialog(
      context,
      pairLabel: _label(pair),
    );
    if (!confirmed) return;
    await ref.read(languagePairControllerProvider.notifier).removePair(pair.id);
  }
}

/// A small uppercase section label (kit `SectionLabel`).
class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: MxSpacing.space1),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: MxTypography.fontFamily,
          fontSize: MxTypography.sizeSm,
          fontWeight: MxTypography.bold,
          letterSpacing: MxTypography.sizeSm * MxTypography.trackingWide,
          color: mx.textTertiary,
        ),
      ),
    );
  }
}
