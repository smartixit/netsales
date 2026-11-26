import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_expense_form_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// ورقة إضافة وتعديل بند المصروف السفلية (ExpenseItemBottomSheet)
///
/// واجهة [StatelessWidget] نقية بالكامل بدون أي حالة محلية أو منطق أعمال:
/// - تفتح عبر [CustomBottomSheet.show].
/// - تستمد الحقول والتحقق والحفظ من [NetworkExpenseFormController].
class ExpenseItemBottomSheet extends GetView<NetworkExpenseFormController> {
  const ExpenseItemBottomSheet({super.key});

  static Future<void> show(
    BuildContext context, {
    required NetworkExpenseFormController controller,
    int? editIndex,
  }) {
    if (editIndex != null) {
      controller.prepareEditItemSheet(editIndex);
    } else {
      controller.prepareAddItemSheet();
    }

    return CustomBottomSheet.show<void>(
      title: editIndex != null ? 'تعديل بند المصروف' : 'إضافة بند مصروف جديد',
      child: const ExpenseItemBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEditing = controller.isEditingSheetItem;

    return Form(
      key: controller.sheetFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: controller.sheetStatementController,
            label: 'بيان البند',
            hint: 'مثال: إيجار المقر، صيانة الكوابل، فاتورة كهرباء...',
            prefixIcon: Icon(
              Icons.edit_note_rounded,
              color: colors.onSurfaceVariant,
              size: 20.w,
            ),
            maxLines: 2,
            minLines: 1,
            autofocus: true,
            isRequired: true,
            validator: FormValidators.required(fieldName: 'بيان البند'),
          ),
          AppSpacing.vMd,
          CustomTextField(
            controller: controller.sheetAmountController,
            label: 'مبلغ البند (ر.ي)',
            hint: '0.00',
            prefixIcon: Icon(
              Icons.payments_outlined,
              color: colors.onSurfaceVariant,
              size: 20.w,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            isRequired: true,
            validator: FormValidators.amountValidator(
              fieldName: 'مبلغ البند',
              minValue: 0.01,
            ),
          ),
          AppSpacing.vLg,
          Row(
            children: [
              Expanded(
                child: CustomButton.outline(
                  text: 'إلغاء',
                  icon: Icons.close_rounded,
                  shape: AppButtonShape.rounded,
                  size: AppButtonSize.medium,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                flex: 2,
                child: CustomButton.primary(
                  text: isEditing ? 'حفظ التعديلات' : 'إضافة البند',
                  icon: isEditing ? Icons.check_rounded : Icons.add_rounded,
                  shape: AppButtonShape.rounded,
                  size: AppButtonSize.medium,
                  onPressed: () {
                    if (controller.saveSheetItem()) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
        ],
      ),
    );
  }
}
