import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expense_form_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// شريط تأكيد وحفظ سند الصرف الثابت أسفل شاشة النموذج
class ExpenseFormCheckoutBar extends StatelessWidget {
  const ExpenseFormCheckoutBar({super.key, required this.controller});

  final NetworkExpenseFormController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
        child: Obx(() {
          final total = controller.estimatedTotal.value;
          final itemsCount = controller.lineItems.length;
          final isSubmitting = controller.isSubmitting.value;
          final isEdit = controller.isEditMode.value;

          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$itemsCount ${itemsCount == 1 ? 'بند مصروف' : 'بنود مصروفات'}',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.vXxs,
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AmountFormatter.format(total.toString()),
                            style: AppTypography.titleMedium.copyWith(
                              color: colors.error,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          AppSpacing.hXxs,
                          Text(
                            'ر.ي',
                            style: AppTypography.caption.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.hSm,
              CustomButton.primary(
                text: isEdit ? 'تحديث المصروف' : 'تسجيل وخصم',
                icon: isEdit ? Icons.save_rounded : Icons.check_circle_rounded,
                loading: isSubmitting,
                onPressed: isSubmitting ? null : controller.submit,
              ),
            ],
          );
        }),
      ),
    );
  }
}
