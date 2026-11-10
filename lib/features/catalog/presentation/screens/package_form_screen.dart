import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_form_identity_section.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_form_pricing_section.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_form_specs_section.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_form_status_section.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة إنشاء وتعديل باقة كروت الإنترنت — تركيبة تصريحية بالكامل (Declarative Composition)
class PackageFormScreen extends GetView<PackageCatalogController> {
  const PackageFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final isEditing = controller.isEditing.value;
      final isSaving = controller.isSaving.value;

      return CustomAppScaffold(
        appBar: AppBar(
          title: Text(
            isEditing ? 'تعديل باقة الكروت' : 'إنشاء باقة كروت جديدة',
            style: AppTypography.titleMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.cardPadding),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. البيانات التعريفية وهوية الباقة وشبكة التبعية
                const PackageFormIdentitySection(),

                AppSpacing.vLg,

                // 2. المواصفات الفنية للكرت
                const PackageFormSpecsSection(),

                AppSpacing.vLg,

                // 3. التعرفة المالية والخصومات الافتراضية مع إشعار سلطة الخادم
                const PackageFormPricingSection(),

                AppSpacing.vLg,

                // 4. حالة تفعيل الباقة
                const PackageFormStatusSection(),

                AppSpacing.vXl,

                // 5. زر الحفظ الرئيسي
                CustomButton(
                  text: isEditing ? 'حفظ التعديلات' : 'إنشاء الباقة الآن',
                  icon: isEditing ? Icons.save_rounded : Icons.add_rounded,
                  loading: isSaving,
                  onPressed: isSaving ? null : controller.savePackage,
                ),

                AppSpacing.vMd,
              ],
            ),
          ),
        ),
      );
    });
  }
}
