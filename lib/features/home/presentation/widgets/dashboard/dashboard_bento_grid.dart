import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/widgets/animations/custom_interactive_bounce.dart';

/// ============================================================================
/// شبكة بينتو للمؤشرات التحليلية (DashboardBentoGrid)
/// ============================================================================
/// تصميم شبكي متناسق (Bento Grid) يعرض إحصائيات المبيعات، ومعدل النمو،
/// وعدد الكروت المباعة، وحالة نقاط البيع مع مؤشرات الصعود والهبوط.
class DashboardBentoGrid extends StatelessWidget {
  final Map<String, dynamic> kpis;

  const DashboardBentoGrid({
    super.key,
    required this.kpis,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // استخراج بيانات المبيعات
    final sales = (kpis['sales'] as Map<String, dynamic>?) ?? {};
    final curSales = ((sales['cur_amount'] ?? 0.0) as num).toDouble();
    final growthPct = ((sales['growth_pct'] ?? 0.0) as num).toDouble();
    final isPositiveGrowth = growthPct >= 0;

    // استخراج بيانات الكروت
    final vouchers = (kpis['vouchers'] as Map<String, dynamic>?) ?? {};
    final vouchersSold = ((vouchers['sold_count'] ?? 0) as num).toInt();

    // استخراج بيانات نقاط البيع
    final posCount = (kpis['pos_count'] as Map<String, dynamic>?) ?? {};
    final activePos = ((posCount['active'] ?? 0) as num).toInt();
    final totalPos = ((posCount['total'] ?? 0) as num).toInt();

    // استخراج بيانات الطلبات
    final requests = (kpis['requests'] as Map<String, dynamic>?) ?? {};
    final pendingRequests = ((requests['pending_count'] ?? 0) as num).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مؤشرات الأداء التراكمية',
          style: AppTypography.titleMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.vMd,

        // الصف الأول: بطاقة المبيعات الكبرى + بطاقة الكروت المباعة
        Row(
          children: [
            // بطاقة المبيعات مع نسبة النمو
            Expanded(
              flex: 3,
              child: _BentoCard(
                icon: Icons.trending_up_rounded,
                iconColor: colors.primary,
                title: 'إجمالي المبيعات',
                value: AmountFormatter.formatValue(curSales),
                unit: 'ر.ي',
                badgeText: '${isPositiveGrowth ? '+' : ''}${AmountFormatter.formatValue(growthPct, decimalPlaces: 1)}%',
                isPositiveBadge: isPositiveGrowth,
              ),
            ),
            AppSpacing.hMd,
            // بطاقة الكروت المباعة
            Expanded(
              flex: 2,
              child: _BentoCard(
                icon: Icons.confirmation_number_outlined,
                iconColor: colors.secondary,
                title: 'الكروت المباعة',
                value: vouchersSold.toString(),
                unit: 'كرت',
              ),
            ),
          ],
        ),

        AppSpacing.vMd,

        // الصف الثاني: نقاط البيع النشطة + طلبات التوريد
        Row(
          children: [
            // بطاقة نقاط البيع
            Expanded(
              child: _BentoCard(
                icon: Icons.storefront_outlined,
                iconColor: colors.tertiary,
                title: 'نقاط البيع النشطة',
                value: '$activePos / $totalPos',
                unit: 'نقطة',
              ),
            ),
            AppSpacing.hMd,
            // بطاقة طلبات الكروت
            Expanded(
              child: _BentoCard(
                icon: Icons.inventory_2_outlined,
                iconColor: pendingRequests > 0 ? colors.warning : colors.primary,
                title: 'الطلبات المعلقة',
                value: pendingRequests.toString(),
                unit: 'طلب',
                isHighlighted: pendingRequests > 0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// بطاقة ذرية داخل شبكة بينتو
class _BentoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String unit;
  final String? badgeText;
  final bool isPositiveBadge;
  final bool isHighlighted;

  const _BentoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.unit,
    this.badgeText,
    this.isPositiveBadge = true,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.lgRadius,
          border: Border.all(
            color: isHighlighted
                ? colors.warning.withValues(alpha: 0.5)
                : colors.outlineVariant.withValues(alpha: 0.6),
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
                  padding: EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.smRadius,
                  ),
                  child: Icon(icon, color: iconColor, size: 18.r),
                ),
                if (badgeText != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: isPositiveBadge
                          ? colors.success.withValues(alpha: 0.12)
                          : colors.error.withValues(alpha: 0.12),
                      borderRadius: AppRadius.fullRadius,
                    ),
                    child: Text(
                      badgeText!,
                      style: AppTypography.labelSmall.copyWith(
                        color: isPositiveBadge ? colors.success : colors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
              ],
            ),
            AppSpacing.vSm,
            Text(
              title,
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
                    value,
                    style: AppTypography.titleLarge.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.hXs,
                  Text(
                    unit,
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
    );
  }
}
