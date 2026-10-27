import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';

/// ============================================================================
/// كارت تقدير قيمة طلب التوريد المباشر (RequestFinancialSummaryCard)
/// ============================================================================
/// يوضح لنقطة البيع ملخص الكميات، الأسعار، الخصومات المكتسبة، والصافي المطلوب سداده
/// مع التجاوب التام ومنع التجاوز على أي قياس شاشة.
class RequestFinancialSummaryCard extends StatelessWidget {
  final int voucherCount;
  final double grossAmount;
  final double discountAmount;
  final double netAmount;
  final String saleType;

  const RequestFinancialSummaryCard({
    super.key,
    required this.voucherCount,
    required this.grossAmount,
    required this.discountAmount,
    required this.netAmount,
    required this.saleType,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCash = saleType == 'CASH';

    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.4),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_outlined,
                size: 16.r,
                color: colors.primary,
              ),
              AppSpacing.hXs,
              Expanded(
                child: Text(
                  'تقدير تكلفة التوريد',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppSpacing.hXs,
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: (isCash ? colors.primary : colors.tertiary)
                      .withValues(alpha: 0.12),
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Text(
                  isCash ? 'سداد نقدي' : 'قيد على المحفظة',
                  style: AppTypography.labelSmall.copyWith(
                    color: isCash ? colors.primary : colors.tertiary,
                    fontWeight: FontWeight.w800,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),

          AppSpacing.vSm,
          Divider(
            color: colors.outlineVariant.withValues(alpha: 0.3),
            height: 1.h,
          ),
          AppSpacing.vSm,

          _SummaryLine(
            label: 'إجمالي عدد الكروت المطلوبة:',
            value: '$voucherCount كرت',
          ),
          AppSpacing.vXxs,
          _SummaryLine(
            label: 'القيمة الإجمالية قبل الخصم:',
            value: '${AmountFormatter.formatValue(grossAmount)} ر.ي',
          ),
          if (discountAmount > 0) ...[
            AppSpacing.vXxs,
            _SummaryLine(
              label: 'مجموع الخصم المكتسب:',
              value: '- ${AmountFormatter.formatValue(discountAmount)} ر.ي',
              isHighlight: true,
            ),
          ],
          AppSpacing.vXxs,
          _SummaryLine(
            label: 'الصافي التقديري للطلب:',
            value: '${AmountFormatter.formatValue(netAmount)} ر.ي',
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;
  final bool isBold;

  const _SummaryLine({
    required this.label,
    required this.value,
    this.isHighlight = false,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppSpacing.hXs,
        Text(
          value,
          style: (isBold ? AppTypography.titleSmall : AppTypography.bodyMedium)
              .copyWith(
            color: isHighlight ? colors.primary : colors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
