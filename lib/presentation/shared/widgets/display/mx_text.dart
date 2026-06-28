import 'package:flutter/material.dart';

/// A semantic type-scale slot.
enum MxTextRole {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
}

/// Brand-typography text — the design-system text role API.
///
/// Purpose:
/// The single place that reads the theme [TextTheme]. Screens pick a semantic
/// role instead of touching `Theme.of(context).textTheme`, so typography stays
/// consistent and centralized.
///
/// Use when:
/// Rendering any text in a screen or widget.
///
/// Do not use when:
/// The text style comes from a parent widget contract (e.g. a button label).
///
/// Category:
/// display
///
/// Public API:
/// - data: the string to render
/// - role: the type-scale slot (default bodyMedium)
/// - color / weight: optional overrides
/// - maxLines / overflow / textAlign: standard text layout options
///
/// States:
/// default
class MxText extends StatelessWidget {
  const MxText(
    this.data, {
    super.key,
    this.role = MxTextRole.bodyMedium,
    this.color,
    this.weight,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  /// Headline (`headlineSmall`) — section/screen heading.
  const MxText.headline(
    this.data, {
    super.key,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
  }) : role = MxTextRole.headlineSmall,
       weight = null;

  /// Title (`titleMedium`) — card/list-section title.
  const MxText.title(
    this.data, {
    super.key,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
  }) : role = MxTextRole.titleMedium,
       weight = null;

  /// Body (`bodyMedium`) — default paragraph text.
  const MxText.body(
    this.data, {
    super.key,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
  }) : role = MxTextRole.bodyMedium,
       weight = null;

  /// Label (`labelMedium`) — captions/metadata.
  const MxText.label(
    this.data, {
    super.key,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
  }) : role = MxTextRole.labelMedium,
       weight = null;

  final String data;
  final MxTextRole role;
  final Color? color;
  final FontWeight? weight;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final base = switch (role) {
      MxTextRole.displayLarge => t.displayLarge,
      MxTextRole.displayMedium => t.displayMedium,
      MxTextRole.displaySmall => t.displaySmall,
      MxTextRole.headlineLarge => t.headlineLarge,
      MxTextRole.headlineMedium => t.headlineMedium,
      MxTextRole.headlineSmall => t.headlineSmall,
      MxTextRole.titleLarge => t.titleLarge,
      MxTextRole.titleMedium => t.titleMedium,
      MxTextRole.titleSmall => t.titleSmall,
      MxTextRole.bodyLarge => t.bodyLarge,
      MxTextRole.bodyMedium => t.bodyMedium,
      MxTextRole.bodySmall => t.bodySmall,
      MxTextRole.labelLarge => t.labelLarge,
      MxTextRole.labelMedium => t.labelMedium,
      MxTextRole.labelSmall => t.labelSmall,
    };
    return Text(
      data,
      style: base?.copyWith(color: color, fontWeight: weight),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
