import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/workspace/domain/entities/network_workspace_overview_entity.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/indicators/custom_pulsing_indicator.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// كرت منحنى وتيرة المبيعات والتدفقات النقدية القيادي (ExecutiveSalesVelocityChart)
/// مصمم بدقة بنمط تشغيلي فاخر، متجاوب بدون أي تجاوز للحواف، ومرتبط 100% بالبيانات الحقيقية
class ExecutiveSalesVelocityChart extends StatelessWidget {
  final NetworkWorkspaceOverviewEntity overview;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  const ExecutiveSalesVelocityChart({
    super.key,
    required this.overview,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  /// الفترات المعتمدة من الباكيند API (NetworkWorkspaceOverviewRequest)
  static const List<({String key, String label})> _periodOptions = [
    (key: '7d', label: '7 أيام'),
    (key: '30d', label: '30 يوماً'),
    (key: '90d', label: '3 أشهر'),
    (key: '12m', label: 'سنة'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final salesData = overview.metric('sales');
    final rawTrend = salesData?['trend'];
    final List<dynamic> trendList = (rawTrend is List) ? rawTrend : const [];

    final chartPoints = <SalesVelocityPoint>[];
    for (int i = 0; i < trendList.length; i++) {
      final item = trendList[i];
      if (item is Map) {
        final rawDate = item['date']?.toString() ?? '';
        final total = (item['total'] is num)
            ? (item['total'] as num).toDouble()
            : double.tryParse(item['total']?.toString() ?? '0') ?? 0.0;
        final count = (item['count'] is num)
            ? (item['count'] as num).toInt()
            : int.tryParse(item['count']?.toString() ?? '0') ?? 0;

        chartPoints.add(
          SalesVelocityPoint(
            rawDate: rawDate,
            formattedDate: _formatAxisDate(rawDate),
            amount: total,
            count: count,
          ),
        );
      }
    }

    // استخراج المؤشرات المرافقة للمنحنى
    final totalSalesStr = salesData?['total_amount'] != null
        ? AmountFormatter.format(salesData!['total_amount'].toString())
        : '0.00';
    final invoiceCount = salesData?['invoice_count'] is num
        ? (salesData!['invoice_count'] as num).toInt()
        : int.tryParse(salesData?['invoice_count']?.toString() ?? '0') ?? 0;
    final rawGrowth = salesData?['growth_rate'];
    final double growthRate = (rawGrowth is num) ? rawGrowth.toDouble() : 0.0;

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
                  CustomPulsingIndicator(
                    color: colors.primary,
                    size: 8.r,
                  ),
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
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: isCompact ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _periodOptions.map((option) {
                    final isSelected = selectedPeriod == option.key;
                    return isCompact
                        ? Expanded(
                            child: _PeriodPill(
                              label: option.label,
                              isSelected: isSelected,
                              onTap: () => onPeriodChanged(option.key),
                            ),
                          )
                        : _PeriodPill(
                            label: option.label,
                            isSelected: isSelected,
                            onTap: () => onPeriodChanged(option.key),
                          );
                  }).toList(growable: false),
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
              color: isDark
                  ? const Color(0xFF0B132B).withValues(alpha: 0.6)
                  : colors.surfaceContainerHighest.withValues(alpha: 0.45),
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
                              totalSalesStr,
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
                          '$invoiceCount عملية',
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
                              growthRate >= 0
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded,
                              size: 13.r,
                              color: growthRate >= 0
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF43F5E),
                            ),
                            SizedBox(width: 2.w),
                            Flexible(
                              child: Text(
                                '${growthRate >= 0 ? '+' : ''}${growthRate.toStringAsFixed(1)}%',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelSmall.copyWith(
                                  color: growthRate >= 0
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF43F5E),
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

          // 3. مساحة الرسم البياني التفاعلي أو الحالة الفارغة
          if (chartPoints.isNotEmpty)
            SizedBox(
              height: 185.h,
              child: SfCartesianChart(
                margin: EdgeInsets.zero,
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  axisLine: AxisLine(
                    color: colors.outlineVariant.withValues(alpha: 0.35),
                  ),
                  labelStyle: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 8.5.sp,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  isVisible: false,
                  majorGridLines: MajorGridLines(
                    width: 0.6,
                    color: colors.outlineVariant.withValues(alpha: 0.15),
                  ),
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  header: 'تفاصيل المبيعات',
                  format: 'التاريخ: point.x\nالقيمة: point.y ر.ي',
                  canShowMarker: true,
                  textStyle: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                series: <CartesianSeries<SalesVelocityPoint, String>>[
                  SplineAreaSeries<SalesVelocityPoint, String>(
                    dataSource: chartPoints,
                    xValueMapper: (SalesVelocityPoint point, _) =>
                        point.formattedDate,
                    yValueMapper: (SalesVelocityPoint point, _) => point.amount,
                    color: colors.primary.withValues(alpha: 0.18),
                    borderColor: colors.primary,
                    borderWidth: 2.5,
                    splineType: SplineType.natural,
                    gradient: LinearGradient(
                      colors: [
                        colors.primary.withValues(alpha: 0.32),
                        colors.primary.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    markerSettings: MarkerSettings(
                      isVisible: true,
                      shape: DataMarkerType.circle,
                      borderColor: colors.surface,
                      borderWidth: 1.8,
                      color: colors.primary,
                      width: 5.5,
                      height: 5.5,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              height: 120.h,
              alignment: Alignment.center,
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A).withValues(alpha: 0.4)
                    : colors.surfaceContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_graph_rounded,
                    size: 32.r,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.45),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'لا توجد فواتير مبيعات مسجلة في هذه الفترة ($selectedPeriod)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'ستنعكس وتيرة الفواتير والتدفقات النقدية تلقائياً فور تسجيل المبيعات',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 9.5.sp,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// تنسيق التاريخ للعرض في المحور الأفقي بسلاسة دون تزاحم
  static String _formatAxisDate(String rawDate) {
    if (rawDate.isEmpty) return '';
    try {
      if (rawDate.length >= 10) {
        // مثلاً: 2026-11-15 -> 15/11
        final parts = rawDate.split('-');
        if (parts.length >= 3) {
          return '${parts[2]}/${parts[1]}';
        }
      }
    } catch (_) {}
    return rawDate;
  }
}

/// نقطة بيانات في منحنى المبيعات
class SalesVelocityPoint {
  final String rawDate;
  final String formattedDate;
  final double amount;
  final int count;

  const SalesVelocityPoint({
    required this.rawDate,
    required this.formattedDate,
    required this.amount,
    required this.count,
  });
}

/// كبسولة تبديل الفترة الزمنية بأسلوب تفاعلي راقٍ
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
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.badgeText.copyWith(
            color: isSelected ? Colors.white : colors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            fontSize: 9.5.sp,
          ),
        ),
      ),
    );
  }
}
