import 'package:flutter/material.dart';

import 'core/theme/mx_colors.dart';
import 'core/theme/mx_elevation.dart';
import 'core/theme/mx_radius.dart';
import 'core/theme/mx_spacing.dart';
import 'core/theme/mx_typography.dart';

void main() => runApp(const MemoxApp());

/// Builds a Material [ThemeData] from the generated design tokens ([MxColors] +
/// [MxTypography]) for one brightness. This is the seam where the Tier-0 token
/// mirrors become the app's actual theme — a full Tier-1 theme (extensions for
/// the non-Material roles) will grow from here.
ThemeData _themeFrom(MxColors c, Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: MxColors.seed,
    brightness: brightness,
  ).copyWith(
    primary: c.primary,
    onPrimary: c.onPrimary,
    primaryContainer: c.primarySoft,
    onPrimaryContainer: c.onPrimarySoft,
    secondary: c.accent,
    onSecondary: c.onAccent,
    secondaryContainer: c.accentSoft,
    error: c.error,
    onError: c.onError,
    surface: c.surface,
    onSurface: c.text,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    fontFamily: MxTypography.fontFamily,
    textTheme: const TextTheme().apply(
      bodyColor: c.text,
      displayColor: c.text,
    ),
  );
}

class MemoxApp extends StatefulWidget {
  const MemoxApp({super.key});

  @override
  State<MemoxApp> createState() => _MemoxAppState();
}

class _MemoxAppState extends State<MemoxApp> {
  ThemeMode _mode = ThemeMode.light;

  void _toggle() => setState(
    () => _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoX',
      debugShowCheckedModeBanner: false,
      theme: _themeFrom(MxColors.light, Brightness.light),
      darkTheme: _themeFrom(MxColors.dark, Brightness.dark),
      themeMode: _mode,
      home: _TokenShowcase(
        isDark: _mode == ThemeMode.dark,
        onToggle: _toggle,
      ),
    );
  }
}

/// A throwaway screen that renders directly from the tokens — proof the Tier-0
/// mirrors drive real pixels (color, type, spacing, radius, shadow) in both
/// themes. Replaced by real screens once Tier 1/2 land.
class _TokenShowcase extends StatelessWidget {
  const _TokenShowcase({required this.isDark, required this.onToggle});

  final bool isDark;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final c = isDark ? MxColors.dark : MxColors.light;
    final shadows = isDark ? MxShadows.dark : MxShadows.light;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MxSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MemoX',
                    style: TextStyle(
                      fontSize: MxTypography.size2xl,
                      fontWeight: MxTypography.extrabold,
                      letterSpacing: MxTypography.size2xl * MxTypography.trackingTight,
                      color: c.text,
                    ),
                  ),
                  IconButton(
                    onPressed: onToggle,
                    icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                    color: c.primary,
                  ),
                ],
              ),
              const SizedBox(height: MxSpacing.space2),
              Text(
                'Tier-0 design tokens, applied.',
                style: TextStyle(
                  fontSize: MxTypography.sizeBase,
                  color: c.textSecondary,
                ),
              ),
              const SizedBox(height: MxSpacing.space6),

              // A card surface: radius + shadow + surface color from tokens.
              Container(
                padding: const EdgeInsets.all(MxSpacing.space5),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: MxRadius.cardRadius,
                  boxShadow: shadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Card surface',
                      style: TextStyle(
                        fontSize: MxTypography.sizeLg,
                        fontWeight: MxTypography.bold,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: MxSpacing.space1),
                    Text(
                      'MxRadius.card · MxShadows.card · MxColors.surface',
                      style: TextStyle(
                        fontSize: MxTypography.sizeSm,
                        color: c.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MxSpacing.space6),

              Text(
                'Semantic palette',
                style: TextStyle(
                  fontSize: MxTypography.sizeMd,
                  fontWeight: MxTypography.semibold,
                  color: c.text,
                ),
              ),
              const SizedBox(height: MxSpacing.space3),
              Wrap(
                spacing: MxSpacing.space3,
                runSpacing: MxSpacing.space3,
                children: [
                  _Swatch('primary', c.primary, c.onPrimary),
                  _Swatch('accent', c.accent, c.onAccent),
                  _Swatch('success', c.success, c.onSuccess),
                  _Swatch('warning', c.warning, c.onWarning),
                  _Swatch('error', c.error, c.onError),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.label, this.bg, this.fg);

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MxSpacing.space4,
        vertical: MxSpacing.space3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: MxRadius.controlRadius,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: MxTypography.sizeSm,
          fontWeight: MxTypography.semibold,
          color: fg,
        ),
      ),
    );
  }
}
