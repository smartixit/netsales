import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/debts/domain/entities/debt_summary_entity.dart';

class AgingSummaryStrip extends StatelessWidget {
  final AgingSummaryEntity aging;

  const AgingSummaryStrip({super.key, required this.aging});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تحليل أعمار الديون (Aging Buckets)',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              Text(
                'الإجمالي: ${AmountFormatter.formatValue(aging.total, decimalPlaces: 0)} ر.ي',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          // شريط النسبة المئوية الملون (Segmented Proportional Bar)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: SizedBox(
              height: 10.h,
              child: aging.total <= 0
                  ? Container(color: colors.outlineVariant)
                  : Row(
                      children: [
                        if (aging.bucket0To30 > 0)
                          Expanded(
                            flex: (aging.percentage0To30 * 10).round().clamp(1, 1000),
                            child: Container(color: const Color(0xFF10B981)), // Emerald Green
                          ),
                        if (aging.bucket31To60 > 0)
                          Expanded(
                            flex: (aging.percentage31To60 * 10).round().clamp(1, 1000),
                            child: Container(color: const Color(0xFFF59E0B)), // Amber
                          ),
                        if (aging.bucket61To90 > 0)
                          Expanded(
                            flex: (aging.percentage61To90 * 10).round().clamp(1, 1000),
                            child: Container(color: const Color(0xFFF97316)), // Orange
                          ),
                        if (aging.bucketOver90 > 0)
                          Expanded(
                            flex: (aging.percentageOver90 * 10).round().clamp(1, 1000),
                            child: Container(color: const Color(0xFFEF4444)), // Red
                          ),
                      ],
                    ),
            ),
          ),
          AppSpacing.vMd,
          // البنود الأربعة التفصيلية
          Row(
            children: [
              _buildBucketPill(
                context,
                label: '0 - 30 يوم',
                amount: '${AmountFormatter.formatValue(aging.bucket0To30, decimalPlaces: 0)} ر.ي',
                color: const Color(0xFF10B981),
              ),
              SizedBox(width: 6.w),
              _buildBucketPill(
                context,
                label: '31 - 60 يوم',
                amount: '${AmountFormatter.formatValue(aging.bucket31To60, decimalPlaces: 0)} ر.ي',
                color: const Color(0xFFF59E0B),
              ),
              SizedBox(width: 6.w),
              _buildBucketPill(
                context,
                label: '61 - 90 يوم',
                amount: '${AmountFormatter.formatValue(aging.bucket61To90, decimalPlaces: 0)} ر.ي',
                color: const Color(0xFFF97316),
              ),
              SizedBox(width: 6.w),
              _buildBucketPill(
                context,
                label: '> 90 يوم',
                amount: '${AmountFormatter.formatValue(aging.bucketOver90, decimalPlaces: 0)} ر.ي',
                color: const Color(0xFFEF4444),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBucketPill(
    BuildContext context, {
    required String label,
    required String amount,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6.r,
                  height: 6.r,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              amount,
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 10.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
