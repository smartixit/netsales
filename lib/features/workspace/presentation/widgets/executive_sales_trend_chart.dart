import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/models/network_workspace_dashboard_view_model.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/charts/charting.dart';
import 'package:netsales/widgets/menus/custom_popup_menu.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_shimmer.dart';

/// Sales trend panel arranged to match the mobile dashboard reference:
/// compact period selector, chart, server-provided total and growth.
class ExecutiveSalesTrendChart extends StatelessWidget {
  const ExecutiveSalesTrendChart({
    super.key,
    required this.chartDefinition,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.summary,
    this.isLoading = false,
  });

  final ChartDefinition chartDefinition;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;
  final NetworkSalesTrendSummary summary;
  final bool isLoading;

  static const List<ChartPeriodOption> periodOptions = [
    ChartPeriodOption(id: '7d', label: 'آخر 7 أيام'),
    ChartPeriodOption(id: '30d', label: 'آخر 30 يوماً'),
    ChartPeriodOption(id: '90d', label: 'آخر 3 أشهر'),
    ChartPeriodOption(id: '12m', label: 'آخر سنة'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final period = periodOptions.firstWhere(
      (item) => item.id == selectedPeriod,
      orElse: () => periodOptions[1],
    );
    final isGrowthPositive = summary.growthRate >= 0;

    return CustomSurfaceCard(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: colors.primary,
                size: 19.r,
              ),
              AppSpacing.hSm,
              Expanded(
                child: Text(
                  'اتجاه المبيعات',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              CustomPopupMenu<String>(
                minWidth: 150.w,
                trigger: Container(
                  constraints: BoxConstraints(minHeight: 34.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.65),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        period.label,
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpacing.hXs,
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16.r,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                items: periodOptions
                    .map(
                      (option) => CustomPopupItem<String>(
                        value: option.id,
                        label: option.label,
                        icon: Icons.calendar_today_rounded,
                        trailing: option.id == selectedPeriod
                            ? Icon(
                                Icons.check_rounded,
                                size: 17.r,
                                color: colors.primary,
                              )
                            : null,
                      ),
                    )
                    .toList(growable: false),
                onSelected: onPeriodChanged,
              ),
            ],
          ),
          AppSpacing.vMd,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: AppSpacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'إجمالي المبيعات',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      if (isLoading)
                        CustomSkeletonShimmer(
                          child: Container(
                            width: 90.w,
                            height: 22.h,
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                            ),
                          ),
                        )
                      else
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            summary.totalSales.isEmpty
                                ? '—'
                                : summary.totalSales,
                            maxLines: 1,
                            style: AppTypography.headlineSmall.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                      SizedBox(height: 9.h),
                      if (isLoading)
                        CustomSkeletonShimmer(
                          child: Container(
                            width: 55.w,
                            height: 18.h,
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (isGrowthPositive
                                        ? colors.success
                                        : colors.error)
                                    .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isGrowthPositive
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                size: 15.r,
                                color: isGrowthPositive
                                    ? colors.success
                                    : colors.error,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${isGrowthPositive ? '+' : ''}${summary.growthRate.toStringAsFixed(1)}%',
                                style: AppTypography.labelMedium.copyWith(
                                  color: isGrowthPositive
                                      ? colors.success
                                      : colors.error,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                flex: 6,
                child: SizedBox(
                  height: 148.h,
                  child: NetSalesChartsThemeAdapter.wrap(
                    context: context,
                    child: ChartRenderer(
                      definition: isLoading
                          ? chartDefinition.copyWith(state: ChartState.loading)
                          : chartDefinition,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
