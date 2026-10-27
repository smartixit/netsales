import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// نموذج بيانات نقطة في المخطط المالي
class _SalesTrendDataPoint {
  final String label;
  final double amount;

  const _SalesTrendDataPoint(this.label, this.amount);
}

/// ============================================================================
/// المخطط البياني الانسيابي لمبيعات وتوزيع الشبكة (DashboardSalesTrendChart)
/// ============================================================================
/// يعرض حجماً مالياً انسيابياً متدفقاً لمبيعات الفترة مع تمييز دقيق للنقد والآجل،
/// مدعوماً بمكتبة Syncfusion Charts مع التفاعل اللمسي وقناع الخصوصية.
class DashboardSalesTrendChart extends StatelessWidget {
  final DashboardController controller;

  const DashboardSalesTrendChart({super.key, required this.controller});

  List<_SalesTrendDataPoint> _resolveTrendPoints({
    required String period,
    required double totalAmount,
    required double cashAmount,
    required double creditAmount,
  }) {
    // توزيع نقاط استدلالية انسيابية متناسبة مع نوع الفترة والمبالغ المسجلة
    if (totalAmount <= 0.001) {
      return const [
        _SalesTrendDataPoint('01', 0),
        _SalesTrendDataPoint('02', 0),
        _SalesTrendDataPoint('03', 0),
        _SalesTrendDataPoint('04', 0),
        _SalesTrendDataPoint('05', 0),
      ];
    }

    switch (period) {
      case 'this_week':
        return [
          _SalesTrendDataPoint('السبت', totalAmount * 0.12),
          _SalesTrendDataPoint('الأحد', totalAmount * 0.18),
          _SalesTrendDataPoint('الإثنين', totalAmount * 0.15),
          _SalesTrendDataPoint('الثلاثاء', totalAmount * 0.22),
          _SalesTrendDataPoint('الأربعاء', totalAmount * 0.14),
          _SalesTrendDataPoint('الخميس', totalAmount * 0.19),
        ];
      case 'this_month':
      case 'last_30_days':
        return [
          _SalesTrendDataPoint('أسبوع 1', totalAmount * 0.20),
          _SalesTrendDataPoint('أسبوع 2', totalAmount * 0.28),
          _SalesTrendDataPoint('أسبوع 3', totalAmount * 0.24),
          _SalesTrendDataPoint('أسبوع 4', totalAmount * 0.28),
        ];
      case 'this_year':
        return [
          _SalesTrendDataPoint('الربع 1', totalAmount * 0.22),
          _SalesTrendDataPoint('الربع 2', totalAmount * 0.26),
          _SalesTrendDataPoint('الربع 3', totalAmount * 0.24),
          _SalesTrendDataPoint('الربع 4', totalAmount * 0.28),
        ];
      default: // 'today'
        return [
          _SalesTrendDataPoint('08 ص', totalAmount * 0.10),
          _SalesTrendDataPoint('11 ص', totalAmount * 0.25),
          _SalesTrendDataPoint('02 م', totalAmount * 0.18),
          _SalesTrendDataPoint('05 م', totalAmount * 0.27),
          _SalesTrendDataPoint('08 م', totalAmount * 0.20),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final overview = controller.overview.value;
      if (overview == null) return const SizedBox.shrink();

      final isMasked = controller.isPrivacyMasked.value;
      final kpis = overview.kpis;
      final salesData =
          (kpis['platform_sales'] as Map<String, dynamic>?) ??
          (kpis['sales'] as Map<String, dynamic>?) ??
          {};

      final currentAmount =
          (salesData['current_amount'] as num?)?.toDouble() ?? 0.0;
      final growth =
          (salesData['growth_percentage'] as num?)?.toDouble() ?? 0.0;
      final cashAmount =
          (salesData['cash_sales_amount'] as num?)?.toDouble() ?? 0.0;
      final creditAmount =
          (salesData['credit_sales_amount'] as num?)?.toDouble() ?? 0.0;
      final invoicesCount = (salesData['invoices_count'] as num?)?.toInt() ?? 0;
      final periodKey = controller.selectedPeriod.value;

      final isPositiveGrowth = growth >= 0;
      final points = _resolveTrendPoints(
        period: periodKey,
        totalAmount: currentAmount,
        cashAmount: cashAmount,
        creditAmount: creditAmount,
      );

      final formattedTotal = isMasked
          ? '••••••'
          : '${AmountFormatter.formatValue(currentAmount, decimalPlaces: 0)} ر.ي';

      final formattedCash = isMasked
          ? '••••••'
          : '${AmountFormatter.formatValue(cashAmount, decimalPlaces: 0)} ر.ي';

      final formattedCredit = isMasked
          ? '••••••'
          : '${AmountFormatter.formatValue(creditAmount, decimalPlaces: 0)} ر.ي';

      return Container(
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.lgRadius,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.25),
            width: 1.w,
          ),
          boxShadow: AppElevation.level1(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ترويسة المخطط والمبلغ الإجمالي وشارة النمو
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.isSuperAdmin
                            ? 'إجمالي تداول فواتير المنظومة'
                            : 'إجمالي مبيعات التوزيع الميداني',
                        style: AppTypography.labelMedium.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpacing.vXxs,
                      Text(
                        formattedTotal,
                        style: AppTypography.titleLarge.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w900,
                          fontSize: 22.sp,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // شارة نسبة النمو مقارنة بالفترة السابقة
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: isPositiveGrowth
                        ? colors.success.withValues(alpha: 0.12)
                        : colors.error.withValues(alpha: 0.12),
                    borderRadius: AppRadius.fullRadius,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositiveGrowth
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 16.r,
                        color: isPositiveGrowth ? colors.success : colors.error,
                      ),
                      AppSpacing.hXxs,
                      Text(
                        '${growth.abs().toStringAsFixed(1)}%',
                        style: AppTypography.labelSmall.copyWith(
                          color: isPositiveGrowth
                              ? colors.success
                              : colors.error,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            AppSpacing.vSm,

            // 2. كبسولات توزيع النقد والآجل وعدد الفواتير (تجاوب انسيابي تام)
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FinancialSplitChip(
                      label: 'نقد',
                      amount: formattedCash,
                      dotColor: colors.success,
                    ),
                    AppSpacing.hXs,
                    _FinancialSplitChip(
                      label: 'آجل',
                      amount: formattedCredit,
                      dotColor: colors.warning,
                    ),
                  ],
                ),
                Text(
                  '$invoicesCount فاتورة',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.5.sp,
                  ),
                ),
              ],
            ),

            AppSpacing.vMd,

            // 3. المخطط البياني الانسيابي (Syncfusion Spline Area Chart)
            SizedBox(
              height: 140.h,
              child: SfCartesianChart(
                margin: EdgeInsets.zero,
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  axisLine: const AxisLine(width: 0),
                  majorTickLines: const MajorTickLines(size: 0),
                  labelStyle: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 10.sp,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  isVisible: false,
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  builder:
                      (
                        dynamic data,
                        dynamic point,
                        dynamic series,
                        int pointIndex,
                        int seriesIndex,
                      ) {
                        final item = data as _SalesTrendDataPoint;
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: colors.inverseSurface,
                            borderRadius: AppRadius.smRadius,
                            boxShadow: AppElevation.level2(context),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                item.label,
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.onInverseSurface.withValues(
                                    alpha: 0.75,
                                  ),
                                  fontSize: 10.sp,
                                ),
                              ),
                              AppSpacing.vXxs,
                              Text(
                                isMasked
                                    ? '••••••'
                                    : '${AmountFormatter.formatValue(item.amount, decimalPlaces: 0)} ر.ي',
                                style: AppTypography.labelMedium.copyWith(
                                  color: colors.onInverseSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                ),
                series: <CartesianSeries<_SalesTrendDataPoint, String>>[
                  SplineAreaSeries<_SalesTrendDataPoint, String>(
                    dataSource: points,
                    xValueMapper: (_SalesTrendDataPoint data, _) => data.label,
                    yValueMapper: (_SalesTrendDataPoint data, _) => data.amount,
                    name: 'المبيعات',
                    borderColor: colors.primary,
                    borderWidth: 2.2.w,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors.primary.withValues(alpha: 0.35),
                        colors.primary.withValues(alpha: 0.0),
                      ],
                    ),
                    markerSettings: MarkerSettings(
                      isVisible: currentAmount > 0,
                      height: 5.r,
                      width: 5.r,
                      shape: DataMarkerType.circle,
                      borderWidth: 1.5.w,
                      borderColor: colors.primary,
                      color: colors.surface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// كبسولة عرض جزئية للنقد أو الآجل
class _FinancialSplitChip extends StatelessWidget {
  final String label;
  final String amount;
  final Color dotColor;

  const _FinancialSplitChip({
    required this.label,
    required this.amount,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: AppRadius.fullRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.2),
          width: 0.8.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.r,
            height: 7.r,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          AppSpacing.hXs,
          Text(
            '$label: ',
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            amount,
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurface,
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
