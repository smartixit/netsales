import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';

/// ============================================================================
/// سند التسوية المالية اللحظي الموحد (InvoiceFinancialSummaryCard)
/// ============================================================================
/// يمثل كشف حساب فوري يوضح إجمالي المبالغ، الخصم، الصافي، المدفوع، والذمة المتبقية
/// مع التجاوب التام ومنع أي تجاوز أفقي على كافة الشاشات.
class InvoiceFinancialSummaryCard extends StatelessWidget {
  final int voucherCount;
  final double grossAmount;
  final double discountAmount;
  final double netAmount;
  final double paidAmount;
  final double remainingDebt;
  final String saleType;

  const InvoiceFinancialSummaryCard({
    super.key,
    required this.voucherCount,
    required this.grossAmount,
    required this.discountAmount,
    required this.netAmount,
    required this.paidAmount,
    required this.remainingDebt,
    required this.saleType,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isFullyPaid = remainingDebt <= 0.001;

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
          // ترويسة السند وحالة التسوية
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 16.r,
                color: colors.primary,
              ),
              AppSpacing.hXs,
              Expanded(
                child: Text(
                  'سند التسوية المالية المباشر',
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
                  color: isFullyPaid
                      ? colors.primary.withValues(alpha: 0.12)
                      : colors.error.withValues(alpha: 0.12),
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Text(
                  isFullyPaid ? 'مسددة بالكامل' : 'تسوية ذمة آجلة',
                  style: AppTypography.labelSmall.copyWith(
                    color: isFullyPaid ? colors.primary : colors.error,
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

          // سطور التفاصيل المالية المتجاوبة
          _FinancialRow(
            label: 'إجمالي عدد الكروت الموردة:',
            value: '$voucherCount كرت',
          ),
          AppSpacing.vXxs,
          _FinancialRow(
            label: 'المبلغ الإجمالي المرجعي:',
            value: '${AmountFormatter.formatValue(grossAmount)} ر.ي',
          ),
          if (discountAmount > 0) ...[
            AppSpacing.vXxs,
            _FinancialRow(
              label: 'الخصم الممنوح للوكيل:',
              value: '- ${AmountFormatter.formatValue(discountAmount)} ر.ي',
              isHighlight: true,
            ),
          ],
          AppSpacing.vXxs,
          _FinancialRow(
            label: 'الصافي المطلوب للتسوية:',
            value: '${AmountFormatter.formatValue(netAmount)} ر.ي',
            isBold: true,
          ),
          if (saleType == 'CREDIT') ...[
            AppSpacing.vXxs,
            _FinancialRow(
              label: 'المسدد نقداً فورياً:',
              value: '${AmountFormatter.formatValue(paidAmount)} ر.ي',
            ),
            if (remainingDebt > 0.001) ...[
              AppSpacing.vXxs,
              _FinancialRow(
                label: 'متبقي دين آجل على المحفظة:',
                value: '${AmountFormatter.formatValue(remainingDebt)} ر.ي',
                isDebt: true,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _FinancialRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;
  final bool isDebt;
  final bool isBold;

  const _FinancialRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
    this.isDebt = false,
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
              color: isDebt ? colors.error : colors.onSurfaceVariant,
              fontWeight: (isDebt || isBold) ? FontWeight.w700 : FontWeight.w500,
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
            color: isDebt
                ? colors.error
                : (isHighlight ? colors.primary : colors.onSurface),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
