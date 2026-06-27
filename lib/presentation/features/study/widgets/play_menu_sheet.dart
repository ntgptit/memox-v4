import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox_v4/app/di/clock_provider.dart';
import 'package:memox_v4/app/di/deck_providers.dart';
import 'package:memox_v4/app/di/srs_providers.dart';
import 'package:memox_v4/app/router/route_paths.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/domain/models/play_menu.dart';
import 'package:memox_v4/domain/types/result.dart';
import 'package:memox_v4/domain/types/study_entry.dart';
import 'package:memox_v4/domain/usecases/study/build_play_menu.dart';
import 'package:memox_v4/l10n/generated/app_localizations.dart';

/// Opens the Play menu for a node (the 5 entries, "Lặp lại" only when due>0).
Future<void> showPlayMenu(BuildContext context, int nodeId) =>
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => PlayMenuSheet(nodeId: nodeId),
    );

class PlayMenuSheet extends ConsumerStatefulWidget {
  const PlayMenuSheet({super.key, required this.nodeId});

  final int nodeId;

  @override
  ConsumerState<PlayMenuSheet> createState() => _PlayMenuSheetState();
}

class _PlayMenuSheetState extends ConsumerState<PlayMenuSheet> {
  PlayMenu? _menu;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final menu = (await BuildPlayMenuUseCase(
      ref.read(deckRepositoryProvider),
      ref.read(srsRepositoryProvider),
      ref.read(clockProvider),
    ).call(widget.nodeId)).valueOrNull;
    if (!mounted) return;
    setState(() => _menu = menu ?? const PlayMenu(dueCount: 0, newCount: 0));
  }

  void _go(StudyEntry entry) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    unawaited(
      router.push(switch (entry) {
        StudyEntry.dueReview => RoutePaths.studyLocation(
          widget.nodeId,
          StudyEntry.dueReview,
        ),
        StudyEntry.newLearn => RoutePaths.studyLocation(
          widget.nodeId,
          StudyEntry.newLearn,
        ),
        StudyEntry.review => RoutePaths.reviewLocation(widget.nodeId),
        StudyEntry.game => RoutePaths.gamePickerLocation(widget.nodeId),
        StudyEntry.player => RoutePaths.playerLocation(widget.nodeId),
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final menu = _menu;
    return SafeArea(
      child: menu == null
          ? const Padding(
              padding: EdgeInsets.all(MxSpacing.space6),
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (final entry in menu.entries) _tile(l10n, menu, entry),
              ],
            ),
    );
  }

  ListTile _tile(AppLocalizations l10n, PlayMenu menu, StudyEntry entry) {
    final (Key key, IconData icon, String label) = switch (entry) {
      StudyEntry.dueReview => (
        const Key('playDueReview'),
        Icons.replay,
        l10n.studyDueReview(menu.dueCount),
      ),
      StudyEntry.newLearn => (
        const Key('playNewLearn'),
        Icons.school_outlined,
        l10n.studyNewLearn,
      ),
      StudyEntry.review => (
        const Key('playReview'),
        Icons.menu_book_outlined,
        l10n.studyReview,
      ),
      StudyEntry.game => (
        const Key('playGame'),
        Icons.videogame_asset_outlined,
        l10n.gameTitle,
      ),
      StudyEntry.player => (
        const Key('playPlayer'),
        Icons.play_circle_outline,
        l10n.studyPlayer,
      ),
    };
    return ListTile(
      key: key,
      leading: Icon(icon),
      title: Text(label),
      onTap: () => _go(entry),
    );
  }
}
