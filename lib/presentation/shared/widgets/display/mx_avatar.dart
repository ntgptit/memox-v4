import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_spacing.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';

/// Size step for [MxAvatar].
enum MxAvatarSize { sm, md, lg }

/// A user/profile avatar — the design kit's `MxAvatar`.
///
/// Purpose:
/// A circular avatar that shows an image, or initials from a name as a fallback,
/// with an optional brand ring.
///
/// Use when:
/// Representing a person or account.
///
/// Do not use when:
/// Showing a feature/category icon (use MxIconTile).
///
/// Category:
/// display
///
/// Public API:
/// - name: display name (used for the initials fallback)
/// - image: optional avatar image
/// - size: sm / md / lg
/// - accent: use the accent tint instead of primary
/// - ring: draw a brand ring around the avatar
///
/// States:
/// image, initials
class MxAvatar extends StatelessWidget {
  const MxAvatar({
    super.key,
    this.name,
    this.image,
    this.size = MxAvatarSize.md,
    this.accent = false,
    this.ring = false,
  });

  final String? name;
  final ImageProvider<Object>? image;
  final MxAvatarSize size;
  final bool accent;
  final bool ring;

  double get _diameter => switch (size) {
    MxAvatarSize.sm => MxSpacing.space7,
    MxAvatarSize.md => MxSpacing.space9,
    MxAvatarSize.lg => MxSpacing.space11,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = MxTheme.of(context).colors;
    final tintBg = accent ? colors.accentSoft : colors.primarySoft;
    final tintFg = accent ? colors.accent : colors.primary;
    final avatar = Container(
      width: _diameter,
      height: _diameter,
      decoration: BoxDecoration(
        color: tintBg,
        shape: BoxShape.circle,
        image: image == null
            ? null
            : DecorationImage(image: image!, fit: BoxFit.cover),
        border: ring ? Border.all(color: colors.primary, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: image == null
          ? Text(
              _initials(name),
              style: theme.textTheme.labelMedium?.copyWith(color: tintFg),
            )
          : null,
    );
    return avatar;
  }

  static String _initials(String? name) {
    final parts = (name ?? '').trim().split(RegExp(r'\s+'));
    final letters = parts
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return letters.isEmpty ? '?' : letters;
  }
}
