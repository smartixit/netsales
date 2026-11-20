import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/charts/charting.dart';
import 'package:netsales/widgets/indicators/custom_pulsing_indicator.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// كرت منحنى وتيرة المبيعات والتدفقات النقدية (ExecutiveSalesVelocityChart)
/// يعتمد 100% على منظومة الرسوم البيانية المركزية الموحدة في lib/widgets/charts/
class ExecutiveSalesVelocityChart extends StatelessWidget {
  final ChartDefinition chartDefinition;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;
  final ({String totalSales, int invoiceCount, double growthRate}) summary;

  const ExecutiveSalesVelocityChart({
    super.key,
    required this.chartDefinition,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.summary,
  });

  /// الفترات المعتمدة من الباكيند API
  static const List<ChartPeriodOption> periodOptions = [
    ChartPeriodOption(id: '7d', label: '7 أيام'),
    ChartPeriodOption(id: '30d', label: '30 يوماً'),
    ChartPeriodOption(id: '90d', label: '3 أشهر'),
    ChartPeriodOption(id: '12m', label: 'سنة'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomSurfaceCard(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. رأس البطاقة المتجاوب (العنوان ومحدد الفترة)
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 360;

              final titleSection = Row(
                children: [
                  CustomPulsingIndicator(color: colors.primary, size: 8.r),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'منحنى وتيرة المبيعات والطلبات',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleMedium.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5.sp,
                          ),
                        ),
                        Text(
                          'حجم الفواتير الصادرة وسرعة التدفقات النقدية الفعلية',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 10.5.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final periodSelector = Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: isCompact ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: periodOptions
                      .map((option) {
                        final isSelected = selectedPeriod == option.id;
                        return isCompact
                            ? Expanded(
                                child: _PeriodPill(
                                  label: option.label,
                                  isSelected: isSelected,
                                  onTap: () => onPeriodChanged(option.id),
                                ),
                              )
                            : _PeriodPill(
                                label: option.label,
                                isSelected: isSelected,
                                onTap: () => onPeriodChanged(option.id),
                              );
                      })
                      .toList(growable: false),
                ),
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    titleSection,
                    SizedBox(height: AppSpacing.sm),
                    periodSelector,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: titleSection),
                  SizedBox(width: 8.w),
                  periodSelector,
                ],
              );
            },
          ),
          SizedBox(height: AppSpacing.md),

          // 2. شريط المؤشرات القيادي السريع المدمج مع المنحنى
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                // مبيعات الفترة
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إجمالي مبيعات الفترة',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 9.5.sp,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              summary.totalSales,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.titleMedium.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w900,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'ر.ي',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 9.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 28.h,
                  color: colors.outlineVariant.withValues(alpha: 0.3),
                ),
                // عدد الفواتير
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'عدد العمليات',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 9.5.sp,
                          ),
                        ),
                        Text(
                          '${summary.invoiceCount} عملية',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 28.h,
                  color: colors.outlineVariant.withValues(alpha: 0.3),
                ),
                // وتيرة النمو
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(right: 6.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'وتيرة النمو',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 9.5.sp,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              summary.growthRate >= 0
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded,
                              size: 13.r,
                              color: summary.growthRate >= 0 ? colors.success : colors.error,
                            ),
                            SizedBox(width: 2.w),
                            Flexible(
                              child: Text(
                                '${summary.growthRate >= 0 ? '+' : ''}${summary.growthRate.toStringAsFixed(1)}%',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelSmall.copyWith(
                                  color: summary.growthRate >= 0 ? colors.success : colors.error,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10.5.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.sm),

          // 3. مساحة الرسم البياني التفاعلي عبر محرك ChartRenderer المركزي
          SizedBox(
            height: 185.h,
            child: NetSalesChartsThemeAdapter.wrap(
              context: context,
              child: ChartRenderer(definition: chartDefinition),
            ),
          ),
        ],
      ),
    );
  }
}

/// كبسولة تبديل الفترة الزمنية
class _PeriodPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.5.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: isSelected ? AppElevation.tinted(context, colors.primary, alpha: 0.18, blur: 6, dy: 1) : AppElevation.level0(context),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.badgeText.copyWith(
            color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            fontSize: 9.5.sp,
          ),
        ),
      ),
    );
  }
}
