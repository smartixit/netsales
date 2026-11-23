import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_form_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/forms/package_form_preview_hero.dart';
import 'package:netsales/features/catalog/presentation/widgets/forms/package_general_info_section.dart';
import 'package:netsales/features/catalog/presentation/widgets/forms/package_pricing_form_section.dart';
import 'package:netsales/features/catalog/presentation/widgets/forms/package_specs_form_section.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/document_details/custom_document_action_bar.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة إنشاء وتعديل باقة كروت الإنترنت (PackageFormScreen)
///
/// تجسد استوديو تصميم ومحاكاة كروت الإنترنت التفاعلي (Interactive Voucher Studio):
/// - هيرو تفاعلي حي يعكس كرت الشحن الرقمي ثلاثي الأبعاد [PackageFormPreviewHero].
/// - تفويض كامل لحقول الإدخال إلى ودجات الأقسام المنفصلة في `widgets/forms/`.
/// - شريط أزرار ثابت للحفظ والإلغاء مع تغذية لمسية.
class PackageFormScreen extends GetView<PackageFormController> {
  const PackageFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEditing = controller.isEditing.value;
      final isSaving = controller.isSaving.value;

      return CustomAppScaffold(
        appBarTitle: isEditing
            ? 'تعديل باقة الكروت'
            : 'استوديو إنشاء باقة كروت',
        body: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.cardPadding),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. هيرو المعاينة الحية الفورية للكرت الرقمي
                const PackageFormPreviewHero(),
                AppSpacing.vLg,

                // 2. كبسولة الهوية البصرية واسم الباقة
                const PackageGeneralInfoSection(),
                AppSpacing.vLg,

                // 3. كبسولة المواصفات الفنية وحجم الحزمة
                const PackageSpecsFormSection(),
                AppSpacing.vLg,

                // 4. كبسولة التسعير ورادار الأرباح وهوامش الجملة
                const PackagePricingFormSection(),
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
              constraints: BoxConstraints(maxWidth: 760.w),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton.outline(
                      text: 'إلغاء',
                      icon: Icons.close_rounded,
                      shape: AppButtonShape.rounded,
                      size: AppButtonSize.medium,
                      onPressed: () => Get.back<void>(),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: CustomButton.primary(
                      text: isEditing ? 'حفظ التعديلات' : 'تثبيت الباقة',
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
