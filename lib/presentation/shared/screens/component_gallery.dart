import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/presentation/shared/composites/action_callout.dart';
import 'package:memox_v4/presentation/shared/composites/confirm_dialog.dart';
import 'package:memox_v4/presentation/shared/composites/mx_app_bar.dart';
import 'package:memox_v4/presentation/shared/composites/mx_bottom_nav.dart';
import 'package:memox_v4/presentation/shared/composites/mx_card.dart';
import 'package:memox_v4/presentation/shared/composites/mx_empty_state.dart';
import 'package:memox_v4/presentation/shared/composites/mx_fab.dart';
import 'package:memox_v4/presentation/shared/composites/mx_icon_tile.dart';
import 'package:memox_v4/presentation/shared/composites/mx_list_row.dart';
import 'package:memox_v4/presentation/shared/composites/mx_scaffold.dart';
import 'package:memox_v4/presentation/shared/composites/mx_search_dock.dart';
import 'package:memox_v4/presentation/shared/composites/mx_section_header.dart';
import 'package:memox_v4/presentation/shared/composites/mx_sheet.dart';
import 'package:memox_v4/presentation/shared/composites/mx_stat_ring.dart';
import 'package:memox_v4/presentation/shared/composites/status_card_row.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_avatar.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_badge.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_chip.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_choice_option.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_icon_button.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_progress_bar.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_segmented_control.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_skeleton.dart';
import 'package:memox_v4/presentation/shared/primitives/mx_switch.dart';

/// A dev/QA gallery rendering every shared primitive + composite in its variants,
/// in the ambient theme. It is the visual lock before the feature screens — a
/// single place where the whole component set can be eyeballed and (via the
/// golden suite in V.1) snapshot-tested, so no screen re-derives a component.
///
/// Not a shipped product screen: the section labels + demo copy are developer
/// strings, not localized product copy.
class ComponentGallery extends StatelessWidget {
  const ComponentGallery({super.key});

  static const _segments = [
    MxSegment(value: 'a', label: 'Cards'),
    MxSegment(value: 'b', label: 'Stats'),
  ];

  static const _navItems = [
    MxBottomNavItem(id: 'today', label: 'Today', icon: Icons.today),
    MxBottomNavItem(id: 'library', label: 'Library', icon: Icons.folder),
  ];

  @override
  Widget build(BuildContext context) {
    return MxScaffold(
      appBar: const MxAppBar(
        large: true,
        eyebrow: 'Design system',
        title: 'Components',
      ),
      children: [
        _section('Buttons', Wrap(
          spacing: MxSpacing.space2,
          runSpacing: MxSpacing.space2,
          children: [
            MxButton(label: 'Primary', onPressed: () {}),
            MxButton(label: 'Secondary', variant: MxButtonVariant.secondary, onPressed: () {}),
            MxButton(label: 'Outline', variant: MxButtonVariant.outline, onPressed: () {}),
            MxButton(label: 'Ghost', variant: MxButtonVariant.ghost, onPressed: () {}),
            const MxButton(label: 'Disabled'),
            MxButton(label: 'Delete', danger: true, icon: Icons.delete, onPressed: () {}),
          ],
        )),
        _section('Icon buttons', Row(
          children: [
            MxIconButton(icon: Icons.menu, semanticLabel: 'Menu', onPressed: () {}),
            MxIconButton(icon: Icons.search, semanticLabel: 'Search', variant: MxIconButtonVariant.filled, onPressed: () {}),
            MxIconButton(icon: Icons.add, semanticLabel: 'Add', variant: MxIconButtonVariant.primary, onPressed: () {}),
          ],
        )),
        _section('Avatars', const Row(
          children: [
            MxAvatar(name: 'Nguyen Van'),
            SizedBox(width: MxSpacing.space3),
            MxAvatar(name: 'AB', variant: MxAvatarVariant.accent, size: MxAvatarSize.large, ring: true),
          ],
        )),
        _section('Badges', const Wrap(
          spacing: MxSpacing.space2,
          children: [
            MxBadge(label: '3'),
            MxBadge(label: 'Due', tone: MxBadgeTone.error),
            MxBadge(label: 'OK', tone: MxBadgeTone.success, soft: true),
            MxBadge(dot: true, tone: MxBadgeTone.warning),
          ],
        )),
        _section('Chips', Wrap(
          spacing: MxSpacing.space2,
          children: [
            MxChip(label: 'All', onPressed: () {}),
            MxChip(label: 'Due', selected: true, onPressed: () {}),
            MxChip(label: 'New', variant: MxChipVariant.accent, onPressed: () {}),
          ],
        )),
        _section('Switch + segmented', Row(
          children: [
            MxSwitch(value: true, semanticLabel: 'Toggle', onChanged: (_) {}),
            const SizedBox(width: MxSpacing.space4),
            Expanded(child: MxSegmentedControl(segments: _segments, value: 'a', onChanged: (_) {})),
          ],
        )),
        _section('Cards', Column(
          children: [
            const MxCard(child: Text('Elevated')),
            const SizedBox(height: MxSpacing.space2),
            const MxCard(variant: MxCardVariant.primary, child: Text('Primary')),
            const SizedBox(height: MxSpacing.space2),
            MxCard(variant: MxCardVariant.flat, onPressed: () {}, child: const Text('Flat / interactive')),
          ],
        )),
        _section('Icon tiles', const Row(
          children: [
            MxIconTile(icon: Icons.book),
            SizedBox(width: MxSpacing.space3),
            MxIconTile(icon: Icons.bolt, tone: MxIconTileTone.warning, size: MxIconTileSize.large),
            SizedBox(width: MxSpacing.space3),
            MxIconTile(icon: Icons.star, solid: true),
          ],
        )),
        _section('Progress + rings', const Row(
          children: [
            Expanded(child: MxProgressBar(value: 0.6)),
            SizedBox(width: MxSpacing.space4),
            MxStatRing(percent: 0.7, value: '5', label: 'streak'),
          ],
        )),
        _section('Floating actions', Row(
          children: [
            MxFab(icon: Icons.add, semanticLabel: 'Add', onPressed: () {}),
            const SizedBox(width: MxSpacing.space3),
            MxFab(icon: Icons.play_arrow, label: 'Study', variant: MxFabVariant.accent, onPressed: () {}),
          ],
        )),
        _section('Skeletons', const Column(
          children: [
            MxSkeleton(height: 18),
            SizedBox(height: MxSpacing.space2),
            MxSkeleton(width: 160, height: 14),
          ],
        )),
        _section('Status rows', const MxStatusCardRow(
          term: '안녕하세요',
          meaning: 'Hello (formal)',
          status: MxCardStatus.due,
        )),
        _section('List rows', Column(
          children: [
            MxListRow(title: 'Korean Basics', icon: Icons.folder, subtitle: '42 cards', trailing: const Icon(Icons.chevron_right), onPressed: () {}),
            const MxListRow(title: 'Archived', subtitle: 'Hidden deck', muted: true, last: true),
          ],
        )),
        _section('Choice options', Column(
          children: [
            MxChoiceOption(text: 'Seoul', tone: MxChoiceTone.correct, onPressed: () {}),
            const SizedBox(height: MxSpacing.space2),
            MxChoiceOption(text: 'Busan', tone: MxChoiceTone.wrong, onPressed: () {}),
          ],
        )),
        _section('Callouts', const MxActionCallout(
          icon: Icons.warning,
          text: '8 cards already exist — import anyway?',
        )),
        _section('Search dock', const MxSearchDock(placeholder: 'Search cards')),
        _section('Bottom nav', ClipRRect(
          borderRadius: BorderRadius.circular(MxSpacing.space2),
          child: MxBottomNav(items: _navItems, value: 'today', onChanged: (_) {}),
        )),
        _section('Empty state', const SizedBox(
          height: 240,
          child: MxEmptyState(
            icon: Icons.folder_off,
            title: 'No decks yet',
            text: 'Create your first deck to start learning.',
          ),
        )),
        _section('Overlays', Builder(
          builder: (context) => Wrap(
            spacing: MxSpacing.space2,
            children: [
              MxButton(
                label: 'Dialog',
                variant: MxButtonVariant.outline,
                onPressed: () => showMxConfirmDialog<void>(
                  context: context,
                  icon: Icons.delete,
                  tone: MxDialogTone.error,
                  title: 'Delete this card?',
                  text: "This can't be undone.",
                  actions: [
                    MxButton(label: 'Cancel', variant: MxButtonVariant.ghost, block: true, onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              MxButton(
                label: 'Sheet',
                variant: MxButtonVariant.outline,
                onPressed: () => showMxSheet<void>(
                  context: context,
                  title: 'Sort by',
                  child: const Text('Sheet content'),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _section(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxSectionHeader(title: title),
        const SizedBox(height: MxSpacing.space3),
        content,
      ],
    );
  }
}
