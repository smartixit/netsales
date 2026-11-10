import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/auth/domain/entities/directorate_entity.dart';
import 'package:netsales/features/auth/domain/entities/governorate_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/presentation/controllers/commercial_directory_controller.dart';
import 'package:netsales/features/finance/presentation/widgets/manual_wallet_transaction_sheet.dart';
import 'package:netsales/features/finance/presentation/widgets/update_pos_credit_limit_sheet.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';
import 'package:netsales/widgets/toasts/custom_toast.dart';

/// نافذة استعراض وتحديث بيانات نقطة البيع
class PosDetailsBottomSheet {
  PosDetailsBottomSheet._();

  static Future<void> show({required PosEntity pos, bool canEdit = false}) {
    final formKey = GlobalKey<FormState>();
    final controller = Get.find<CommercialDirectoryController>();

    final nameController = TextEditingController(text: pos.posName);
    final phoneController = TextEditingController(text: pos.posPhoneNumber);
    final addressController = TextEditingController(text: pos.posAddress ?? '');
    final govDisplayController = TextEditingController(
      text: pos.governorateName ?? 'غير محددة',
    );
    final dirDisplayController = TextEditingController(
      text: pos.directorateName ?? 'غير محددة',
    );

    final isEditing = false.obs;
    final selectedGovernorate = Rxn<GovernorateEntity>();
    final selectedDirectorate = Rxn<DirectorateEntity>();
    final directorates = <DirectorateEntity>[].obs;
    final isLoadingDirectorates = false.obs;

    // تهيئة البيانات الجغرافية
    void initGeography() {
      controller.loadGovernorates().then((_) async {
        if (pos.governorateId != null) {
          final foundGov = controller.governorates.firstWhereOrNull(
            (g) => g.governorateId == pos.governorateId,
          );
          if (foundGov != null) {
            selectedGovernorate.value = foundGov;
            govDisplayController.text = foundGov.governorateName;
            isLoadingDirectorates.value = true;
            final dirs = await controller.loadDirectorates(foundGov.governorateId);
            directorates.assignAll(dirs);
            isLoadingDirectorates.value = false;

            if (pos.directorateId != null) {
              final foundDir = dirs.firstWhereOrNull(
                (d) => d.directorateId == pos.directorateId,
              );
              if (foundDir != null) {
                selectedDirectorate.value = foundDir;
                dirDisplayController.text = foundDir.directorateName;
              }
            }
          }
        }
      });
    }

    initGeography();

    return CustomBottomSheet.show<void>(
      title: 'بيانات نقطة البيع',
      subtitle: 'المعلومات التجارية والتشغيلية لنقطة البيع',
      leadingIcon: Icons.storefront_rounded,
      scrollable: true,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSpacing.vMd,

            // شارة الحالة ورقم نقطة البيع
            Builder(
              builder: (context) {
                final colors = context.colors;

                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.storefront_rounded,
                            size: 20.r,
                            color: colors.primary,
                          ),
                          AppSpacing.hSm,
                          Text(
                            'معرف نقطة البيع #${pos.posUuid}',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      CustomStatusBadge.fromPresentation(
                        EnumPresentationRegistry.resolvePosStatus(
                          pos.typedStatus,
                          serverLabel: pos.statusLabel,
                        ),
                        showDot: true,
                        isCompact: true,
                      ),
                    ],
                  ),
                );
              },
            ),

            AppSpacing.vSm,

            // المعرف الفريد UUID
            Builder(
              builder: (context) {
                final colors = context.colors;
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fingerprint_rounded,
                        size: 20.r,
                        color: colors.primary,
                      ),
                      AppSpacing.hSm,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المعرف الفريد (UUID)',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              pos.posUuid,
                              style: AppTypography.bodySmall.copyWith(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CustomButton.icon(
                        icon: Icons.copy_rounded,
                        iconSize: 18.r,
                        dimension: 32.r,
                        tooltip: 'نسخ المعرف',
                        onPressed: () async {
                          await UrlLauncherService.copyToClipboard(pos.posUuid);
                          CustomToast.show(
                            message: 'تم نسخ معرف نقطة البيع',
                            icon: Icons.copy_rounded,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            AppSpacing.vMd,

            // حقل الاسم التجاري
            Obx(
              () => CustomTextField(
                controller: nameController,
                label: 'اسم نقطة البيع',
                hint: 'أدخل الاسم التجاري لنقطة البيع',
                prefixIcon: const Icon(Icons.store_rounded),
                readOnly: !isEditing.value,
                isRequired: isEditing.value,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'اسم نقطة البيع مطلوب';
                  }
                  return null;
                },
              ),
            ),

            AppSpacing.vSm,

            // حقل رقم الهاتف
            Obx(
              () => CustomTextField(
                controller: phoneController,
                label: 'رقم الهاتف',
                hint: '77xxxxxxx',
                prefixIcon: const Icon(Icons.phone_rounded),
                readOnly: !isEditing.value,
                isRequired: isEditing.value,
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'رقم الهاتف مطلوب';
                  }
                  return null;
                },
              ),
            ),

            AppSpacing.vSm,

            // اختيار المحافظة والمديرية والعنوان التفصيلي
            Obx(() {
              if (!isEditing.value) {
                // وضع العرض: إظهار المحافظة والمديرية كحقول قراءة
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: govDisplayController,
                            label: 'المحافظة',
                            prefixIcon: const Icon(Icons.map_outlined),
                            readOnly: true,
                            isRequired: false,
                          ),
                        ),
                        AppSpacing.hSm,
                        Expanded(
                          child: CustomTextField(
                            controller: dirDisplayController,
                            label: 'المديرية',
                            prefixIcon: const Icon(Icons.location_city_outlined),
                            readOnly: true,
                            isRequired: false,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vSm,
                    CustomTextField(
                      controller: addressController,
                      label: 'العنوان التفصيلي (الشارع / المعلم)',
                      hint: 'الشارع، الحي، المعلم المجاور',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      readOnly: true,
                      isRequired: false,
                    ),
                  ],
                );
              }

              // وضع التعديل: استخدام CustomDropdown للمحافظة والمديرية المتسلسلة
              final govItems = controller.governorates.map((gov) {
                return DropdownItem<GovernorateEntity>(
                  value: gov,
                  child: Text(
                    gov.governorateName,
                    style: AppTypography.bodyMedium,
                  ),
                );
              }).toList();

              final dirItems = directorates.map((dir) {
                return DropdownItem<DirectorateEntity>(
                  value: dir,
                  child: Text(
                    dir.directorateName,
                    style: AppTypography.bodyMedium,
                  ),
                );
              }).toList();

              final hasGov = selectedGovernorate.value != null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomDropdown<GovernorateEntity>(
                    label: 'المحافظة',
                    hint: controller.isLoadingGovernorates.value
                        ? 'جاري جلب المحافظات...'
                        : 'اختر المحافظة',
                    prefixIcon: Icons.map_outlined,
                    items: govItems,
                    rxValue: selectedGovernorate,
                    itemSearchText: (gov) => gov.governorateName,
                    isRequired: true,
                    onChanged: (gov) async {
                      selectedGovernorate.value = gov;
                      govDisplayController.text =
                          gov?.governorateName ?? 'غير محددة';
                      selectedDirectorate.value = null;
                      dirDisplayController.text = 'غير محددة';
                      directorates.clear();
                      if (gov != null) {
                        isLoadingDirectorates.value = true;
                        final dirs = await controller.loadDirectorates(
                          gov.governorateId,
                        );
                        directorates.assignAll(dirs);
                        isLoadingDirectorates.value = false;
                      }
                    },
                    validator: (gov) =>
                        gov == null ? 'يرجى اختيار المحافظة.' : null,
                  ),
                  AppSpacing.vSm,
                  CustomDropdown<DirectorateEntity>(
                    label: 'المديرية',
                    hint: isLoadingDirectorates.value
                        ? 'جاري جلب المديريات...'
                        : (hasGov ? 'اختر المديرية' : 'اختر المحافظة أولاً'),
                    prefixIcon: Icons.location_city_outlined,
                    enabled: hasGov && !isLoadingDirectorates.value,
                    items: dirItems,
                    rxValue: selectedDirectorate,
                    itemSearchText: (dir) => dir.directorateName,
                    isRequired: true,
                    onChanged: (dir) {
                      selectedDirectorate.value = dir;
                      dirDisplayController.text =
                          dir?.directorateName ?? 'غير محددة';
                    },
                    validator: (dir) =>
                        dir == null ? 'يرجى اختيار المديرية.' : null,
                  ),
                  AppSpacing.vSm,
                  CustomTextField(
                    controller: addressController,
                    label: 'العنوان التفصيلي (الشارع / المعلم)',
                    hint: 'الشارع، الحي، المعلم المجاور',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    isRequired: false,
                  ),
                ],
              );
            }),

            AppSpacing.vLg,

            // أزرار العمليات المالية والائتمانية (لمالكي الشبكة المصرح لهم)
            if (PermissionService.to.can(AppPermissions.posWalletsManage) ||
                PermissionService.to.can(AppPermissions.posWalletsEdit)) ...[
              CustomButton.outline(
                text: 'تعديل السقف الائتماني للنقطة',
                icon: Icons.credit_card_rounded,
                onPressed: () {
                  UpdatePosCreditLimitSheet.show(
                    posWalletId: pos.posId,
                    posName: pos.posName,
                  );
                },
              ),
              AppSpacing.vXs,
              CustomButton.outline(
                text: 'إدراج قيد تسوية مالي في محفظة النقطة',
                icon: Icons.account_balance_wallet_outlined,
                onPressed: () {
                  ManualWalletTransactionSheet.show(
                    walletId: pos.posId,
                    accountName: pos.posName,
                    currentBalance: 0.0,
                    isPosWallet: true,
                    onSuccess: () {
                      CustomSnackbar.show(
                        title: 'تم إدراج القيد',
                        message:
                            'تم إدراج القيد المالي في محفظة نقطة البيع بنجاح.',
                        type: SnackType.success,
                      );
                    },
                  );
                },
              ),
              AppSpacing.vMd,
            ],

            // أزرار الحفظ أو التعديل
            if (canEdit)
              Obx(() {
                if (!isEditing.value) {
                  return CustomButton.outline(
                    text: 'تعديل البيانات',
                    icon: Icons.edit_note_rounded,
                    onPressed: () => isEditing.value = true,
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: CustomButton.outline(
                        text: 'إلغاء',
                        onPressed: () {
                          nameController.text = pos.posName;
                          phoneController.text = pos.posPhoneNumber;
                          addressController.text = pos.posAddress ?? '';
                          initGeography();
                          isEditing.value = false;
                        },
                      ),
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: CustomButton.primary(
                        text: 'حفظ التعديلات',
                        icon: Icons.check_rounded,
                        loading: controller.isActionLoading.value,
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final payload = <String, dynamic>{
                            'pos_name': nameController.text.trim(),
                            'pos_phone_number': phoneController.text.trim(),
                            if (selectedGovernorate.value != null)
                              'governorate_id':
                                  selectedGovernorate.value!.governorateId,
                            if (selectedDirectorate.value != null)
                              'directorate_id':
                                  selectedDirectorate.value!.directorateId,
                            if (addressController.text.trim().isNotEmpty)
                              'pos_address': addressController.text.trim(),
                          };

                          final success = await controller.updatePosDetails(
                            pos.posId,
                            payload,
                          );
                          if (success) {
                            Get.back<void>();
                          }
                        },
                      ),
                    ),
                  ],
                );
              }),

            AppSpacing.vSm,
          ],
        ),
      ),
    );
  }
}
