import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';

/// ============================================================================
/// بطاقة الملخص المالي ومطابقة الحساب السيادية (InvoiceFinancialSummaryCard)
/// ============================================================================
/// تعرض تفاصيل الحساب المالي للفاتورة بدقة محاسبية متناهية:
/// الإجمالي، المسدد، والمتبقي مع إشعار المطابقة والتسوية المعتمد.
class InvoiceFinancialSummaryCard extends StatelessWidget {
  final SaleInvoiceEntity invoice;

  const InvoiceFinancialSummaryCard({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasRemaining = invoice.hasRemaining;
    final isCash = invoice.isCash;
    final themeColor = isCash ? colors.primary : colors.warning;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.28),
          width: 1.w,
        ),
        boxShadow: AppElevation.level1(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26.r,
                height: 26.r,
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: themeColor,
                  size: 15.r,
                ),
              ),
              AppSpacing.hXs,
              Text(
                'الملخص المالي ومطابقة الحساب',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5.sp,
                ),
              ),
            ],
          ),

          AppSpacing.vMd,

          // 1. الإجمالي المطلوب
          _SummaryLedgerRow(
            label: 'إجمالي قيمة الفاتورة المعتمدة',
            value: AmountFormatter.formatValue(invoice.invoiceTotalAmount),
            currency: 'ر.ي',
            isBold: true,
          ),

          AppSpacing.vSm,

          // 2. المبلغ المدفوع
          _SummaryLedgerRow(
            label: 'المبلغ المسدد (المدفوع)',
            value: AmountFormatter.formatValue(invoice.paidAmount),
            currency: 'ر.ي',
            valueColor: colors.primary,
          ),

          AppSpacing.vSm,
          Divider(
            thickness: 0.6.h,
            color: colors.outlineVariant.withValues(alpha: 0.25),
          ),
          AppSpacing.vSm,

          // 3. المتبقي بذمة العميل
          _SummaryLedgerRow(
            label: 'المتبقي بذمة نقطة البيع',
            value: AmountFormatter.formatValue(invoice.remainingAmount),
            currency: 'ر.ي',
            valueColor: hasRemaining ? colors.warning : colors.onSurfaceVariant,
            isBold: hasRemaining,
          ),

          AppSpacing.vMd,

          // 4. بطاقة حالة التسوية السيادية
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
            decoration: BoxDecoration(
              color: (hasRemaining ? colors.warning : colors.primary)
                  .withValues(alpha: 0.08),
              borderRadius: AppRadius.mdRadius,
              border: Border.all(
                color: (hasRemaining ? colors.warning : colors.primary)
                    .withValues(alpha: 0.25),
                width: 0.8.w,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasRemaining
                      ? Icons.warning_amber_rounded
                      : Icons.verified_rounded,
                  size: 18.r,
                  color: hasRemaining ? colors.warning : colors.primary,
                ),
                AppSpacing.hSm,
                Expanded(
                  child: Text(
                    hasRemaining
                        ? 'يتبقى مبلغ ${AmountFormatter.formatValue(invoice.remainingAmount)} ر.ي مقيد كدين آجل في ذمة نقطة البيع'
                        : 'تم سداد ومطابقة كامل قيمة الفاتورة بنجاح ودون أي ذمم معلقة',
                    style: AppTypography.labelSmall.copyWith(
                      color: hasRemaining ? colors.warning : colors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.sp,
                    ),
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

class _SummaryLedgerRow extends StatelessWidget {
  final String label;
  final String value;
  final String currency;
  final Color? valueColor;
  final bool isBold;

  const _SummaryLedgerRow({
    required this.label,
    required this.value,
    required this.currency,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: colors.onSurfaceVariant.withValues(alpha: 0.8),
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            fontSize: 11.sp,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: (isBold ? AppTypography.titleSmall : AppTypography.bodySmall)
                  .copyWith(
                color: valueColor ?? colors.onSurface,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
                fontSize: isBold ? 14.sp : 12.sp,
              ),
            ),
            AppSpacing.hXxs,
            Text(
              currency,
              style: AppTypography.labelSmall.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
