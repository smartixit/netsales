import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';

/// شريط أزرار الإجراءات السريعة لبطاقة المصروف التشغيلي
class ExpenseCardActions extends StatelessWidget {
  const ExpenseCardActions({
    super.key,
    required this.expense,
    required this.onTapDetails,
    this.onDelete,
    this.canDelete = false,
  });

  final ExpenseEntity expense;
  final VoidCallback onTapDetails;
  final VoidCallback? onDelete;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // زر الحذف (إذا كان مصرحاً للمستخدم)
          if (canDelete && onDelete != null) ...[
            CustomButton.outline(
              text: 'حذف واسترجاع',
              size: AppButtonSize.small,
              icon: Icons.delete_outline_rounded,
              onPressed: () {
                CustomDialog.showDanger(
                  title: 'حذف المصروف التشغيلي',
                  message:
                      'هل أنت متأكد من حذف هذا المصروف؟ سيتم استرجاع كامل المبلغ (${expense.formattedTotalAmount} ر.ي) تلقائياً لمحفظة الشبكة.',
                  confirmLabel: 'نعم، حذف واسترجاع',
                  cancelLabel: 'إلغاء',
                  onConfirm: onDelete,
                );
              },
            ),
            AppSpacing.hSm,
          ],

          // زر عرض التفاصيل
          CustomButton.outline(
            text: 'عرض التفاصيل والسند',
            size: AppButtonSize.small,
            icon: Icons.visibility_outlined,
            onPressed: onTapDetails,
          ),
        ],
      ),
    );
  }
}
