import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/widgets/cards/custom_kpi_card.dart';

/// ============================================================================
/// شبكة بينتو للمؤشرات التحليلية (DashboardBentoGrid)
/// ============================================================================
/// تصميم شبكي متناسق (Bento Grid) يعرض إحصائيات المبيعات، ومعدل النمو،
/// وعدد الكروت المباعة، وحالة نقاط البيع مع مؤشرات الصعود والهبوط.
class DashboardBentoGrid extends StatelessWidget {
  final Map<String, dynamic> kpis;
  final bool isMasked;

  const DashboardBentoGrid({
    super.key,
    required this.kpis,
    this.isMasked = false,
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

    final formattedSales = isMasked
        ? '••••••••'
        : AmountFormatter.formatValue(curSales);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مؤشرات الأداء للشبكة المحددة',
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
              child: CustomKpiCard.standard(
                icon: Icons.trending_up_rounded,
                iconColor: colors.primary,
                title: 'إجمالي المبيعات',
                value: formattedSales,
                unit: 'ر.ي',
                badgeText: '${isPositiveGrowth ? '+' : ''}${AmountFormatter.formatValue(growthPct, decimalPlaces: 1)}%',
                isPositiveBadge: isPositiveGrowth,
              ),
            ),
            AppSpacing.hMd,
            // بطاقة الكروت المباعة
            Expanded(
              flex: 2,
              child: CustomKpiCard.standard(
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
              child: CustomKpiCard.standard(
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
              child: pendingRequests > 0
                  ? CustomKpiCard.highlighted(
                      icon: Icons.inventory_2_outlined,
                      iconColor: colors.warning,
                      title: 'الطلبات المعلقة',
                      value: pendingRequests.toString(),
                      unit: 'طلب',
                    )
                  : CustomKpiCard.standard(
                      icon: Icons.inventory_2_outlined,
                      iconColor: colors.primary,
                      title: 'الطلبات المعلقة',
                      value: pendingRequests.toString(),
                      unit: 'طلب',
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

