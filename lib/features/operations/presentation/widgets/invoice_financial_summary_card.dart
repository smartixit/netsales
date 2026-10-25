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
/// بطاقة الملخص المالي ومطابقة الحساب (InvoiceFinancialSummaryCard)
/// ============================================================================
/// تعرض تفاصيل الحساب المالي للفاتورة: الإجمالي، المدفوع، والمتبقي بدقة متناهية.
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

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: AppElevation.level1(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: colors.primary,
                size: 18.r,
              ),
              AppSpacing.hXs,
              Text(
                'الملخص المالي ومطابقة الحساب',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          AppSpacing.vMd,

          // 1. الإجمالي المطلوب
          _SummaryRow(
            label: 'إجمالي قيمة الفاتورة',
            value: AmountFormatter.formatValue(invoice.invoiceTotalAmount),
            currency: 'ر.ي',
            isBold: true,
          ),

          AppSpacing.vSm,

          // 2. المبلغ المدفوع
          _SummaryRow(
            label: 'المبلغ المدفوع (المسدد)',
            value: AmountFormatter.formatValue(invoice.paidAmount),
            currency: 'ر.ي',
            valueColor: colors.success,
          ),

          AppSpacing.vSm,
          Divider(
            thickness: 0.8,
            color: colors.outlineVariant.withValues(alpha: 0.3),
          ),
          AppSpacing.vSm,

          // 3. المتبقي بذمة العميل مع بطاقة الحالة
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: hasRemaining
                  ? colors.warning.withValues(alpha: 0.08)
                  : colors.success.withValues(alpha: 0.08),
              borderRadius: AppRadius.mdRadius,
              border: Border.all(
                color: hasRemaining
                    ? colors.warning.withValues(alpha: 0.3)
                    : colors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      hasRemaining
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_rounded,
                      color: hasRemaining ? colors.warning : colors.success,
                      size: 20.r,
                    ),
                    AppSpacing.hSm,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasRemaining ? 'المتبقي بذمة الوكيل' : 'حالة الحساب',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          hasRemaining
                              ? 'مستحق السداد آجل'
                              : 'الفاتورة مسددة بالكامل',
                          style: AppTypography.bodySmall.copyWith(
                            color: hasRemaining ? colors.warning : colors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      AmountFormatter.formatValue(invoice.remainingAmount),
                      style: AppTypography.titleMedium.copyWith(
                        color: hasRemaining ? colors.warning : colors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.hXxs,
                    Text(
                      'ر.ي',
                      style: AppTypography.labelSmall.copyWith(
                        color: hasRemaining ? colors.warning : colors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final String currency;
  final Color? valueColor;
  final bool isBold;

  const _SummaryRow({
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
          style: AppTypography.bodySmall.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: valueColor ?? colors.onSurface,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            AppSpacing.hXxs,
            Text(
              currency,
              style: AppTypography.labelSmall.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
