import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expense_form_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// سطر إدخال بند المصروف الفردي داخل النموذج
class ExpenseFormItemRow extends StatelessWidget {
  const ExpenseFormItemRow({
    super.key,
    required this.item,
    required this.index,
    required this.onRemove,
    this.canRemove = true,
  });

  final ExpenseFormLineItem item;
  final int index;
  final VoidCallback onRemove;
  final bool canRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              AppSpacing.hSm,
              Text(
                'البند رقم ${index + 1}',
                style: AppTypography.labelMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (canRemove)
                CustomButton.icon(
                  icon: Icons.delete_outline_rounded,
                  tooltip: 'حذف البند',
                  iconSize: 16.r,
                  dimension: 30.r,
                  foregroundColor: colors.error,
                  backgroundColor: colors.error.withValues(alpha: 0.08),
                  onPressed: onRemove,
                ),
            ],
          ),
          AppSpacing.vSm,

          // بيان البند
          CustomTextField(
            controller: item.statementController,
            label: 'بيان المصروف',
            hint: 'مثال: صيانة مولد، شراء أدوات، وقود...',
            isRequired: true,
          ),
          AppSpacing.vSm,

          // مبلغ البند
          CustomTextField(
            controller: item.amountController,
            label: 'المبلغ (ر.ي)',
            hint: '0.00',
            isRequired: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: const [
              AmountTextInputFormatter(decimalPlaces: 2),
            ],
          ),
        ],
      ),
    );
  }
}
