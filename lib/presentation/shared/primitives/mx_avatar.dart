import 'package:flutter/material.dart';
import 'package:memox_v4/core/theme/mx_component.dart';
import 'package:memox_v4/core/theme/mx_theme.dart';
import 'package:memox_v4/core/theme/mx_typography.dart';

/// Size step for [MxAvatar], mirroring the kit (`md` is the base).
enum MxAvatarSize { small, medium, large }

/// Fill for [MxAvatar]: the neutral primary tint (base) or the accent tint.
enum MxAvatarVariant { neutral, accent }

/// The kit's circular avatar with an image or initials fallback (`MxAvatar` ·
/// base class `.avatar`). A primitive — pure presentation, token-driven.
///
/// The kit's `src` URL maps to an idiomatic Flutter [ImageProvider] ([image]);
/// when it is null the two-letter initials of [name] are shown. When [name] is
/// given it is exposed as the semantics label so the avatar is announced.
class MxAvatar extends StatelessWidget {
  const MxAvatar({
    this.name,
    this.image,
    this.size = MxAvatarSize.medium,
    this.variant = MxAvatarVariant.neutral,
    this.ring = false,
    super.key,
  });

  final String? name;
  final ImageProvider? image;
  final MxAvatarSize size;
  final MxAvatarVariant variant;

  /// A primary ring around the avatar (kit `.avatar--ring`).
  final bool ring;

  // Kit `.avatar` diameters — raw px with no matching MxSizes token.
  static const double _dimMedium = MxComponentSizes.avatarMd;
  static const double _dimSmall = MxComponentSizes.avatarSm;
  static const double _dimLarge = MxComponentSizes.avatarLg;

  /// Two-letter uppercase initials from [name] (first letter of the first two
  /// words), matching the kit fallback.
  static String initialsOf(String? name) {
    if (name == null) return '';
    final words =
        name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    final second = words.length > 1 ? words[1][0] : '';
    return (words.first[0] + second).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final mx = MxTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final image = this.image;

    final dim = switch (size) {
      MxAvatarSize.small => _dimSmall,
      MxAvatarSize.medium => _dimMedium,
      MxAvatarSize.large => _dimLarge,
    };
    final fontSize = switch (size) {
      MxAvatarSize.small => MxTypography.sizeSm,
      MxAvatarSize.medium => MxTypography.sizeBase,
      MxAvatarSize.large => MxTypography.sizeLg,
    };
    final (background, foreground) = switch (variant) {
      MxAvatarVariant.neutral => (mx.primarySoft, mx.onPrimarySoft),
      MxAvatarVariant.accent => (mx.accentSoft, scheme.onSecondary),
    };

    final Widget content = image == null
        ? Text(
            initialsOf(name),
            style: TextStyle(
              fontFamily: MxTypography.fontFamily,
              fontSize: fontSize,
              fontWeight: MxTypography.bold,
              color: foreground,
            ),
          )
        : ClipOval(
            child: Image(
              image: image,
              width: dim,
              height: dim,
              fit: BoxFit.cover,
            ),
          );

    return Semantics(
      label: name,
      image: image != null,
      child: Container(
        width: dim,
        height: dim,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: background,
          boxShadow: ring
              ? [
                  // Outer primary ring, then the 2px surface gap on top of it.
                  BoxShadow(color: scheme.primary, spreadRadius: 4),
                  BoxShadow(color: mx.surface, spreadRadius: 2),
                ]
              : null,
        ),
        child: content,
      ),
    );
  }
}
