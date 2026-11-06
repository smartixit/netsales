import 'package:flutter/material.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/themes/app_breakpoints.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_elevation.dart';
import '../../../core/themes/app_motion.dart';

import '../src/theme/dashboard_layout_theme.dart';

/// Maps the NetSales design language to the reusable dashboard semantic roles.
/// This adapter is the only layer that knows about NetSales design tokens.
class NetSalesDashboardThemeAdapter {
  const NetSalesDashboardThemeAdapter._();

  static DashboardLayoutTheme of(BuildContext context) {
    final colors = AppColors.of(context);
    final desktop = AppBreakpoints.isDesktop(context);
    // ScreenUtil-backed spacing/radius tokens are scaled in the mobile design
    // coordinate space. Dashboard dimensions are desktop logical pixels, so
    // fixed desktop-safe values are used for layout geometry while semantic
    // radii and colors remain sourced from the existing design system.
    return DashboardLayoutTheme(
      sidebarBackground: colors.surfaceContainerLowest,
      sidebarForeground: colors.onSurface,
      sidebarMuted: colors.onSurfaceVariant,
      sidebarSelectedBackground: colors.primaryContainer,
      sidebarSelectedForeground: colors.onPrimaryContainer,
      sidebarHoverBackground: colors.surfaceContainerLow,
      topbarBackground: colors.surfaceContainerLowest,
      contentBackground: colors.background,
      border: colors.outlineVariant,
      badgeBackground: colors.primary,
      badgeForeground: colors.onPrimary,
      sidebarRadius: 0,
      itemRadius: AppRadius.md,
      sidebarPadding: desktop ? 18 : AppSpacing.md,
      itemSpacing: 4,
      sectionSpacing: 18,
      contentPadding: desktop ? 28 : AppSpacing.lg,
      motionDuration: AppMotion.duration(context, AppMotion.normal),
      motionCurve: AppMotion.standard,
    );
  }
}
