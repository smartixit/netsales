import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_sheet_quantity_section.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_cart_section.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// شاشة إنشاء وتقديم طلب توريد كروت جديد من نقطة البيع (New Procurement Order Wizard)
class PosNewProcurementOrderScreen extends GetView<PosProcurementController> {
  const PosNewProcurementOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      appBar: AppBar(
        title: Text(
          'طلب توريد كروت جديد',
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
              // 1. اختيار الشبكة الموردة
              Text(
                'الشبكة الموردة',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.vSm,
              Obx(() {
                if (controller.isLoadingNetworks.value) {
                  return const LinearProgressIndicator();
                }

                final networks = controller.linkedNetworks;
                if (networks.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      'لا توجد شبكات موردة نشطة مرتبطة بنقطة البيع حالياً.',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.error,
                      ),
                    ),
                  );
                }

                return CustomDropdown<int>(
                  label: 'اختر الشبكة الموردة',
                  searchEnabled: false,
                  rxValue: controller.selectedNetworkId,
                  items: networks.map((link) {
                    return DropdownItem<int>(
                      value: link.networkId,
                      child: Text(
                        link.network?.networkName ?? 'شبكة #${link.networkId}',
                      ),
                    );
                  }).toList(),
                  onChanged: (id) {
                    if (id != null) controller.onNetworkSelected(id);
                  },
                );
              }),

              AppSpacing.vLg,

              // 2. اختيار باقة الكروت
              Text(
                'باقة الكروت المطلوبة',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.vSm,
              Obx(() {
                if (controller.isLoadingPackages.value) {
                  return const LinearProgressIndicator();
                }

                final packages = controller.availablePackages;
                if (packages.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      'يرجى اختيار شبكة لعرض باقات الكروت المتوفرة لديها.',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return CustomDropdown<int>(
                  label: 'اختر باقة الكروت',
                  searchEnabled: true,
                  rxValue: controller.selectedPackageId,
                  items: packages.map((pkg) {
                    return DropdownItem<int>(
                      value: pkg.packageId,
                      child: Text('${pkg.packageName} (سعر أساسي: ${pkg.packageVoucherPrice})'),
                    );
                  }).toList(),
                  onChanged: (id) {
                    if (id != null) {
                      final found =
                          packages.firstWhereOrNull((p) => p.packageId == id);
                      if (found != null) controller.onPackageSelected(found);
                    }
                  },
                );
              }),

              AppSpacing.vLg,

              // 3. تحديد كمية التوريد بوحدة الأوراق مع معاينة تحويلها إلى كروت
              const ProcurementSheetQuantitySection(),
              AppSpacing.vMd,
              Obx(() {
                return CustomButton.secondary(
                  text: controller.isSelectedPackageInCart
                      ? 'تحديث الباقة في الطلب'
                      : 'إضافة الباقة إلى الطلب',
                  icon: controller.isSelectedPackageInCart
                      ? Icons.edit_rounded
                      : Icons.add_shopping_cart_rounded,
                  onPressed: controller.selectedPackage.value == null
                      ? null
                      : controller.addOrUpdateCartLine,
                );
              }),
              AppSpacing.vLg,
              const ProcurementCartSection(),

              AppSpacing.vLg,

              // 4. نوع وطريقة الدفع (نقدي / آجل)
              Text(
                'طريقة الدفع المقترحة',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.vSm,
              Obx(() {
                final isCash =
                    controller.selectedSaleType.value == SaleType.cash;
                return CustomSegmentedBar(
                  selectedIndex: isCash ? 0 : 1,
                  onSegmentChanged: (idx) {
                    controller.selectedSaleType.value =
                        idx == 0 ? SaleType.cash : SaleType.credit;
                  },
                  items: const [
                    CustomSegmentItem(
                      label: 'دفع نقدي (CASH)',
                      icon: Icons.payments_outlined,
                    ),
                    CustomSegmentItem(
                      label: 'دفع آجل (CREDIT)',
                      icon: Icons.credit_card_outlined,
                    ),
                  ],
                );
              }),

              AppSpacing.vLg,

              // 5. ملاحظات إضافية
              CustomTextField(
                controller: controller.notesController,
                label: 'ملاحظات الطلب (اختياري)',
                hint: 'أضف أي تفاصيل خاصة لمزود الشبكة...',
                maxLines: 2,
                isRequired: false,
              ),

              AppSpacing.vLg,

              // 6. إشعار السلطة المالية للخادم
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: AppSpacing.lg,
                      color: colors.primary,
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: Text(
                        'يتم احتساب الخصومات التعاقدية والتسوية المالية تلقائياً فور اعتماد الطلب من الشبكة.',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.vXl,

              // 7. زر الإرسال
              Obx(() {
                return CustomButton(
                  text: 'تقديم طلب التوريد الآن',
                  icon: Icons.send_rounded,
                  loading: controller.isSubmitting.value,
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () async {
                          final ok = await controller.submitOrder();
                          if (ok) Get.back<void>();
                        },
                );
              }),

              AppSpacing.vMd,
            ],
          ),
        ),
      ),
    );
  }
}

