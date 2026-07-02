import 'package:equatable/equatable.dart';

/// Colour mode (personalization BR-1): light, dark, or follow the OS.
enum ColorMode { light, dark, system }

/// Accent colour, chosen from the preset token palette (BR-2).
enum AccentColor { brand, warm, cool }

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
