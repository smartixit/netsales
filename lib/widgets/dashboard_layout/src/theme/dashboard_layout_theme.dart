import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

@immutable
class DashboardLayoutTheme extends ThemeExtension<DashboardLayoutTheme> {
  const DashboardLayoutTheme({
    required this.sidebarBackground,
    required this.sidebarForeground,
    required this.sidebarMuted,
    required this.sidebarSelectedBackground,
    required this.sidebarSelectedForeground,
    required this.sidebarHoverBackground,
    required this.topbarBackground,
    required this.contentBackground,
    required this.border,
    required this.badgeBackground,
    required this.badgeForeground,
    this.sidebarRadius = 0,
    this.itemRadius = 12,
    this.sidebarPadding = 16,
    this.itemSpacing = 4,
    this.sectionSpacing = 20,
    this.contentPadding = 28,
    this.motionDuration = const Duration(milliseconds: 250),
    this.motionCurve = Curves.easeInOutCubic,
  });

  final Color sidebarBackground;
  final Color sidebarForeground;
  final Color sidebarMuted;
  final Color sidebarSelectedBackground;
  final Color sidebarSelectedForeground;
  final Color sidebarHoverBackground;
  final Color topbarBackground;
  final Color contentBackground;
  final Color border;
  final Color badgeBackground;
  final Color badgeForeground;
  final double sidebarRadius;
  final double itemRadius;
  final double sidebarPadding;
  final double itemSpacing;
  final double sectionSpacing;
  final double contentPadding;
  final Duration motionDuration;
  final Curve motionCurve;

  static DashboardLayoutTheme of(BuildContext context) {
    final theme = Theme.of(context).extension<DashboardLayoutTheme>();
    if (theme != null) return theme;
    final scheme = Theme.of(context).colorScheme;
    return DashboardLayoutTheme(
      sidebarBackground: scheme.surface,
      sidebarForeground: scheme.onSurface,
      sidebarMuted: scheme.onSurfaceVariant,
      sidebarSelectedBackground: scheme.primaryContainer,
      sidebarSelectedForeground: scheme.onPrimaryContainer,
      sidebarHoverBackground: scheme.surfaceContainerHighest,
      topbarBackground: scheme.surface,
      contentBackground: scheme.surface,
      border: scheme.outlineVariant,
      badgeBackground: scheme.primary,
      badgeForeground: scheme.onPrimary,
    );
  }

  @override
  DashboardLayoutTheme copyWith({
    Color? sidebarBackground,
    Color? sidebarForeground,
    Color? sidebarMuted,
    Color? sidebarSelectedBackground,
    Color? sidebarSelectedForeground,
    Color? sidebarHoverBackground,
    Color? topbarBackground,
    Color? contentBackground,
    Color? border,
    Color? badgeBackground,
    Color? badgeForeground,
    double? sidebarRadius,
    double? itemRadius,
    double? sidebarPadding,
    double? itemSpacing,
    double? sectionSpacing,
    double? contentPadding,
    Duration? motionDuration,
    Curve? motionCurve,
  }) => DashboardLayoutTheme(
    sidebarBackground: sidebarBackground ?? this.sidebarBackground,
    sidebarForeground: sidebarForeground ?? this.sidebarForeground,
    sidebarMuted: sidebarMuted ?? this.sidebarMuted,
    sidebarSelectedBackground: sidebarSelectedBackground ?? this.sidebarSelectedBackground,
    sidebarSelectedForeground: sidebarSelectedForeground ?? this.sidebarSelectedForeground,
    sidebarHoverBackground: sidebarHoverBackground ?? this.sidebarHoverBackground,
    topbarBackground: topbarBackground ?? this.topbarBackground,
    contentBackground: contentBackground ?? this.contentBackground,
    border: border ?? this.border,
    badgeBackground: badgeBackground ?? this.badgeBackground,
    badgeForeground: badgeForeground ?? this.badgeForeground,
    sidebarRadius: sidebarRadius ?? this.sidebarRadius,
    itemRadius: itemRadius ?? this.itemRadius,
    sidebarPadding: sidebarPadding ?? this.sidebarPadding,
    itemSpacing: itemSpacing ?? this.itemSpacing,
    sectionSpacing: sectionSpacing ?? this.sectionSpacing,
    contentPadding: contentPadding ?? this.contentPadding,
    motionDuration: motionDuration ?? this.motionDuration,
    motionCurve: motionCurve ?? this.motionCurve,
  );

  @override
  DashboardLayoutTheme lerp(ThemeExtension<DashboardLayoutTheme>? other, double t) {
    if (other is! DashboardLayoutTheme) return this;
    return DashboardLayoutTheme(
      sidebarBackground: Color.lerp(sidebarBackground, other.sidebarBackground, t)!,
      sidebarForeground: Color.lerp(sidebarForeground, other.sidebarForeground, t)!,
      sidebarMuted: Color.lerp(sidebarMuted, other.sidebarMuted, t)!,
      sidebarSelectedBackground: Color.lerp(sidebarSelectedBackground, other.sidebarSelectedBackground, t)!,
      sidebarSelectedForeground: Color.lerp(sidebarSelectedForeground, other.sidebarSelectedForeground, t)!,
      sidebarHoverBackground: Color.lerp(sidebarHoverBackground, other.sidebarHoverBackground, t)!,
      topbarBackground: Color.lerp(topbarBackground, other.topbarBackground, t)!,
      contentBackground: Color.lerp(contentBackground, other.contentBackground, t)!,
      border: Color.lerp(border, other.border, t)!,
      badgeBackground: Color.lerp(badgeBackground, other.badgeBackground, t)!,
      badgeForeground: Color.lerp(badgeForeground, other.badgeForeground, t)!,
      sidebarRadius: lerpDouble(sidebarRadius, other.sidebarRadius, t)!,
      itemRadius: lerpDouble(itemRadius, other.itemRadius, t)!,
      sidebarPadding: lerpDouble(sidebarPadding, other.sidebarPadding, t)!,
      itemSpacing: lerpDouble(itemSpacing, other.itemSpacing, t)!,
      sectionSpacing: lerpDouble(sectionSpacing, other.sectionSpacing, t)!,
      contentPadding: lerpDouble(contentPadding, other.contentPadding, t)!,
      motionDuration: t < 0.5 ? motionDuration : other.motionDuration,
      motionCurve: t < 0.5 ? motionCurve : other.motionCurve,
    );
  }
}
