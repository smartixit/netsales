import 'package:flutter/material.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/themes/app_colors.dart';
import '../src/theme/dashboard_metrics_theme.dart';

/// Bridges the generic KPI semantic theme to the existing NetSales tokens.
/// Keep this adapter at the host boundary; generic KPI widgets do not import
/// NetSales core classes.
class NetSalesDashboardMetricsThemeAdapter {
  const NetSalesDashboardMetricsThemeAdapter._();

  static DashboardMetricsTheme of(BuildContext context) {
    final colors = AppColors.of(context);
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
      cardRadius: AppRadius.card,
      cardPadding: AppSpacing.cardPadding,
      iconRadius: AppRadius.md,
    );
  }

  static Widget wrap({
    required BuildContext context,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        extensions: <ThemeExtension<dynamic>>[
          ...theme.extensions.values.where(
            (extension) => extension is! DashboardMetricsTheme,
          ),
          of(context),
        ],
      ),
      child: child,
    );
  }
}
