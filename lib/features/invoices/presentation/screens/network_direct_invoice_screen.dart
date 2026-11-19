import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/invoices/presentation/controllers/network_direct_invoice_controller.dart';
import 'package:netsales/features/invoices/presentation/widgets/direct_invoice/direct_invoice_cart_section.dart';
import 'package:netsales/features/invoices/presentation/widgets/direct_invoice/direct_invoice_checkout_bar.dart';
import 'package:netsales/features/invoices/presentation/widgets/direct_invoice/direct_invoice_financial_authority_notice.dart';
import 'package:netsales/features/invoices/presentation/widgets/direct_invoice/direct_invoice_section_heading.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// شاشة إنشاء فاتورة مبيعات مباشرة لمشغل الشبكة (Network Direct Invoice Screen)
class NetworkDirectInvoiceScreen
    extends GetView<NetworkDirectInvoiceController> {
  const NetworkDirectInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      if (controller.isLoadingNetworks.value &&
          controller.authorizedNetworks.isEmpty) {
        return CustomAppScaffold(
          appBarTitle: 'إنشاء فاتورة مبيعات مباشرة',
          body: Padding(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            child: const CustomStateView.loading(
              presentation: CustomStatePresentation.skeletonOnly,
              skeleton: CustomStateSkeleton(
                layout: CustomStateSkeletonLayout.list,
                itemCount: 3,
                cardHeight: 90,
              ),
            ),
          ),
        );
      }

      if (controller.authorizedNetworks.isEmpty) {
        return CustomAppScaffold(
          appBarTitle: 'إنشاء فاتورة مبيعات مباشرة',
          body: Center(
            child: CustomEmptyState(
              icon: Icons.domain_disabled_outlined,
              title: 'لا توجد شبكات متاحة',
              subtitle: controller.errorMessage.value ??
                  'لا توجد شبكات مرخصة تابعة لحسابك لإصدار الفواتير.',
              actionLabel: 'العودة',
              onAction: () => Get.back<void>(),
            ),
          ),
        );
      }

      return CustomAppScaffold(
        appBarTitle: 'إنشاء فاتورة مبيعات مباشرة',
        bottomNavigationBar: const DirectInvoiceCheckoutBar(),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppBreakpoints.maxFormWidth,
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.cardPadding,
                AppSpacing.md,
                AppSpacing.cardPadding,
                AppSpacing.xl,
              ),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. الترويسة القيادية
                    const CustomPageHeroCard(
                      title: 'فاتورة مبيعات مباشرة',
                      subtitle:
                          'حدد الشبكة ونقطة البيع، اختر الباقات والكميات، وأصدر الفاتورة المعتمدة سيادياً.',
                      icon: Icons.post_add_rounded,
                    ),
                    AppSpacing.vLg,

                    // 2. اختيار الشبكة ونقطة البيع
                    const DirectInvoiceSectionHeading(
                      title: 'الجهة المستفيدة',
                      description: 'حدد الشبكة الموردة ونقطة البيع المستفيدة من الفاتورة.',
                    ),
                    AppSpacing.vSm,

                    // منتقي الشبكة
                    CustomDropdown<int>(
                      label: 'الشبكة الموردة',
                      hint: 'اختر الشبكة',
                      rxValue: controller.selectedNetworkId,
                      enabled: controller.canChangeTarget,
                      searchEnabled: controller.authorizedNetworks.length > 5,
                      items: controller.authorizedNetworks
                          .map((network) {
                            return DropdownItem<int>(
                              value: network.networkId,
                              child: Text(network.networkName),
                            );
                          })
                          .toList(growable: false),
                      onChanged: (networkId) {
                        if (networkId != null) {
                          controller.onNetworkSelected(networkId);
                        }
                      },
                    ),
                    AppSpacing.vSm,

                    // منتقي نقطة البيع
                    Obx(() {
                      if (controller.isLoadingPos.value) {
                        return const CustomStateView.loading(
                          presentation: CustomStatePresentation.skeletonOnly,
                          skeleton: CustomStateSkeleton(
                            layout: CustomStateSkeletonLayout.text,
                            lineCount: 2,
                            showCardSurface: false,
                          ),
                        );
                      }

                      if (controller.linkedPos.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: colors.outlineVariant.withValues(alpha: .35),
                            ),
                          ),
                          child: Text(
                            'لا توجد نقاط بيع مرتبطة بهذه الشبكة حالياً.',
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        );
                      }

                      return CustomDropdown<int>(
                        label: 'نقطة البيع المستفيدة',
                        hint: 'اختر نقطة البيع',
                        rxValue: controller.selectedPosId,
                        enabled: controller.canChangeTarget,
                        searchEnabled: controller.linkedPos.length > 5,
                        items: controller.linkedPos
                            .map((pos) {
                              return DropdownItem<int>(
                                value: pos.posId,
                                child: Text(pos.posName),
                              );
                            })
                            .toList(growable: false),
                        onChanged: (posId) {
                          if (posId != null) {
                            controller.onPosSelected(posId);
                          }
                        },
                      );
                    }),
                    AppSpacing.vLg,

                    // 3. طريقة البيع (كاش / آجل)
                    const DirectInvoiceSectionHeading(
                      title: 'طريقة المعاملة',
                      description: 'حدد نوع البيع (نقدي أو آجل).',
                    ),
                    AppSpacing.vSm,
                    Obx(
                      () => CustomSegmentedBar(
                        selectedIndex:
                            controller.selectedSaleType.value == SaleType.cash
                                ? 0
                                : 1,
                        onSegmentChanged: (idx) => controller.setSaleType(
                          idx == 0 ? SaleType.cash : SaleType.credit,
                        ),
                        items: const [
                          CustomSegmentItem(
                            label: 'نقدي (كاش)',
                            icon: Icons.payments_outlined,
                          ),
                          CustomSegmentItem(
                            label: 'آجل (ائتمان)',
                            icon: Icons.credit_card_outlined,
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.vLg,

                    // 4. الباقات المتاحة للإضافة
                    const DirectInvoiceSectionHeading(
                      title: 'باقات الكروت المتاحة',
                      description: 'حدد كمية الكروت المطلوبة لكل باقة.',
                    ),
                    AppSpacing.vSm,
                    Obx(() {
                      if (controller.isLoadingPackages.value) {
                        return const CustomStateView.loading(
                          presentation: CustomStatePresentation.skeletonOnly,
                          skeleton: CustomStateSkeleton(
                            layout: CustomStateSkeletonLayout.list,
                            itemCount: 2,
                            cardHeight: 80,
                          ),
                        );
                      }

                      if (controller.availablePackages.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: colors.outlineVariant.withValues(alpha: .35),
                            ),
                          ),
                          child: Text(
                            'لا توجد باقات كروت نشطة لهذه الشبكة.',
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: controller.availablePackages.map((package) {
                          final packageColor = CustomColorPicker.parseHex(
                            package.packageColor,
                            fallback: colors.primary,
                          );

                          final existingLine = controller.cart.firstWhereOrNull(
                            (line) => line.package.packageId == package.packageId,
                          );
                          final currentCount = existingLine?.voucherCount ?? 0;

                          return Container(
                            margin: EdgeInsets.only(bottom: AppSpacing.sm),
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: currentCount > 0
                                    ? packageColor.withValues(alpha: .5)
                                    : colors.outlineVariant.withValues(alpha: .3),
                                width: currentCount > 0 ? 1.2 : 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 10.r,
                                  height: 38.h,
                                  decoration: BoxDecoration(
                                    color: packageColor,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                ),
                                AppSpacing.hSm,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        package.packageName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: colors.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'سعر الكرت: ${AmountFormatter.format(package.packageVoucherPrice.toString())}',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      iconSize: 22.r,
                                      color: currentCount > 0
                                          ? colors.primary
                                          : colors.outlineVariant,
                                      onPressed: currentCount > 0
                                          ? () => controller
                                              .addOrUpdatePackageInCart(
                                                  package, currentCount - 1)
                                          : null,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                                      child: Text(
                                        '$currentCount',
                                        style: AppTypography.titleSmall.copyWith(
                                          color: colors.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      iconSize: 22.r,
                                      color: colors.primary,
                                      onPressed: () => controller
                                          .addOrUpdatePackageInCart(
                                              package, currentCount + 1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    }),
                    AppSpacing.vLg,

                    // 5. سلة البنود المختارة
                    const DirectInvoiceCartSection(),
                    AppSpacing.vLg,

                    // 6. إشعار الحوكمة المالية السيادية
                    const DirectInvoiceFinancialAuthorityNotice(),
                    AppSpacing.vXl,
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
