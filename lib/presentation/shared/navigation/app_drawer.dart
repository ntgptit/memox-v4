import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/app/router/route_paths.dart';
import 'package:memox_v4/core/constants/supported_languages.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/domain/entities/language_pair.dart';
import 'package:memox_v4/domain/models/language_pair_context.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';
import 'package:memox_v4/presentation/features/language_pair/viewmodels/language_pair_notifier.dart';

/// Which screen the drawer is showing. The drawer is the language-pair switcher
/// and the secondary navigation hub (`docs/design/screens/23-drawer.md`).
enum _DrawerView { menu, addLanguage, removeLanguage }

/// Navigation drawer with the activity header, language-pair switcher, and the
/// add/remove-language flows. Secondary destinations land with their features.
class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  _DrawerView _view = _DrawerView.menu;
  String? _addSource;
  String? _addTarget;
  String? _addError;

  void _show(_DrawerView view) {
    setState(() {
      _view = view;
      if (view != _DrawerView.addLanguage) {
        _addSource = null;
        _addTarget = null;
        _addError = null;
      }
    });
  }

  LanguagePairNotifier get _notifier => ref.read(languagePairProvider.notifier);

  void _setActive(int id) => unawaited(_notifier.setActive(id));

  void _swap() => unawaited(_notifier.swapDirection());

  void _remove(int id) => unawaited(_notifier.removePair(id));

  @override
  Widget build(BuildContext context) {
    final asyncContext = ref.watch(languagePairProvider);
    return Drawer(
      child: SafeArea(
        child: asyncContext.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _buildError(context),
          data: (data) => _buildBody(context, data),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, LanguagePairContext data) =>
      switch (_view) {
        _DrawerView.menu => _buildMenu(context, data),
        _DrawerView.addLanguage => _buildAddLanguage(context),
        _DrawerView.removeLanguage => _buildRemoveLanguage(context, data),
      };

  // ── menu ────────────────────────────────────────────────────────────────
  Widget _buildMenu(BuildContext context, LanguagePairContext data) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        _activityHeader(context),
        const Divider(height: MxSpacing.space1),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            MxSpacing.space5,
            MxSpacing.space4,
            MxSpacing.space5,
            MxSpacing.space2,
          ),
          child: Text(
            l10n.drawerLanguagesTitle,
            style: theme.textTheme.labelMedium,
          ),
        ),
        if (data.pairs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MxSpacing.space5,
              vertical: MxSpacing.space2,
            ),
            child: Text(
              l10n.drawerLanguagesEmpty,
              style: theme.textTheme.bodySmall,
            ),
          )
        else
          ...data.pairs.map((pair) => _pairTile(context, pair, data)),
        const Divider(height: MxSpacing.space1),
        ListTile(
          key: const Key('drawerAddLanguage'),
          leading: const Icon(Icons.add_circle_outline),
          title: Text(l10n.drawerAddLanguage),
          onTap: () => _show(_DrawerView.addLanguage),
        ),
        if (data.pairs.isNotEmpty)
          ListTile(
            key: const Key('drawerRemoveLanguage'),
            leading: const Icon(Icons.remove_circle_outline),
            title: Text(l10n.drawerRemoveLanguage),
            onTap: () => _show(_DrawerView.removeLanguage),
          ),
        _comingSoonTile(
          context,
          Icons.file_download_outlined,
          l10n.drawerImport,
        ),
        _comingSoonTile(context, Icons.file_upload_outlined, l10n.drawerExport),
        _comingSoonTile(
          context,
          Icons.bar_chart_outlined,
          l10n.drawerStatistics,
        ),
        _comingSoonTile(context, Icons.palette_outlined, l10n.drawerTheme),
        _navTile(
          context,
          Icons.settings_outlined,
          l10n.drawerSettings,
          RoutePaths.settings,
        ),
        _comingSoonTile(context, Icons.help_outline, l10n.drawerFaq),
        _comingSoonTile(context, Icons.mail_outline, l10n.drawerSendEmail),
        _comingSoonTile(context, Icons.sync, l10n.drawerSync),
      ],
    );
  }

  Widget _activityHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(MxSpacing.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.drawerActivityTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: MxSpacing.space2),
          Row(
            children: <Widget>[
              Icon(
                Icons.schedule,
                size: MxSpacing.space5,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: MxSpacing.space2),
              Text(l10n.activityMinutes(0), style: theme.textTheme.bodyMedium),
              const SizedBox(width: MxSpacing.space5),
              Icon(
                Icons.menu_book_outlined,
                size: MxSpacing.space5,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: MxSpacing.space2),
              Text(l10n.activityWords(0), style: theme.textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pairTile(
    BuildContext context,
    LanguagePair pair,
    LanguagePairContext data,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isActive = data.active?.id == pair.id;
    return ListTile(
      key: Key('pairTile-${pair.id}'),
      selected: isActive,
      leading: Icon(
        isActive ? Icons.check_circle : Icons.circle_outlined,
        color: isActive ? theme.colorScheme.primary : null,
      ),
      title: Text(_pairLabel(pair, data.displaySwapped)),
      trailing: isActive
          ? IconButton(
              key: const Key('swapDirection'),
              icon: const Icon(Icons.swap_horiz),
              tooltip: l10n.swapDirectionTooltip,
              onPressed: _swap,
            )
          : null,
      onTap: isActive ? null : () => _setActive(pair.id),
    );
  }

  Widget _comingSoonTile(BuildContext context, IconData icon, String label) =>
      ListTile(
        leading: Icon(icon),
        title: Text(label),
        onTap: () => _comingSoon(context),
      );

  Widget _navTile(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) => ListTile(
    leading: Icon(icon),
    title: Text(label),
    onTap: () {
      Navigator.of(context).pop();
      unawaited(context.push(route));
    },
  );

  void _comingSoon(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
  }

  // ── add language ──────────────────────────────────────────────────────────
  Widget _buildAddLanguage(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListView(
      key: const ValueKey('mx-node:drawer/add-screen'),
      padding: const EdgeInsets.all(MxSpacing.space5),
      children: <Widget>[
        _viewHeader(context, l10n.addLanguageTitle, const Key('addBack')),
        const SizedBox(height: MxSpacing.space4),
        Text(l10n.addLanguageLearning, style: theme.textTheme.labelMedium),
        const SizedBox(height: MxSpacing.space2),
        _languageDropdown(
          fieldKey: const Key('addLanguageSource'),
          hint: l10n.addLanguageLearning,
          value: _addSource,
          onChanged: (value) => setState(() {
            _addSource = value;
            _addError = null;
          }),
        ),
        const SizedBox(height: MxSpacing.space4),
        Text(l10n.addLanguageNative, style: theme.textTheme.labelMedium),
        const SizedBox(height: MxSpacing.space2),
        _languageDropdown(
          fieldKey: const Key('addLanguageTarget'),
          hint: l10n.addLanguageNative,
          value: _addTarget,
          onChanged: (value) => setState(() {
            _addTarget = value;
            _addError = null;
          }),
        ),
        if (_addError != null) ...<Widget>[
          const SizedBox(height: MxSpacing.space3),
          Text(
            _addError!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: MxSpacing.space5),
        FilledButton(
          key: const ValueKey('mx-node:drawer/add-confirm'),
          onPressed: () => _submitAdd(context),
          child: Text(l10n.addLanguageSubmit),
        ),
      ],
    );
  }

  Widget _languageDropdown({
    required Key fieldKey,
    required String hint,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) => DropdownButton<String>(
    key: fieldKey,
    isExpanded: true,
    value: value,
    hint: Text(hint),
    items: kSupportedLanguages
        .map(
          (language) => DropdownMenuItem<String>(
            value: language.code,
            child: Text(language.endonym),
          ),
        )
        .toList(),
    onChanged: onChanged,
  );

  void _submitAdd(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final source = _addSource;
    final target = _addTarget;
    if (source == null || target == null) {
      setState(() => _addError = l10n.addLanguageErrorEmpty);
      return;
    }
    if (source == target) {
      setState(() => _addError = l10n.addLanguageErrorSame);
      return;
    }
    unawaited(_notifier.addPair(sourceLang: source, targetLang: target));
    _show(_DrawerView.menu);
  }

  // ── remove language ─────────────────────────────────────────────────────────
  Widget _buildRemoveLanguage(BuildContext context, LanguagePairContext data) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListView(
      key: const ValueKey('mx-node:drawer/remove-screen'),
      padding: const EdgeInsets.all(MxSpacing.space5),
      children: <Widget>[
        _viewHeader(context, l10n.removeLanguageTitle, const Key('removeBack')),
        const SizedBox(height: MxSpacing.space4),
        if (data.pairs.isEmpty)
          Text(l10n.removeLanguageEmpty, style: theme.textTheme.bodyMedium)
        else
          ...data.pairs.map(
            (pair) => ListTile(
              key: Key('removeTile-${pair.id}'),
              title: Text(_pairLabel(pair, data.displaySwapped)),
              trailing: IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                tooltip: l10n.commonDelete,
                onPressed: () => _confirmRemove(context, pair),
              ),
            ),
          ),
      ],
    );
  }

  void _confirmRemove(BuildContext context, LanguagePair pair) {
    final l10n = AppLocalizations.of(context);
    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.removeLanguageConfirmTitle),
          content: Text(l10n.removeLanguageConfirmBody),
          actions: <Widget>[
            TextButton(
              key: const ValueKey('mx-node:drawer/remove-cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              key: const ValueKey('mx-node:drawer/remove-ok'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _remove(pair.id);
              },
              child: Text(l10n.commonDelete),
            ),
          ],
        ),
      ),
    );
  }

  // ── shared ──────────────────────────────────────────────────────────────────
  Widget _viewHeader(BuildContext context, String title, Key backKey) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        IconButton(
          key: backKey,
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.commonBack,
          onPressed: () => _show(_DrawerView.menu),
        ),
        const SizedBox(width: MxSpacing.space2),
        Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
      ],
    );
  }

  Widget _buildError(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(MxSpacing.space5),
      child: Icon(
        Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
      ),
    ),
  );

  String _pairLabel(LanguagePair pair, bool swapped) {
    final source = endonymOf(pair.sourceLang);
    final target = endonymOf(pair.targetLang);
    return swapped ? '$target → $source' : '$source → $target';
  }
}
