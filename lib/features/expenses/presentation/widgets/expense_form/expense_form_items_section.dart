import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expense_form_controller.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_form/expense_form_item_row.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// قسم إدارة بنود المصروف داخل النموذج
class ExpenseFormItemsSection extends StatelessWidget {
  const ExpenseFormItemsSection({super.key, required this.controller});

  final NetworkExpenseFormController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ترويسة القسم مع زر إضافة بند
        Row(
          children: [
            Icon(
              Icons.format_list_numbered_rounded,
              size: 18.r,
              color: colors.primary,
            ),
            AppSpacing.hXs,
            Obx(
              () => Text(
                'بنود المصروف (${controller.lineItems.length})',
                style: AppTypography.titleMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            CustomButton.outline(
              text: 'إضافة بند +',
              icon: Icons.add_rounded,
              size: AppButtonSize.small,
              onPressed: controller.addItem,
            ),
          ],
        ),
        AppSpacing.vSm,

        // قائمة البنود التفاعلية
        Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              controller.lineItems.length,
              (index) => ExpenseFormItemRow(
                key: ValueKey(controller.lineItems[index].id),
                item: controller.lineItems[index],
                index: index,
                canRemove: controller.lineItems.length > 1,
                onRemove: () => controller.removeItem(index),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
