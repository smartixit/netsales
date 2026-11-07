import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Semantic, host-independent chart theme supplied through ThemeExtensions.
@immutable
class ChartsTheme extends ThemeExtension<ChartsTheme> {
  const ChartsTheme({
    required this.primary,
    required this.text,
    required this.mutedText,
    required this.surface,
    required this.cardSurface,
    required this.border,
    required this.gridLine,
    required this.tooltipSurface,
    required this.tooltipText,
    required this.palette,
    this.cardRadius = 16,
    this.cardPadding = 18,
    this.cardElevation = const <BoxShadow>[],
    this.axisLabelSize = 11,
    this.titleSize = 15,
    this.motionDuration = const Duration(milliseconds: 180),
    this.motionCurve = Curves.easeOutCubic,
  });

  final Color primary;
  final Color text;
  final Color mutedText;
  final Color surface;
  final Color cardSurface;
  final Color border;
  final Color gridLine;
  final Color tooltipSurface;
  final Color tooltipText;
  final List<Color> palette;
  final double cardRadius;
  final double cardPadding;
  final List<BoxShadow> cardElevation;
  final double axisLabelSize;
  final double titleSize;
  final Duration motionDuration;
  final Curve motionCurve;

  static ChartsTheme of(BuildContext context) {
    final extension = Theme.of(context).extension<ChartsTheme>();
    if (extension != null) {
      return extension;
    }
    final scheme = Theme.of(context).colorScheme;
    return ChartsTheme(
      primary: scheme.primary,
      text: scheme.onSurface,
      mutedText: scheme.onSurfaceVariant,
      surface: scheme.surface,
      cardSurface: scheme.surfaceContainerLowest,
      border: scheme.outlineVariant,
      gridLine: scheme.outlineVariant.withValues(alpha: 0.45),
      tooltipSurface: scheme.inverseSurface,
      tooltipText: scheme.onInverseSurface,
      palette: <Color>[
        scheme.primary,
        scheme.tertiary,
        scheme.secondary,
        scheme.error,
        const Color(0xFF5B8DEF),
        const Color(0xFFB779D0),
        const Color(0xFFDA8A43),
      ],
    );
  }

  @override
  ChartsTheme copyWith({
    Color? primary,
    Color? text,
    Color? mutedText,
    Color? surface,
    Color? cardSurface,
    Color? border,
    Color? gridLine,
    Color? tooltipSurface,
    Color? tooltipText,
    List<Color>? palette,
    double? cardRadius,
    double? cardPadding,
    List<BoxShadow>? cardElevation,
    double? axisLabelSize,
    double? titleSize,
    Duration? motionDuration,
    Curve? motionCurve,
  }) => ChartsTheme(
    primary: primary ?? this.primary,
    text: text ?? this.text,
    mutedText: mutedText ?? this.mutedText,
    surface: surface ?? this.surface,
    cardSurface: cardSurface ?? this.cardSurface,
    border: border ?? this.border,
    gridLine: gridLine ?? this.gridLine,
    tooltipSurface: tooltipSurface ?? this.tooltipSurface,
    tooltipText: tooltipText ?? this.tooltipText,
    palette: palette ?? this.palette,
    cardRadius: cardRadius ?? this.cardRadius,
    cardPadding: cardPadding ?? this.cardPadding,
    cardElevation: cardElevation ?? this.cardElevation,
    axisLabelSize: axisLabelSize ?? this.axisLabelSize,
    titleSize: titleSize ?? this.titleSize,
    motionDuration: motionDuration ?? this.motionDuration,
    motionCurve: motionCurve ?? this.motionCurve,
  );

  @override
  ChartsTheme lerp(ThemeExtension<ChartsTheme>? other, double t) {
    if (other is! ChartsTheme) {
      return this;
    }
    return ChartsTheme(
      primary: Color.lerp(primary, other.primary, t)!,
      text: Color.lerp(text, other.text, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      border: Color.lerp(border, other.border, t)!,
      gridLine: Color.lerp(gridLine, other.gridLine, t)!,
      tooltipSurface: Color.lerp(tooltipSurface, other.tooltipSurface, t)!,
      tooltipText: Color.lerp(tooltipText, other.tooltipText, t)!,
      palette: t < 0.5 ? palette : other.palette,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t)!,
      cardPadding: lerpDouble(cardPadding, other.cardPadding, t)!,
      cardElevation: t < 0.5 ? cardElevation : other.cardElevation,
      axisLabelSize: lerpDouble(axisLabelSize, other.axisLabelSize, t)!,
      titleSize: lerpDouble(titleSize, other.titleSize, t)!,
      motionDuration: t < 0.5 ? motionDuration : other.motionDuration,
      motionCurve: t < 0.5 ? motionCurve : other.motionCurve,
    );
  }
}
