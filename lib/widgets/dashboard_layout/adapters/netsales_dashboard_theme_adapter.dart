import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/themes/app_breakpoints.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_elevation.dart';
import '../../../core/themes/app_motion.dart';

import '../src/theme/dashboard_layout_theme.dart';

/// Maps the NetSales design language to reusable dashboard semantic roles.
class NetSalesDashboardThemeAdapter {
  const NetSalesDashboardThemeAdapter._();

  static DashboardLayoutTheme of(BuildContext context) {
    final colors = AppColors.of(context);
    final isDesktop = AppBreakpoints.isDesktop(context);

    // Convert ScreenUtil-backed design tokens back to their logical baseline.
    // This preserves the established token source without scaling desktop
    // navigation geometry by the mobile 375dp design width.
    final screenUtil = ScreenUtil();
    final widthScale = screenUtil.scaleWidth == 0 ? 1.0 : screenUtil.scaleWidth;
    final radiusScale = screenUtil.radius(1) == 0 ? 1.0 : screenUtil.radius(1);

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
      itemRadius: AppRadius.md / radiusScale,
      sidebarPadding: isDesktop
          ? AppSpacing.lg / widthScale
          : AppSpacing.md / widthScale,
      itemSpacing: AppSpacing.xs / widthScale,
      sectionSpacing: isDesktop
          ? AppSpacing.xl / widthScale
          : AppSpacing.lg / widthScale,
      contentPadding: isDesktop
          ? AppSpacing.xxl / widthScale
          : AppSpacing.lg / widthScale,
      motionDuration: AppMotion.duration(context, AppMotion.normal),
      motionCurve: AppMotion.standard,
    );
  }

  /// Wrap the shell once at the host boundary; generic widgets consume only
  /// the ThemeExtension and never import NetSales core services.
  static Widget wrap({required BuildContext context, required Widget child}) {
    final baseTheme = Theme.of(context);
    return Theme(
      data: baseTheme.copyWith(
        extensions: <ThemeExtension<dynamic>>[
          ...baseTheme.extensions.values.where(
            (extension) => extension is! DashboardLayoutTheme,
          ),
          of(context),
        ],
      ),
      child: child,
    );
  }

  /// Exposes the established shadow vocabulary to host-provided surfaces.
  static List<BoxShadow> sidebarElevation(BuildContext context) =>
      AppElevation.level1(context);
}
