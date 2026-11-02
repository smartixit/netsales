import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/debts/domain/entities/outstanding_invoice_entity.dart';

class OutstandingInvoiceTile extends StatelessWidget {
  final PosOutstandingInvoiceEntity invoice;

  const OutstandingInvoiceTile({super.key, required this.invoice});

  Color _getBadgeColor(String bucket) {
    switch (bucket) {
      case '0-30':
        return const Color(0xFF10B981);
      case '31-60':
        return const Color(0xFFF59E0B);
      case '61-90':
        return const Color(0xFFF97316);
      case '>90':
      default:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final badgeColor = _getBadgeColor(invoice.agingBucket);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
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
              Row(
                children: [
                  Icon(Icons.description_rounded, size: 20.r, color: colors.primary),
                  SizedBox(width: 6.w),
                  Text(
                    invoice.invoiceUuid,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
              // شارة عمر الدين (Aging Badge)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${invoice.daysOutstanding} يوم (${invoice.agingBucket})',
                      style: AppTypography.labelSmall.copyWith(
                        color: badgeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تاريخ الفاتورة: ${DateFormatter.date(invoice.invoiceDate)}',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              Text(
                invoice.paymentStatusLabel,
                style: AppTypography.labelSmall.copyWith(
                  color: invoice.isPartiallyPaid ? colors.warning : colors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          const Divider(height: 1),
          AppSpacing.vSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الإجمالي',
                    style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant),
                  ),
                  Text(
                    '${AmountFormatter.formatValue(invoice.invoiceTotalAmount, decimalPlaces: 0)} ر.ي',
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المدفوع',
                    style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant),
                  ),
                  Text(
                    '${AmountFormatter.formatValue(invoice.paidAmount, decimalPlaces: 0)} ر.ي',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'المتبقي ذمة مستحقة',
                    style: AppTypography.labelSmall.copyWith(color: colors.error),
                  ),
                  Text(
                    '${AmountFormatter.formatValue(invoice.remainingAmount, decimalPlaces: 0)} ر.ي',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
