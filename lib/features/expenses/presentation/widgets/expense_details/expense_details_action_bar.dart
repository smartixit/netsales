import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expense_details_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';

/// شريط الإجراءات والعمليات المستندية الثابت أسفل شاشة تفاصيل المصروف التشغيلي
class ExpenseDetailsActionBar extends StatelessWidget {
  const ExpenseDetailsActionBar({super.key, required this.controller});

  final NetworkExpenseDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final exp = controller.expense.value;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant.withValues(alpha: .35),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // زر التصدير كـ PDF الرئيسي
            Expanded(
              child: CustomButton.primary(
                text: 'تصدير سند PDF',
                icon: Icons.picture_as_pdf_outlined,
                onPressed: controller.exportPdf,
              ),
            ),
            AppSpacing.hSm,

            // زر الطباعة
            CustomButton.outline(
              text: 'طباعة',
              icon: Icons.print_outlined,
              onPressed: controller.printPdf,
            ),
            AppSpacing.hSm,

            // زر المشاركة
            CustomButton.outline(
              text: 'مشاركة',
              icon: Icons.share_outlined,
              onPressed: controller.sharePdf,
            ),

            // زر الحذف والاسترجاع إذا مصرحاً له
            if (controller.canDeleteExpense && exp != null) ...[
              AppSpacing.hSm,
              CustomButton.outline(
                text: 'حذف',
                icon: Icons.delete_outline_rounded,
                onPressed: () {
                  CustomDialog.showDanger(
                    title: 'حذف المصروف التشغيلي',
                    message:
                        'هل أنت متأكد من حذف هذا المصروف؟ سيتم استرجاع كامل المبلغ (${exp.formattedTotalAmount} ر.ي) تلقائياً لمحفظة الشبكة.',
                    confirmLabel: 'نعم، حذف واسترجاع',
                    cancelLabel: 'إلغاء',
                    onConfirm: controller.deleteExpense,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
