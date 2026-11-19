import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_card/invoice_card_metric_column.dart';

/// سكة القياسات المالية والتشغيلية الموحدة لبطاقة الفاتورة
class InvoiceCardMetricsBar extends StatelessWidget {
  const InvoiceCardMetricsBar({super.key, required this.invoice});

  final InvoiceEntity invoice;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final paidPct = invoice.paidPercentage;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: .30),
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // 1. عدد الباقات
              Expanded(
                flex: 2,
                child: InvoiceCardMetricColumn(
                  label: 'الباقات',
                  value: invoice.packagesCount.toString(),
                  unit: 'باقة',
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              ),

              Container(
                width: 1,
                height: 26.h,
                color: colors.outlineVariant.withValues(alpha: .35),
              ),

              // 2. إجمالي الكروت
              Expanded(
                flex: 3,
                child: InvoiceCardMetricColumn(
                  label: 'الكمية الإجمالية',
                  value: invoice.totalVouchersCount.toString(),
                  unit: 'كرت',
                ),
              ),

              Container(
                width: 1,
                height: 26.h,
                color: colors.outlineVariant.withValues(alpha: .35),
              ),

              // 3. إجمالي الفاتورة
              Expanded(
                flex: 4,
                child: InvoiceCardMetricColumn(
                  label: 'إجمالي الفاتورة',
                  value: invoice.formattedTotalAmount,
                  accentColor: colors.primary,
                  crossAxisAlignment: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
          AppSpacing.vSm,

          // شريط نسبة السداد التفاعلي
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: paidPct,
                    minHeight: 4.5.h,
                    backgroundColor: colors.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      invoice.isPaid
                          ? colors.success
                          : (invoice.isPartiallyPaid
                              ? colors.warning
                              : colors.error),
                    ),
                  ),
                ),
              ),
              AppSpacing.hSm,
              Text(
                invoice.isPaid
                    ? 'مسددة'
                    : (invoice.remainingAmount > 0
                        ? 'متبقي: ${invoice.formattedRemainingAmount}'
                        : '${(paidPct * 100).toInt()}%'),
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: invoice.isPaid
                      ? colors.success
                      : (invoice.remainingAmount > 0
                          ? colors.error
                          : colors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
