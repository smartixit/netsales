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

/// ============================================================================
/// مصفوفة أداء وتغطية التوزيع الميداني (DashboardDistributionPerformance)
/// ============================================================================
/// توفر نظرة تحليلية غير متماثلة لكفاءة شبكة التوزيع ونقاط البيع والباقة المتصدرة،
/// مع تتبع دقيق لنسبة التحصيل النقدي مقابل الآجل في السوق.
class DashboardDistributionPerformance extends StatelessWidget {
  final DashboardController controller;

  const DashboardDistributionPerformance({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final overview = controller.overview.value;
      if (overview == null) return const SizedBox.shrink();

      final isMasked = controller.isPrivacyMasked.value;
      final kpis = overview.kpis;

      // 1. استخراج بيانات المبيعات
      final salesData = (kpis['sales'] as Map<String, dynamic>?) ?? {};
      final cashAmount = (salesData['cash_sales_amount'] as num?)?.toDouble() ?? 0.0;
      final creditAmount = (salesData['credit_sales_amount'] as num?)?.toDouble() ?? 0.0;
      final totalSales = (salesData['current_amount'] as num?)?.toDouble() ?? (cashAmount + creditAmount);
      final cashRatio = totalSales > 0 ? (cashAmount / totalSales).clamp(0.0, 1.0) : 0.0;

      // 2. استخراج بيانات نقاط البيع
      final posData = (kpis['pos_network'] as Map<String, dynamic>?) ?? {};
      final activePos = (posData['active_count'] as num?)?.toInt() ?? 0;
      final totalPos = (posData['total_count'] as num?)?.toInt() ?? 0;
      final posCoverageRatio = totalPos > 0 ? (activePos / totalPos).clamp(0.0, 1.0) : 0.0;

      // 3. استخراج بيانات الباقة الأكثر طلباً
      final topPackage = (kpis['top_package'] as Map<String, dynamic>?);
      final packageName = topPackage?['package_name'] as String? ?? 'لا توجد مبيعات';
      final vouchersSoldCount = (topPackage?['vouchers_sold_count'] as num?)?.toInt() ?? 0;
      final topRevenue = (topPackage?['revenue'] as num?)?.toDouble() ?? 0.0;

      final formattedTopRevenue = isMasked
          ? '••••••'
          : '${AmountFormatter.formatValue(topRevenue, decimalPlaces: 0)} ر.ي';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Row(
            children: [
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.xsRadius,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.grid_view_rounded,
                  size: 16.r,
                  color: colors.primary,
                ),
              ),
              AppSpacing.hSm,
              Text(
                'مصفوفة كفاءة التوزيع الميداني',
                style: AppTypography.titleMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          AppSpacing.vMd,

          // 1. بطاقة توازن النقد والآجل في السوق
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'توازن التحصيل والائتمان الميداني',
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${(cashRatio * 100).toStringAsFixed(0)}% نقداً',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.success,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                AppSpacing.vSm,
                // شريط التقدم المزدوج (نقد مقابل آجل)
                ClipRRect(
                  borderRadius: AppRadius.fullRadius,
                  child: SizedBox(
                    height: 8.h,
                    child: Row(
                      children: [
                        Expanded(
                          flex: (cashRatio * 100).toInt().clamp(1, 100),
                          child: Container(color: colors.success),
                        ),
                        Expanded(
                          flex: ((1.0 - cashRatio) * 100).toInt().clamp(1, 100),
                          child: Container(color: colors.warning),
                        ),
                      ],
                    ),
                  ),
                ),
                AppSpacing.vSm,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 8.r,
                            height: 8.r,
                            decoration: BoxDecoration(
                              color: colors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          AppSpacing.hXs,
                          Expanded(
                            child: Text(
                              'نقد: ${isMasked ? '••••' : AmountFormatter.formatValue(cashAmount, decimalPlaces: 0)} ر.ي',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 8.r,
                            height: 8.r,
                            decoration: BoxDecoration(
                              color: colors.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                          AppSpacing.hXs,
                          Flexible(
                            child: Text(
                              'آجل: ${isMasked ? '••••' : AmountFormatter.formatValue(creditAmount, decimalPlaces: 0)} ر.ي',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          AppSpacing.vMd,

          // 2. شبكة المؤشرات المتجاورة: تغطية نقاط البيع + الباقة الأكثر طلباً
          Row(
            children: [
              // كارت تغطية نقاط البيع
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 32.r,
                            height: 32.r,
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.12),
                              borderRadius: AppRadius.smRadius,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.storefront_rounded,
                              size: 18.r,
                              color: colors.primary,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.1),
                              borderRadius: AppRadius.xsRadius,
                            ),
                            child: Text(
                              '${(posCoverageRatio * 100).toStringAsFixed(0)}%',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vSm,
                      Text(
                        'نقاط البيع النشطة',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      AppSpacing.vXxs,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              '$activePos',
                              style: AppTypography.titleLarge.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: Text(
                              ' / $totalPos نقطة',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacing.hSm,

              // كارت الباقة المتصدرة
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 32.r,
                            height: 32.r,
                            decoration: BoxDecoration(
                              color: colors.secondary.withValues(alpha: 0.15),
                              borderRadius: AppRadius.smRadius,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.local_fire_department_rounded,
                              size: 18.r,
                              color: colors.secondary,
                            ),
                          ),
                          if (vouchersSoldCount > 0)
                            Text(
                              '$vouchersSoldCount كرت',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.secondary,
                                fontWeight: FontWeight.w800,
                                fontSize: 10.sp,
                              ),
                            ),
                        ],
                      ),
                      AppSpacing.vSm,
                      Text(
                        'الباقة الأكثر طلباً',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      AppSpacing.vXxs,
                      Text(
                        packageName,
                        style: AppTypography.titleSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (topRevenue > 0) ...[
                        AppSpacing.vXxs,
                        Text(
                          formattedTopRevenue,
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
