import 'package:flutter/material.dart';

/// Accent options — all map to existing brand/semantic roles (no new tokens).
enum AccentChoice { brand, warm, cool }

/// Font scale presets.
enum FontScale { small, medium, large }

extension FontScaleX on FontScale {
  double get factor => switch (this) {
    FontScale.small => 0.9,
    FontScale.medium => 1.0,
    FontScale.large => 1.15,
  };
}

/// Personalization preferences (`docs/business/personalization/personalization.md`).
class ThemePrefs {
  const ThemePrefs({
    this.mode = ThemeMode.system,
    this.accent = AccentChoice.brand,
    this.fontScale = FontScale.medium,
  });

  final ThemeMode mode;
  final AccentChoice accent;
  final FontScale fontScale;

  ThemePrefs copyWith({
    ThemeMode? mode,
    AccentChoice? accent,
    FontScale? fontScale,
  }) => ThemePrefs(
    mode: mode ?? this.mode,
    accent: accent ?? this.accent,
    fontScale: fontScale ?? this.fontScale,
  );

  static ThemeMode parseMode(String? raw) => switch (raw) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  static AccentChoice parseAccent(String? raw) => AccentChoice.values
      .firstWhere((a) => a.name == raw, orElse: () => AccentChoice.brand);

  static FontScale parseFontScale(String? raw) => FontScale.values.firstWhere(
    (f) => f.name == raw,
    orElse: () => FontScale.medium,
  );
}
