import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/debts/domain/entities/debt_summary_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

class PosDebtCard extends StatelessWidget {
  final PosDebtBreakdownEntity pos;
  final VoidCallback onCollectPayment;
  final VoidCallback onManageCreditLimit;
  final VoidCallback onViewInvoices;

  const PosDebtCard({
    super.key,
    required this.pos,
    required this.onCollectPayment,
    required this.onManageCreditLimit,
    required this.onViewInvoices,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasDebt = pos.outstandingDebt > 0;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: hasDebt
              ? colors.error.withValues(alpha: 0.3)
              : colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(Icons.storefront_rounded, color: colors.primary, size: 20.r),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pos.posName,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      Text(
                        'فواتير آجلة غير مسددة: ${pos.unpaidInvoicesCount}',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${AmountFormatter.formatValue(pos.outstandingDebt, decimalPlaces: 0)} ر.ي',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: hasDebt ? colors.error : colors.onSurface,
                    ),
                  ),
                  Text(
                    hasDebt ? 'مديونية مستحقة' : 'لا توجد ديون',
                    style: AppTypography.labelSmall.copyWith(
                      color: hasDebt ? colors.error : colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.vSm,
          const Divider(height: 1),
          AppSpacing.vSm,
          // سقف الائتمان والهامش المتاح
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السقف الائتماني: ${pos.creditLimit != null ? "${AmountFormatter.formatValue(pos.creditLimit!, decimalPlaces: 0)} ر.ي" : "غير ممنوح (NULL)"}',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (pos.creditLimit != null)
                Text(
                  'المتاح: ${AmountFormatter.formatValue(pos.availableLimit, decimalPlaces: 0)} ر.ي',
                  style: AppTypography.labelSmall.copyWith(
                    color: pos.availableLimit < 0 ? colors.error : colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          AppSpacing.vSm,
          // أزرار العمليات
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'تحصيل سداد',
                  icon: Icons.payments_rounded,
                  height: 36.h,
                  onPressed: hasDebt ? onCollectPayment : null,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomButton.outline(
                  text: 'الفواتير الآجلة',
                  icon: Icons.receipt_long_rounded,
                  height: 36.h,
                  onPressed: onViewInvoices,
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'تعديل السقف الائتماني',
                onPressed: onManageCreditLimit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
