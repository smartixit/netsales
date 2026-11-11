import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/invoices/presentation/controllers/network_direct_invoice_controller.dart';
import 'package:netsales/features/invoices/presentation/widgets/direct_invoice_cart_section.dart';
import 'package:netsales/features/invoices/presentation/widgets/direct_invoice_section_widgets.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/voucher_quantity_stepper.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// Network-side standalone invoice creation. Laravel remains the sole
/// authority for package pricing, discounts, invoice totals and settlement.
class NetworkDirectInvoiceScreen
    extends GetView<NetworkDirectInvoiceController> {
  const NetworkDirectInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      appBar: AppBar(
        title: Text(
          'إنشاء فاتورة مبيعات مباشرة',
          style: AppTypography.titleMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoadingNetworks.value &&
            controller.authorizedNetworks.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            child: const CustomSkeletonFeed(itemCount: 3, cardHeight: 90),
          );
        }

        if (controller.authorizedNetworks.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.domain_disabled_outlined,
                    color: colors.onSurfaceVariant,
                    size: 42,
                  ),
                  AppSpacing.vMd,
                  Text(
                    controller.errorMessage.value ??
                        'لا توجد شبكات متاحة لإصدار الفواتير.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.vLg,
                  CustomButton.outline(
                    text: 'العودة إلى الفواتير',
                    onPressed: Get.back<void>,
                  ),
                ],
              ),
            ),
          );
        }

        return Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DirectInvoiceSectionHeading(
                  title: 'الجهة المستفيدة',
                  description: 'حدد الشبكة ونقطة البيع المرتبطة بها.',
                ),
                AppSpacing.vSm,
                CustomDropdown<int>(
                  label: 'الشبكة الموردة',
                  hint: 'اختر الشبكة',
                  rxValue: controller.selectedNetworkId,
                  enabled:
                      controller.canChangeTarget &&
                      !controller.isLoadingNetworks.value,
                  searchEnabled: controller.authorizedNetworks.length > 5,
                  items: controller.authorizedNetworks
                      .map((network) {
                        return DropdownItem<int>(
                          value: network.networkId,
                          child: Text(network.networkName),
                        );
                      })
                      .toList(growable: false),
                  itemSearchText: (networkId) =>
                      controller.authorizedNetworks
                          .firstWhereOrNull(
                            (network) => network.networkId == networkId,
                          )
                          ?.networkName ??
                      networkId.toString(),
                  onChanged: (networkId) {
                    if (networkId != null) {
                      controller.onNetworkSelected(networkId);
                    }
                  },
                ),
                AppSpacing.vMd,
                Obx(() {
                  if (controller.isLoadingPos.value) {
                    return const LinearProgressIndicator();
                  }
                  if (controller.linkedPos.isEmpty) {
                    return DirectInvoiceInlineNotice(
                      message: controller.selectedNetworkId.value == null
                          ? 'اختر الشبكة أولاً لعرض نقاط البيع المرتبطة بها.'
                          : 'لا توجد نقاط بيع نشطة مرتبطة بهذه الشبكة.',
                      icon: Icons.store_mall_directory_outlined,
                    );
                  }
                  return CustomDropdown<int>(
                    label: 'نقطة البيع المستفيدة',
                    hint: 'اختر نقطة البيع',
                    rxValue: controller.selectedPosId,
                    enabled: controller.canChangeTarget,
                    searchEnabled: controller.linkedPos.length > 5,
                    items: controller.linkedPos
                        .map((link) {
                          return DropdownItem<int>(
                            value: link.posId,
                            child: Text(
                              link.pos?.posName ?? 'نقطة بيع #${link.posId}',
                            ),
                          );
                        })
                        .toList(growable: false),
                    itemSearchText: (posId) =>
                        controller.linkedPos
                            .firstWhereOrNull((link) => link.posId == posId)
                            ?.pos
                            ?.posName ??
                        posId.toString(),
                    onChanged: (posId) {
                      if (posId != null) controller.onPosSelected(posId);
                    },
                  );
                }),
                if (!controller.canChangeTarget) ...[
                  AppSpacing.vXs,
                  Text(
                    'أفرغ بنود الفاتورة أولاً لتغيير الشبكة أو نقطة البيع.',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.warning,
                    ),
                  ),
                ],
                AppSpacing.vLg,
                const DirectInvoiceSectionHeading(
                  title: 'باقات الكروت والكميات',
                  description:
                      'أدخل عدد الكروت المطلوب لكل باقة، ثم أضفها إلى الفاتورة.',
                ),
                AppSpacing.vSm,
                Obx(() {
                  if (controller.isLoadingPackages.value) {
                    return const LinearProgressIndicator();
                  }
                  if (controller.availablePackages.isEmpty) {
                    return DirectInvoiceInlineNotice(
                      message: controller.selectedNetworkId.value == null
                          ? 'اختر الشبكة أولاً لعرض باقاتها.'
                          : 'لا توجد باقات نشطة متاحة لهذه الشبكة.',
                      icon: Icons.inventory_2_outlined,
                    );
                  }
                  return CustomDropdown<int>(
                    label: 'الباقة',
                    hint: 'اختر باقة الكروت',
                    rxValue: controller.selectedPackageId,
                    enabled: controller.hasSelectedNetwork,
                    searchEnabled: controller.availablePackages.length > 5,
                    items: controller.availablePackages
                        .map((package) {
                          final pkgColor = CustomColorPicker.parseHex(package.packageColor);
                          return DropdownItem<int>(
                            value: package.packageId,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: pkgColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                AppSpacing.hSm,
                                Expanded(child: Text(package.packageName)),
                              ],
                            ),
                          );
                        })
                        .toList(growable: false),
                    itemSearchText: (packageId) =>
                        controller.availablePackages
                            .firstWhereOrNull(
                              (package) => package.packageId == packageId,
                            )
                            ?.packageName ??
                        packageId.toString(),
                    onChanged: (packageId) {
                      if (packageId != null) {
                        controller.onPackageSelected(packageId);
                      }
                    },
                  );
                }),
                AppSpacing.vMd,
                Obx(() {
                  final package = controller.selectedPackage;
                  final sheetSize = package?.packageVoucherCount ?? 0;
                  final currentCount = controller.currentVoucherCount;

                  return VoucherQuantityStepper(
                    controller: controller.quantityController,
                    sheetSize: sheetSize,
                    currentCount: currentCount,
                    label: 'عدد الكروت',
                    showPresets: sheetSize > 0,
                    showSummaryCard: sheetSize > 0,
                    showClearAction: true,
                    validator: controller.validateVoucherCount,
                    onCountChanged: controller.setVoucherCount,
                  );
                }),
                AppSpacing.vSm,
                Obx(
                  () => CustomButton.secondary(
                    text: controller.isSelectedPackageInCart
                        ? 'تحديث كمية الباقة في الفاتورة'
                        : 'إضافة الباقة إلى الفاتورة',
                    icon: controller.isSelectedPackageInCart
                        ? Icons.edit_rounded
                        : Icons.add_shopping_cart_rounded,
                    width: double.infinity,
                    enabled:
                        controller.selectedPackage != null &&
                        controller.hasSelectedPos,
                    onPressed: controller.addOrUpdateCartLine,
                  ),
                ),
                AppSpacing.vLg,
                const DirectInvoiceCartSection(),
                AppSpacing.vLg,
                const DirectInvoiceSectionHeading(
                  title: 'طريقة البيع',
                  description:
                      'اختر نوع الفاتورة؛ يتم التحقق من الرصيد والسقف الائتماني لدى الخادم.',
                ),
                AppSpacing.vSm,
                Obx(
                  () => CustomSegmentedBar(
                    selectedIndex:
                        controller.selectedSaleType.value == SaleType.cash
                        ? 0
                        : 1,
                    onSegmentChanged: (index) {
                      controller.setSaleType(
                        index == 0 ? SaleType.cash : SaleType.credit,
                      );
                    },
                    items: const [
                      CustomSegmentItem(
                        label: 'نقدي',
                        icon: Icons.payments_outlined,
                      ),
                      CustomSegmentItem(
                        label: 'آجل',
                        icon: Icons.credit_card_outlined,
                      ),
                    ],
                  ),
                ),
                AppSpacing.vMd,
                const DirectInvoiceFinancialAuthorityNotice(),
                AppSpacing.vLg,
                Obx(
                  () => CustomButton.primary(
                    text: 'إنشاء فاتورة المبيعات',
                    icon: Icons.receipt_long_rounded,
                    width: double.infinity,
                    loading: controller.isSubmitting.value,
                    enabled:
                        !controller.isSubmitting.value &&
                        controller.hasSelectedPos &&
                        controller.cart.isNotEmpty,
                    onPressed: controller.submitAndNavigate,
                  ),
                ),
                AppSpacing.vLg,
              ],
            ),
          ),
        );
      }),
    );
  }
}

