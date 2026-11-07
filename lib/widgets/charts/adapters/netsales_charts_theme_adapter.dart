import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_elevation.dart';
import '../../../core/themes/app_motion.dart';
import '../src/theme/charts_theme.dart';

/// Adapts NetSales design tokens at the application boundary.
class NetSalesChartsThemeAdapter {
  const NetSalesChartsThemeAdapter._();

  static ChartsTheme of(BuildContext context) {
    final colors = AppColors.of(context);
    final screenUtil = ScreenUtil();
    final widthScale = screenUtil.scaleWidth == 0 ? 1.0 : screenUtil.scaleWidth;
    final radiusScale = screenUtil.radius(1) == 0 ? 1.0 : screenUtil.radius(1);

    return ChartsTheme(
      primary: colors.primary,
      text: colors.onSurface,
      mutedText: colors.onSurfaceVariant,
      surface: colors.surface,
      cardSurface: colors.surfaceContainerLowest,
      border: colors.outlineVariant,
      gridLine: colors.outlineVariant.withValues(alpha: 0.42),
      tooltipSurface: colors.inverseSurface,
      tooltipText: colors.onInverseSurface,
      palette: <Color>[
        colors.primary,
        colors.secondary,
        colors.tertiary,
        colors.info,
        colors.warning,
        colors.error,
        colors.success,
      ],
      cardRadius: AppRadius.card / radiusScale,
      cardPadding: AppSpacing.cardPadding / widthScale,
      cardElevation: AppElevation.level1(context),
      motionDuration: AppMotion.duration(context, AppMotion.fast),
    );
  }

  static Widget wrap({
    required BuildContext context,
    required Widget child,
  }) {
    final baseTheme = Theme.of(context);
    final extensions = baseTheme.extensions.values
        .where((extension) => extension is! ChartsTheme)
        .toList(growable: true);
    extensions.add(of(context));

    return Theme(
      data: baseTheme.copyWith(extensions: extensions),
      child: child,
    );
  }
}
