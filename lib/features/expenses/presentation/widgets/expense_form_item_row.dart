import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// بطاقة سطر إدخال بند المصروف الفردي (ExpenseFormItemRow)
///
/// مكون عرض بحت خالٍ تماماً من أي متغيرات أو حسابات منطقية داخلية:
/// يتلقى وحدات التحكم النصية [statementController] و [amountController] ورقم السطر [index]،
/// ويفوض إمكانية الإزالة كلياً عبر توفير [onRemove] أو كونه null.
class ExpenseFormItemRow extends StatelessWidget {
  const ExpenseFormItemRow({
    super.key,
    required this.statementController,
    required this.amountController,
    required this.index,
    this.onRemove,
  });

  final TextEditingController statementController;
  final TextEditingController amountController;
  final int index;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'البند #${index + 1}',
                style: AppTypography.labelLarge.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onRemove != null)
                CustomButton.icon(
                  icon: Icons.delete_outline_rounded,
                  size: AppButtonSize.small,
                  shape: AppButtonShape.circle,
                  backgroundColor: colors.error.withValues(alpha: 0.08),
                  foregroundColor: colors.error,
                  tooltip: 'إزالة هذا البند',
                  onPressed: onRemove,
                ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          CustomTextField(
            controller: statementController,
            label: 'بيان البند',
            hint: 'مثال: إيجار المقر، صيانة الكوابل، تسديد فاتورة كهرباء...',
            prefixIcon: Icon(
              Icons.edit_note_rounded,
              color: colors.onSurfaceVariant,
              size: 20.w,
            ),
            isRequired: true,
          ),
          SizedBox(height: AppSpacing.sm),
          CustomTextField(
            controller: amountController,
            label: 'مبلغ البند (ر.ي)',
            hint: '0.00',
            prefixIcon: Icon(
              Icons.payments_outlined,
              color: colors.onSurfaceVariant,
              size: 20.w,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            isRequired: true,
          ),
        ],
      ),
    );
  }
}
