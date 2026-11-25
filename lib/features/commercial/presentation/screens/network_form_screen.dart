import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/auth/domain/entities/directorate_entity.dart';
import 'package:netsales/features/auth/domain/entities/governorate_entity.dart';
import 'package:netsales/features/commercial/presentation/controllers/network_form_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/pickers/custom_image_picker.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

class NetworkFormScreen extends GetView<NetworkFormController> {
  const NetworkFormScreen({super.key});

  @override
  Widget build(BuildContext context) => CustomAppScaffold(
    appBarTitle: controller.isEditing ? 'تعديل بيانات الشبكة' : 'إنشاء شبكة',
    body: Obx(() {
      if (controller.errorMessage.value != null && !controller.isLoading.value) {
        return CustomStateView.error(
          title: 'تعذر فتح نموذج الشبكة',
          subtitle: controller.errorMessage.value,
          actionLabel: 'إعادة المحاولة',
          onAction: controller.retryInitialize,
        );
      }
      if (controller.isLoading.value) {
        return const CustomStateView.loading();
      }
      return Form(
        key: controller.formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            CustomPageHeroCard(
              title: controller.isEditing ? 'تعديل الشبكة' : 'إنشاء شبكة جديدة',
              subtitle: 'بيانات الكيان الأساسية فقط؛ لا تتغير العلاقات أو العضويات أو الالتزامات المالية هنا.',
              icon: Icons.hub_rounded,
            ),
            AppSpacing.vMd,
            CustomSurfaceCard(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomImagePicker.logo(
                    label: 'شعار الشبكة',
                    hint: 'صورة اختيارية حتى 2MB',
                    valueListenable: controller.logo,
                  ),
                  AppSpacing.vMd,
                  CustomTextField(
                    controller: controller.nameController,
                    label: 'اسم الشبكة',
                    validator: FormValidators.required(fieldName: 'اسم الشبكة'),
                  ),
                  AppSpacing.vMd,
                  Obx(() => CustomDropdown<GovernorateEntity>(
                    label: 'المحافظة',
                    hint: controller.isLoadingGovernorates.value ? 'جارٍ تحميل المحافظات...' : 'اختر المحافظة',
                    prefixIcon: Icons.map_outlined,
                    items: controller.governorates.map((item) => DropdownItem<GovernorateEntity>(
                      value: item,
                      child: Text(item.governorateName),
                    )).toList(),
                    rxValue: controller.selectedGovernorate,
                    itemSearchText: (item) => item.governorateName,
                    onChanged: controller.onGovernorateChanged,
                    validator: (value) => value == null ? 'اختر المحافظة.' : null,
                  )),
                  AppSpacing.vMd,
                  Obx(() => CustomDropdown<DirectorateEntity>(
                    label: 'المديرية',
                    hint: controller.isLoadingDirectorates.value ? 'جارٍ تحميل المديريات...' : 'اختر المديرية',
                    prefixIcon: Icons.location_city_outlined,
                    enabled: controller.selectedGovernorate.value != null && !controller.isLoadingDirectorates.value,
                    items: controller.directorates.map((item) => DropdownItem<DirectorateEntity>(
                      value: item,
                      child: Text(item.directorateName),
                    )).toList(),
                    rxValue: controller.selectedDirectorate,
                    itemSearchText: (item) => item.directorateName,
                    onChanged: (value) => controller.selectedDirectorate.value = value,
                    validator: (value) => value == null ? 'اختر المديرية.' : null,
                  )),
                  AppSpacing.vMd,
                  CustomTextField(
                    controller: controller.addressController,
                    label: 'العنوان التفصيلي',
                    isRequired: false,
                    validator: FormValidators.addressValidator(fieldName: 'العنوان', isRequired: false),
                  ),
                ],
              ),
            ),
            AppSpacing.vLg,
            CustomButton.primary(
              text: controller.isEditing ? 'حفظ التعديلات' : 'إنشاء الشبكة',
              loading: controller.isSaving.value,
              onPressed: controller.isSaving.value ? null : controller.save,
            ),
          ],
        ),
      );
    }),
  );
}
