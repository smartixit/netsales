import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_elevation.dart';
import '../../../core/themes/app_motion.dart';
import '../../../core/themes/app_breakpoints.dart';
import '../src/theme/dashboard_metrics_theme.dart';

/// Bridges the generic KPI semantic theme to the existing NetSales tokens.
/// Keep this adapter at the host boundary; generic KPI widgets do not import
/// NetSales core classes.
class NetSalesDashboardMetricsThemeAdapter {
  const NetSalesDashboardMetricsThemeAdapter._();

  static DashboardMetricsTheme of(BuildContext context) {
    final colors = AppColors.of(context);
    final screenUtil = ScreenUtil();
    final widthScale = screenUtil.scaleWidth == 0 ? 1.0 : screenUtil.scaleWidth;
    final radiusScale = screenUtil.radius(1) == 0 ? 1.0 : screenUtil.radius(1);
    return DashboardMetricsTheme(
      primary: colors.primary,
      success: colors.success,
      warning: colors.warning,
      danger: colors.error,
      info: colors.info,
      neutral: colors.onSurfaceVariant,
      cardBackground: colors.surfaceContainerLowest,
      cardBorder: colors.outlineVariant,
      mutedForeground: colors.onSurfaceVariant,
      cardRadius: AppRadius.card / radiusScale,
      cardPadding: AppSpacing.cardPadding / widthScale,
      iconRadius: AppRadius.md / radiusScale,
      gridSpacing: AppBreakpoints.gridGutter(context),
      cardShadows: AppElevation.level1(context),
      motionDuration: AppMotion.duration(context, AppMotion.fast),
      motionCurve: AppMotion.standard,
    );
  }

  static Widget wrap({required BuildContext context, required Widget child}) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        extensions: <ThemeExtension<dynamic>>[
          for (final extension in theme.extensions.values)
            if (extension is! DashboardMetricsTheme)
              extension as ThemeExtension<ThemeExtension<dynamic>>,
          of(context) as ThemeExtension<ThemeExtension<dynamic>>,
        ],
      ),
      child: child,
    );
  }
}
