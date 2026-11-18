import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';

/// شبكة المؤشرات التنفيذية لطلب التوريد (ProcurementDetailsMetricsStrip)
///
/// صممت لتجسد أعلى معايير العمق البصري والتسلسل الهرمي في المنصات العالمية:
/// - بطاقات مستقلة متجاوبة مع ظلال وتدرجات ناعمة وعمق بصري مميز.
/// - أيقونات بحاويات ملونة وفق طبيعة المؤشر (مالي، كروت، أوراق، باقات).
/// - خط الهوية المعتمد مع أرقام جدولية موحدة العرض [FontFeature.tabularFigures] وخالية تماماً من الخطوط الأحادية الدخيلة.
/// - تكيف كامل عبر [LayoutBuilder] مع حماية الأرقام بواسطة [FittedBox].
class ProcurementDetailsMetricsStrip extends StatelessWidget {
  const ProcurementDetailsMetricsStrip({super.key, required this.request});

  final RequestEntity request;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final totalSheets = request.totalSheets;
    final sheetsFormatted = totalSheets.truncateToDouble() == totalSheets
        ? totalSheets.toInt().toString()
        : totalSheets.toStringAsFixed(1);

    // بيانات المؤشرات الأربعة الأساسية
    final metrics = [
      _MetricData(
        label: 'إجمالي القيمة',
        value: AmountFormatter.formatValue(request.requestTotalAmount),
        unit: 'ر.ي',
        icon: Icons.account_balance_wallet_rounded,
        accentColor: colors.primary,
        isPrimary: true,
        caption: request.items.isNotEmpty ? 'صافي الطلب' : null,
      ),
      _MetricData(
        label: 'إجمالي الكروت',
        value: '${request.totalVouchers}',
        unit: 'كرت',
        icon: Icons.confirmation_number_rounded,
        accentColor: const Color(0xFF0284C7), // Blue Sky
        caption: 'رصيد إجمالي',
      ),
      _MetricData(
        label: 'عدد الشيتات',
        value: sheetsFormatted,
        unit: 'شيت',
        icon: Icons.layers_rounded,
        accentColor: const Color(0xFF7C3AED), // Violet
        caption: 'طباعة A4',
      ),
      _MetricData(
        label: 'الباقات المطلوبة',
        value: '${request.items.length}',
        unit: 'باقات',
        icon: Icons.widgets_rounded,
        accentColor: const Color(0xFFD97706), // Amber
        caption: 'فئات مختلفة',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;

        if (isCompact) {
          // شبكة 2x2 متجاوبة للشاشات الصغيرة
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: _ExecutiveMetricCard(data: metrics[0])),
                  AppSpacing.hSm,
                  Expanded(child: _ExecutiveMetricCard(data: metrics[1])),
                ],
              ),
              AppSpacing.vSm,
              Row(
                children: [
                  Expanded(child: _ExecutiveMetricCard(data: metrics[2])),
                  AppSpacing.hSm,
                  Expanded(child: _ExecutiveMetricCard(data: metrics[3])),
                ],
              ),
            ],
          );
        }

        // صف أفقي كامل للشاشات اللوحية والواسعة
        return Row(
          children: [
            for (int i = 0; i < metrics.length; i++) ...[
              if (i > 0) AppSpacing.hSm,
              Expanded(child: _ExecutiveMetricCard(data: metrics[i])),
            ],
          ],
        );
      },
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accentColor,
    this.isPrimary = false,
    this.caption,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color accentColor;
  final bool isPrimary;
  final String? caption;
}

class _ExecutiveMetricCard extends StatelessWidget {
  const _ExecutiveMetricCard({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: data.isPrimary
              ? data.accentColor.withValues(alpha: 0.35)
              : colors.outlineVariant.withValues(alpha: 0.35),
          width: data.isPrimary ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: data.isPrimary
                ? data.accentColor.withValues(alpha: 0.06)
                : colors.shadow.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // رأس الكرت: الأيقونة بحاوية ناعمة + اسم المؤشر
          Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: data.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9.r),
                  border: Border.all(
                    color: data.accentColor.withValues(alpha: 0.20),
                    width: 0.8,
                  ),
                ),
                child: Icon(data.icon, size: 16.r, color: data.accentColor),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.label,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (data.caption != null) ...[
                      SizedBox(height: 1.h),
                      Text(
                        data.caption!,
                        style: AppTypography.caption.copyWith(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                          fontSize: 9.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // القيمة الرقمية بخط الهوية مع الأرقام الجدولية
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  data.value,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: data.isPrimary ? data.accentColor : colors.onSurface,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                ),
                SizedBox(width: 4.w),
                Text(
                  data.unit,
                  style: AppTypography.caption.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
