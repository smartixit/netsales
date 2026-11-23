import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_form_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/forms/package_general_info_section.dart';
import 'package:netsales/features/catalog/presentation/widgets/forms/package_pricing_form_section.dart';
import 'package:netsales/features/catalog/presentation/widgets/forms/package_specs_form_section.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/document_details/custom_document_action_bar.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة إنشاء وتعديل باقة كروت الإنترنت (PackageFormScreen)
///
/// تجسد المعمارية المؤسسية النظيفة:
/// - شاشة تركيبية بحتة خالية تماماً من منطق الأعمال وحسابات الـ Map.
/// - تفويض كامل لحقول الإدخال إلى ودجات الأقسام المنفصلة في `widgets/forms/`.
/// - شريط أزرار ثابت للحفظ والإلغاء.
class PackageFormScreen extends GetView<PackageFormController> {
  const PackageFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEditing = controller.isEditing.value;
      final isSaving = controller.isSaving.value;

      return CustomAppScaffold(
        appBarTitle: isEditing ? 'تعديل باقة الكروت' : 'إنشاء باقة كروت جديدة',
        body: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.cardPadding),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PackageGeneralInfoSection(),
                AppSpacing.vLg,
                PackageSpecsFormSection(),
                AppSpacing.vLg,
                PackagePricingFormSection(),
                AppSpacing.vXl,
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomDocumentActionBar(
          child: Align(
            alignment: Alignment.center,
            heightFactor: 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton.outline(
                      text: 'إلغاء وتراجع',
                      icon: Icons.close_rounded,
                      shape: AppButtonShape.rounded,
                      size: AppButtonSize.medium,
                      onPressed: () => Get.back<void>(),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: CustomButton.primary(
                      text: isEditing ? 'حفظ التعديلات' : 'إنشاء وتثبيت الباقة',
                      icon: isEditing
                          ? Icons.check_rounded
                          : Icons.add_task_rounded,
                      shape: AppButtonShape.rounded,
                      size: AppButtonSize.medium,
                      loading: isSaving,
                      onPressed: controller.submitForm,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
