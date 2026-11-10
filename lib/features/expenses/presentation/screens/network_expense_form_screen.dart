import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/expenses/presentation/controllers/network_operating_expenses_controller.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_form_items_section.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/pickers/custom_date_picker_field.dart';
import 'package:netsales/widgets/pickers/custom_file_picker.dart';

class NetworkExpenseFormScreen
    extends GetView<NetworkOperatingExpensesController> {
  const NetworkExpenseFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final isEditing = controller.isEditingForm;
      final isSaving = controller.isSaving.value;
      final currentDate = controller.formDate.value;

      return CustomAppScaffold(
        showBackButton: true,
        appBarTitle: isEditing ? 'تعديل المصروف' : 'تسجيل مصروف جديد',
        appBarSubtitle: 'أدخل بنود الصرف والمستندات المؤيدة',
        body: Form(
          key: controller.formKey,
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            children: [
              // 1. تنبيه سلطة الخادم
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: .7),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: colors.onPrimaryContainer,
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: Text(
                        'سيتم احتساب الإجمالي وخصم أو تسوية المحفظة من الخادم بعد اعتماد الطلب.',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.vLg,

              // 2. حقل تاريخ المصروف
              CustomDatePickerField.single(
                label: 'تاريخ المصروف',
                hint: 'حدد تاريخ المصروف',
                value: currentDate,
                onChanged: (picked) {
                  if (picked != null) {
                    controller.setFormDate(picked);
                  }
                },
              ),

              AppSpacing.vLg,

              // 3. قسم بنود المصروف التفاعلي
              ExpenseFormItemsSection(controller: controller),

              AppSpacing.vLg,

              // 4. منتقي الملفات والمرفقات
              CustomFilePicker(
                label: 'المرفقات والفواتير',
                hint: 'PDF أو صور أو مستندات داعمة — حتى 5 ملفات',
                maxFiles: 5,
                maxFileSizeBytes: 10 * 1024 * 1024,
                allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
                initialFiles: controller.formAttachments.toList(),
                onFilesChanged: controller.setFormAttachments,
              ),

              AppSpacing.vXl,

              // 5. زر الحفظ
              CustomButton.primary(
                text: isEditing ? 'حفظ التعديلات' : 'حفظ المصروف',
                width: double.infinity,
                size: AppButtonSize.large,
                loading: isSaving,
                onPressed: isSaving
                    ? null
                    : () async {
                        if (!controller.formKey.currentState!.validate()) {
                          return;
                        }
                        final success = await controller.submitExpenseForm();
                        if (success && context.mounted) {
                          Get.back<void>();
                        }
                      },
              ),

              AppSpacing.vMd,
            ],
          ),
        ),
      );
    });
  }
}
