import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_form_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/forms/package_form_preview_hero.dart';
import 'package:netsales/features/catalog/presentation/widgets/forms/package_general_info_section.dart';
import 'package:netsales/features/catalog/presentation/widgets/forms/package_pricing_form_section.dart';
import 'package:netsales/features/catalog/presentation/widgets/forms/package_specs_form_section.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/document_details/custom_document_action_bar.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// مساحة عمل إنشاء وتعديل الباقة.
/// تحافظ على تسلسل الإدخال، وتعرض المعاينة نفسها على الشاشات الواسعة
/// وتضعها داخل مساحة قابلة للطي على الهاتف لتبقى الحقول هي الأولوية.
class PackageFormScreen extends GetView<PackageFormController> {
  const PackageFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEditing = controller.isEditing.value;
      final isSaving = controller.isSaving.value;

      return CustomAppScaffold(
        appBarTitle: isEditing ? 'تعديل باقة الكروت' : 'إنشاء باقة كروت',
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWideLayout = constraints.maxWidth >= 920;
            final content = Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _PackageFormIntroduction(isEditing: isEditing),
                  // SizedBox(height: AppSpacing.lg),
                  if (!isWideLayout) ...[
                    const _CompactPreviewDisclosure(),
                    SizedBox(height: AppSpacing.lg),
                  ],
                  const PackageGeneralInfoSection(),
                  SizedBox(height: AppSpacing.xl),
                  const PackageSpecsFormSection(),
                  SizedBox(height: AppSpacing.xl),
                  const PackagePricingFormSection(),
                  SizedBox(height: AppSpacing.xl),
                ],
              ),
            );

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsetsDirectional.fromSTEB(
                AppSpacing.cardPadding,
                AppSpacing.appBarHeight + AppSpacing.md,
                AppSpacing.cardPadding,
                AppSpacing.xl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWideLayout ? 1440 : 760,
                  ),
                  child: isWideLayout
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 6, child: content),
                            SizedBox(width: AppSpacing.xl),
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: EdgeInsets.only(top: AppSpacing.xl),
                                child: const PackageFormPreviewHero(),
                              ),
                            ),
                          ],
                        )
                      : content,
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: CustomDocumentActionBar(
          child: Align(
            alignment: Alignment.center,
            heightFactor: 1,
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
                      text: isEditing ? 'حفظ التعديلات' : 'إنشاء الباقة',
                      icon: isEditing ? Icons.check_rounded : Icons.add_rounded,
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

class _CompactPreviewDisclosure extends StatelessWidget {
  const _CompactPreviewDisclosure();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .6)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          childrenPadding: EdgeInsetsDirectional.fromSTEB(
            AppSpacing.sm,
            0,
            AppSpacing.sm,
            AppSpacing.md,
          ),
          leading: Icon(Icons.visibility_outlined, color: colors.primary),
          title: Text(
            'معاينة شكل الباقة',
            style: AppTypography.titleSmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            'افتح المعاينة عند الحاجة دون مقاطعة إدخال البيانات',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          children: const [PackageFormPreviewHero()],
        ),
      ),
    );
  }
}
