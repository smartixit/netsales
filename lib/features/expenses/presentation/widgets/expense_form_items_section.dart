import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_operating_expenses_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

class ExpenseFormItemsSection extends StatelessWidget {
  const ExpenseFormItemsSection({super.key, required this.controller});

  final NetworkOperatingExpensesController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final items = controller.formItems;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'بنود المصروف',
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CustomButton.outline(
                text: 'إضافة بند',
                icon: Icons.add_rounded,
                onPressed: controller.addFormItem,
              ),
            ],
          ),
          AppSpacing.vSm,
          ...List.generate(items.length, (index) {
            final item = items[index];

            return Container(
              margin: EdgeInsets.only(bottom: AppSpacing.md),
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: .5),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: AppTypography.labelMedium.copyWith(
                            color: colors.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      AppSpacing.hSm,
                      Expanded(
                        child: Text(
                          'البند ${index + 1}',
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      if (items.length > 1)
                        CustomButton.icon(
                          icon: Icons.delete_outline_rounded,
                          foregroundColor: colors.error,
                          tooltip: 'حذف هذا البند',
                          onPressed: () => controller.removeFormItem(index),
                        ),
                    ],
                  ),
                  AppSpacing.vSm,
                  CustomTextField(
                    controller: item.statementController,
                    label: 'وصف المصروف',
                    hint: 'مثال: إيجار مقر الشبكة، صيانة المولد...',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'أدخل وصف البند'
                        : null,
                  ),
                  AppSpacing.vSm,
                  CustomTextField(
                    controller: item.amountController,
                    label: 'المبلغ',
                    hint: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: const [
                      AmountTextInputFormatter(decimalPlaces: 2),
                    ],
                    prefixIcon: const Icon(Icons.payments_outlined),
                    validator: (v) {
                      final cleaned = AmountFormatter.clean(v ?? '');
                      final amount = double.tryParse(cleaned) ?? 0;
                      return amount <= 0 ? 'أدخل مبلغاً أكبر من صفر' : null;
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      );
    });
  }
}
