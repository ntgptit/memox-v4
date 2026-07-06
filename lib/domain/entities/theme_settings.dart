import 'package:equatable/equatable.dart';

/// Colour mode (personalization BR-1): light, dark, or follow the OS.
enum ColorMode { light, dark, system }

/// Accent colour, chosen from the preset token palette (BR-2). The six values map
/// 1:1 to the kit's accent swatches (indigo · violet · green · coral · amber ·
/// cyan); `brand`/`warm`/`cool` are the original indigo/coral/cyan (kept for
/// back-compat with persisted values). Display order lives in `themeAccentOrder`.
enum AccentColor { brand, warm, cool, violet, green, amber }

/// Text-size preference (BR-2).
enum FontScale { small, medium, large }

/// The learner's appearance preferences (personalization). Applied live and
/// persisted (BR-3). Defaults are system mode, the brand accent, medium text.
class ThemeSettings extends Equatable {
  const ThemeSettings({
    this.mode = ColorMode.system,
    this.accent = AccentColor.brand,
    this.fontScale = FontScale.medium,
  });

  final ColorMode mode;
  final AccentColor accent;
  final FontScale fontScale;

  ThemeSettings copyWith({
    ColorMode? mode,
    AccentColor? accent,
    FontScale? fontScale,
  }) {
    return ThemeSettings(
      mode: mode ?? this.mode,
      accent: accent ?? this.accent,
      fontScale: fontScale ?? this.fontScale,
    );
  }

  @override
  List<Object> get props => [mode, accent, fontScale];
}
