import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../enums/dashboard_metric_tone.dart';

/// Semantic visual roles for the generic KPI system.
@immutable
class DashboardMetricsTheme extends ThemeExtension<DashboardMetricsTheme> {
  const DashboardMetricsTheme({
    required this.primary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.neutral,
    required this.cardBackground,
    required this.cardBorder,
    required this.mutedForeground,
    this.cardRadius = 16,
    this.cardPadding = 20,
    this.iconRadius = 12,
    this.gridSpacing = 16,
    this.cardShadows = const [],
    this.motionDuration = const Duration(milliseconds: 150),
    this.motionCurve = Curves.easeInOutCubic,
  });

  final Color primary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color neutral;
  final Color cardBackground;
  final Color cardBorder;
  final Color mutedForeground;
  final double cardRadius;
  final double cardPadding;
  final double iconRadius;
  final double gridSpacing;
  final List<BoxShadow> cardShadows;
  final Duration motionDuration;
  final Curve motionCurve;

  Color colorFor(DashboardMetricTone tone) => switch (tone) {
    DashboardMetricTone.primary => primary,
    DashboardMetricTone.success => success,
    DashboardMetricTone.warning => warning,
    DashboardMetricTone.danger => danger,
    DashboardMetricTone.info => info,
    DashboardMetricTone.neutral => neutral,
  };

  static DashboardMetricsTheme of(BuildContext context) {
    final supplied = Theme.of(context).extension<DashboardMetricsTheme>();
    if (supplied != null) return supplied;
    final scheme = Theme.of(context).colorScheme;
    return DashboardMetricsTheme(
      primary: scheme.primary,
      success: scheme.tertiary,
      warning: scheme.secondary,
      danger: scheme.error,
      info: scheme.primary,
      neutral: scheme.onSurfaceVariant,
      cardBackground: scheme.surfaceContainerLowest,
      cardBorder: scheme.outlineVariant,
      mutedForeground: scheme.onSurfaceVariant,
      cardShadows: [
        BoxShadow(
          color: scheme.shadow.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  @override
  DashboardMetricsTheme copyWith({
    Color? primary,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? neutral,
    Color? cardBackground,
    Color? cardBorder,
    Color? mutedForeground,
    double? cardRadius,
    double? cardPadding,
    double? iconRadius,
    double? gridSpacing,
    List<BoxShadow>? cardShadows,
    Duration? motionDuration,
    Curve? motionCurve,
  }) => DashboardMetricsTheme(
    primary: primary ?? this.primary,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    info: info ?? this.info,
    neutral: neutral ?? this.neutral,
    cardBackground: cardBackground ?? this.cardBackground,
    cardBorder: cardBorder ?? this.cardBorder,
    mutedForeground: mutedForeground ?? this.mutedForeground,
    cardRadius: cardRadius ?? this.cardRadius,
    cardPadding: cardPadding ?? this.cardPadding,
    iconRadius: iconRadius ?? this.iconRadius,
    gridSpacing: gridSpacing ?? this.gridSpacing,
    cardShadows: cardShadows ?? this.cardShadows,
    motionDuration: motionDuration ?? this.motionDuration,
    motionCurve: motionCurve ?? this.motionCurve,
  );

  @override
  DashboardMetricsTheme lerp(
    ThemeExtension<DashboardMetricsTheme>? other,
    double t,
  ) {
    if (other is! DashboardMetricsTheme) return this;
    return DashboardMetricsTheme(
      primary: Color.lerp(primary, other.primary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t)!,
      cardPadding: lerpDouble(cardPadding, other.cardPadding, t)!,
      iconRadius: lerpDouble(iconRadius, other.iconRadius, t)!,
      gridSpacing: lerpDouble(gridSpacing, other.gridSpacing, t)!,
      cardShadows: t < 0.5 ? cardShadows : other.cardShadows,
      motionDuration: t < 0.5 ? motionDuration : other.motionDuration,
      motionCurve: t < 0.5 ? motionCurve : other.motionCurve,
    );
  }
}
