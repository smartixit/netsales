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
import 'package:netsales/features/home/presentation/controllers/home_layout_controller.dart';
import 'package:netsales/features/partners/presentation/controllers/partners_controller.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// مصفوفة أداء وتغطية التوزيع الميداني (DashboardDistributionPerformance)
/// ============================================================================
/// توفر نظرة تحليلية غير متماثلة لكفاءة شبكة التوزيع ونقاط البيع والباقة المتصدرة،
/// مع تتبع دقيق لنسبة التحصيل النقدي مقابل الآجل في السوق.
class DashboardDistributionPerformance extends StatelessWidget {
  final DashboardController controller;

  const DashboardDistributionPerformance({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final overview = controller.overview.value;
      if (overview == null) return const SizedBox.shrink();

      final isMasked = controller.isPrivacyMasked.value;
      final kpis = overview.kpis;

      // حالة مدير النظام الأعلى: عرض مصفوفة أسطول المنظومة
      if (controller.isSuperAdmin) {
        final networksKpi = (kpis['networks'] as Map<String, dynamic>?) ?? {};
        final totalNetworks = (networksKpi['total'] as num?)?.toInt() ?? 0;
        final approvedNetworks =
            (networksKpi['approved'] as num?)?.toInt() ?? 0;
        final pendingNetworks = (networksKpi['pending'] as num?)?.toInt() ?? 0;

        final posKpi = (kpis['pos'] as Map<String, dynamic>?) ?? {};
        final totalPos = (posKpi['total'] as num?)?.toInt() ?? 0;
        final approvedPos = (posKpi['approved'] as num?)?.toInt() ?? 0;
        final pendingPos = (posKpi['pending'] as num?)?.toInt() ?? 0;

        return _SuperAdminFleetBento(
          totalNetworks: totalNetworks,
          approvedNetworks: approvedNetworks,
          pendingNetworks: pendingNetworks,
          totalPos: totalPos,
          approvedPos: approvedPos,
          pendingPos: pendingPos,
        );
      }

      // 1. استخراج بيانات المبيعات
      final salesData = (kpis['sales'] as Map<String, dynamic>?) ?? {};
      final cashAmount =
          (salesData['cash_sales_amount'] as num?)?.toDouble() ?? 0.0;
      final creditAmount =
          (salesData['credit_sales_amount'] as num?)?.toDouble() ?? 0.0;
      final totalSales =
          (salesData['current_amount'] as num?)?.toDouble() ??
          (cashAmount + creditAmount);
      final cashRatio = totalSales > 0
          ? (cashAmount / totalSales).clamp(0.0, 1.0)
          : 0.0;

      // 2. استخراج بيانات نقاط البيع
      final posData = (kpis['pos_network'] as Map<String, dynamic>?) ?? {};
      final activePos = (posData['active_count'] as num?)?.toInt() ?? 0;
      final totalPos = (posData['total_count'] as num?)?.toInt() ?? 0;
      final posCoverageRatio = totalPos > 0
          ? (activePos / totalPos).clamp(0.0, 1.0)
          : 0.0;

      // 3. استخراج بيانات الباقة الأكثر طلباً
      final topPackage = (kpis['top_package'] as Map<String, dynamic>?);
      final packageName =
          topPackage?['package_name'] as String? ?? 'لا توجد مبيعات';
      final vouchersSoldCount =
          (topPackage?['vouchers_sold_count'] as num?)?.toInt() ?? 0;
      final topRevenue = (topPackage?['revenue'] as num?)?.toDouble() ?? 0.0;

      final formattedTopRevenue = isMasked
          ? '••••••'
          : '${AmountFormatter.formatValue(topRevenue, decimalPlaces: 0)} ر.ي';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ترويسة القسم السيادية الراقية
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'مصفوفة كفاءة التوزيع الميداني',
                style: AppTypography.titleMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3.h,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: AppRadius.fullRadius,
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.25),
                    width: 0.8.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpacing.hXs,
                    Text(
                      'تحليل حي',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.vMd,

          // 1. بطاقة توازن النقد والآجل في السوق (Executive Cash vs Credit Bento)
          Container(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'توازن السيولة والائتمان الميداني',
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.success.withValues(alpha: 0.12),
                        borderRadius: AppRadius.fullRadius,
                      ),
                      child: Text(
                        '${(cashRatio * 100).toStringAsFixed(0)}% نقداً',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.success,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.vSm,
                // شريط التدفق المالي المزدوج (Dual Flow Track)
                ClipRRect(
                  borderRadius: AppRadius.fullRadius,
                  child: Container(
                    height: 8.h,
                    color: colors.surfaceContainerHighest,
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
                AppSpacing.vMd,
                // كبسولات التفصيل المالي
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: AppRadius.smRadius,
                          border: Border.all(
                            color: colors.outlineVariant.withValues(
                              alpha: 0.15,
                            ),
                            width: 0.8.w,
                          ),
                        ),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'تحصيل نقدي',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                  Text(
                                    isMasked
                                        ? '••••••'
                                        : '${AmountFormatter.formatValue(cashAmount, decimalPlaces: 0)} ر.ي',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: AppRadius.smRadius,
                          border: Border.all(
                            color: colors.outlineVariant.withValues(
                              alpha: 0.15,
                            ),
                            width: 0.8.w,
                          ),
                        ),
                        child: Row(
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ائتمان آجل',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                  Text(
                                    isMasked
                                        ? '••••••'
                                        : '${AmountFormatter.formatValue(creditAmount, decimalPlaces: 0)} ر.ي',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
              // كارت تغطية نقاط البيع مع ارتداد تفاعلي
              Expanded(
                child: CustomInteractiveBounce(
                  onTap: () {
                    if (Get.isRegistered<HomeLayoutController>()) {
                      Get.find<HomeLayoutController>().changeTab(2);
                      if (Get.isRegistered<PartnersController>()) {
                        Get.find<PartnersController>().changeSegment(1);
                      }
                    }
                  },
                  child: Container(
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
                                borderRadius: AppRadius.fullRadius,
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
                          'تغطية نقاط البيع',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpacing.vXxs,
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$activePos',
                                style: AppTypography.titleLarge.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              AppSpacing.hXxs,
                              Text(
                                '/ $totalPos نشطة',
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              AppSpacing.hSm,

              // كارت الباقة المتصدرة (Hero Sovereign Package)
              Expanded(
                child: Container(
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
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: colors.secondary.withValues(alpha: 0.1),
                                borderRadius: AppRadius.fullRadius,
                              ),
                              child: Text(
                                '$vouchersSoldCount كرت',
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.secondary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                        ],
                      ),
                      AppSpacing.vSm,
                      Text(
                        'الأعلى طلباً',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
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
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            formattedTopRevenue,
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                            ),
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

/// ============================================================================
/// ودجت مصفوفة أسطول المنظومة لمدير النظام الأعلى (Super Admin Fleet Bento)
/// ============================================================================
class _SuperAdminFleetBento extends StatelessWidget {
  final int totalNetworks;
  final int approvedNetworks;
  final int pendingNetworks;
  final int totalPos;
  final int approvedPos;
  final int pendingPos;

  const _SuperAdminFleetBento({
    required this.totalNetworks,
    required this.approvedNetworks,
    required this.pendingNetworks,
    required this.totalPos,
    required this.approvedPos,
    required this.pendingPos,
  });

  void _navigateToPartners(int segmentIndex) {
    if (Get.isRegistered<HomeLayoutController>()) {
      Get.find<HomeLayoutController>().changeTab(2); // تبويب الشركاء
      if (Get.isRegistered<PartnersController>()) {
        Get.find<PartnersController>().changeSegment(segmentIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ترويسة سيادية راقية
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'مصفوفة أسطول التوزيع والشبكات',
              style: AppTypography.titleMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 3.h,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: AppRadius.fullRadius,
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.25),
                  width: 0.8.w,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6.r,
                    height: 6.r,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  AppSpacing.hXs,
                  Text(
                    'المنظومة كاملة',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        AppSpacing.vMd,

        // صف البطاقتين
        Row(
          children: [
            // 1. أسطول شبكات الإنترنت
            Expanded(
              child: _FleetTile(
                title: 'شبكات الإنترنت',
                activeCount: approvedNetworks,
                totalCount: totalNetworks,
                pendingCount: pendingNetworks,
                icon: Icons.cell_tower_rounded,
                iconColor: colors.primary,
                iconBgColor: colors.primaryContainer.withValues(alpha: 0.4),
                onTap: () => _navigateToPartners(0),
              ),
            ),

            AppSpacing.hMd,

            // 2. أسطول نقاط البيع
            Expanded(
              child: _FleetTile(
                title: 'نقاط التوزيع الميداني',
                activeCount: approvedPos,
                totalCount: totalPos,
                pendingCount: pendingPos,
                icon: Icons.point_of_sale_rounded,
                iconColor: colors.secondary,
                iconBgColor: colors.secondaryContainer.withValues(alpha: 0.4),
                onTap: () => _navigateToPartners(1),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FleetTile extends StatelessWidget {
  final String title;
  final int activeCount;
  final int totalCount;
  final int pendingCount;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback onTap;

  const _FleetTile({
    required this.title,
    required this.activeCount,
    required this.totalCount,
    required this.pendingCount,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.lgRadius,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.3),
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
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: iconColor, size: 20.r),
                ),
                if (pendingCount > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.warning.withValues(alpha: 0.2),
                      borderRadius: AppRadius.fullRadius,
                    ),
                    child: Text(
                      '$pendingCount معلق',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.warning,
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            AppSpacing.vSm,
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.vXxs,
            Text(
              '$activeCount نشطة',
              style: AppTypography.titleLarge.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 18.sp,
              ),
            ),
            AppSpacing.vXxs,
            Text(
              'من إجمالي $totalCount مسجلة',
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
