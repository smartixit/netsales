import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/debts/domain/entities/repayment_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';

class RepaymentReceiptDialog extends StatelessWidget {
  final PosRepaymentEntity repayment;

  const RepaymentReceiptDialog({super.key, required this.repayment});

  static Future<void> show(BuildContext context, PosRepaymentEntity repayment) {
    return CustomDialog.show(
      type: DialogType.info,
      title: 'سند سداد مديونية ومحضر التوزيع',
      message: 'بيان الفواتير المسددة والتوزيع الحتمي للأموال',
      content: RepaymentReceiptDialog(repayment: repayment),
      canPop: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('رقم السند', style: AppTypography.labelSmall),
                    Text(repayment.repaymentUuid, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                AppSpacing.vXs,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('المبلغ الإجمالي', style: AppTypography.labelSmall),
                    Text(
                      '${AmountFormatter.formatValue(repayment.amount, decimalPlaces: 0)} ر.ي',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: repayment.isReversed ? colors.error : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                AppSpacing.vXs,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('طريقة الدفع', style: AppTypography.labelSmall),
                    Text(repayment.paymentMethod, style: AppTypography.bodySmall),
                  ],
                ),
                AppSpacing.vXs,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('التاريخ', style: AppTypography.labelSmall),
                    Text(DateFormatter.format(repayment.repaymentDate, 'yyyy/MM/dd HH:mm'), style: AppTypography.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.vMd,
          Text(
            'الفواتير المسددة بموجب هذا السند (FIFO Allocations):',
            style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.vSm,
          if (repayment.allocations.isEmpty)
            Text('لا توجد توزيعات مسجلة', style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant))
          else
            ...repayment.allocations.map((alloc) {
              return Container(
                margin: EdgeInsets.only(bottom: 6.h),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alloc.invoiceUuid ?? 'فاتورة #${alloc.invoiceId}',
                          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          alloc.isReversed ? 'معكوس' : 'سداد ناجح',
                          style: AppTypography.labelSmall.copyWith(
                            color: alloc.isReversed ? colors.error : const Color(0xFF10B981),
                            fontSize: 9.sp,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${AmountFormatter.formatValue(alloc.allocatedAmount, decimalPlaces: 0)} ر.ي',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              );
            }),
          AppSpacing.vLg,
          CustomButton(
            text: 'إغلاق',
            height: 40.h,
            onPressed: () => Get.back<void>(),
          ),
        ],
      ),
    );
  }
}
