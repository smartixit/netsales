import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_new_procurement_order_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_catalog_failure_state.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_package_option_card.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/indicators/custom_results_counter_bar.dart';

/// كتالوج الباقات: استعراض وتكوين السلة مباشرة مع بحث وترقيم خادمي.
class ProcurementPackageSelectionSection
    extends GetView<PosNewProcurementOrderController> {
  const ProcurementPackageSelectionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر باقة التوريد',
          style: AppTypography.titleSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.vXxs,
        Text(
          'عدّل كمية كل باقة من بطاقتها مباشرة. يمكنك إضافة أكثر من باقة، وتظهر تعرفة النقدي والآجل مباشرة داخل كل بطاقة.',
          style: AppTypography.bodySmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        AppSpacing.vSm,
        Obx(() {
          if (controller.selectedNetworkId.value == null) {
            return SizedBox(
              width: double.infinity,
              child: const CustomEmptyState.compact(
                title: 'اختر الشبكة الموردة أولاً',
                subtitle: 'سيظهر هنا كتالوج الباقات النشطة التابعة للشبكة.',
                icon: Icons.hub_outlined,
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: controller.packageSearchController,
                label: 'البحث في الباقات',
                hint: 'اكتب اسم الباقة',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: controller.packageSearchQuery.value.isNotEmpty
                    ? CustomButton.icon(
                        icon: Icons.close_rounded,
                        tooltip: 'مسح البحث',
                        dimension: 36,
                        backgroundColor: Colors.transparent,
                        onPressed: controller.clearPackageSearch,
                      )
                    : null,
                isRequired: false,
                onChanged: controller.onPackageSearchChanged,
              ),
              AppSpacing.vXs,
              CustomResultsCounterBar(
                count: controller.availablePackages.length,
                recordLabel: 'باقة محمّلة',
                isFiltered: controller.packageSearchQuery.value.isNotEmpty,
                isLoading: controller.isLoadingPackages.value,
              ),
              AppSpacing.vSm,
              if (controller.isLoadingPackages.value)
                const CustomStateView.loading(
                  presentation: CustomStatePresentation.skeletonOnly,
                  skeleton: CustomStateSkeleton(
                    layout: CustomStateSkeletonLayout.list,
                    itemCount: 3,
                    cardHeight: 170,
                  ),
                )
              else if (controller.packageErrorMessage.value != null &&
                  controller.availablePackages.isEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ProcurementCatalogFailureState(
                    errorMessage: controller.packageErrorMessage.value!,
                    onRetry: controller.selectedNetworkId.value == null
                        ? null
                        : () => controller.loadNetworkPackages(
                            controller.selectedNetworkId.value!,
                          ),
                  ),
                )
              else if (controller.availablePackages.isEmpty &&
                  controller.packageSearchQuery.value.isNotEmpty)
                CustomEmptyState.search(
                  query: controller.packageSearchQuery.value,
                  onClearSearch: controller.clearPackageSearch,
                )
              else if (controller.availablePackages.isEmpty)
                SizedBox(
                  width: double.infinity,
                  child: const CustomEmptyState.compact(
                    title: 'لا توجد باقات نشطة',
                    subtitle: 'لا تتوفر باقات نشطة لدى الشبكة المحددة حالياً.',
                    icon: Icons.inventory_2_outlined,
                  ),
                )
              else ...[
                if (controller.packageDiscountError.value != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: CustomErrorState.compact(
                      title: 'تعذر تحميل الخصم المخصص لنقطة البيع',
                      subtitle: controller.packageDiscountError.value,
                      onRetry: controller.loadEffectivePackageDiscounts,
                    ),
                  ),
                  AppSpacing.vSm,
                ],
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns =
                        constraints.maxWidth >= AppBreakpoints.mobileMax
                        ? 2
                        : 1;
                    final cardWidth = columns == 1
                        ? constraints.maxWidth
                        : (constraints.maxWidth - AppSpacing.md) / 2;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.md,
                          children: [
                            ...controller.availablePackages.map((package) {
                              return SizedBox(
                                key: ValueKey(
                                  'procurement-package-${package.packageId}',
                                ),
                                width: cardWidth,
                                child: Obx(() {
                                  final quantity = controller
                                      .cartQuantityForPackage(
                                        package.packageId,
                                      );
                                  final customDiscount = controller
                                      .discountForPackage(package.packageId);
                                  final isDiscountLoading = controller
                                      .isLoadingPackageDiscounts
                                      .value;
                                  final isCashSale =
                                      controller.selectedSaleType.value ==
                                      SaleType.cash;
                                  final quote = controller.serverQuote.value;
                                  final hasCurrentQuote =
                                      controller.hasCurrentServerQuote;

                                  return ProcurementPackageOptionCard(
                                    package: package,
                                    quantity: quantity,
                                    customDiscount: customDiscount,
                                    quantityController: controller
                                        .quantityControllerForPackage(
                                          package.packageId,
                                        ),
                                    isDiscountLoading: isDiscountLoading,
                                    isCashSale: isCashSale,
                                    quoteLine: hasCurrentQuote
                                        ? quote?.findLine(package.packageId)
                                        : null,
                                    estimatedLineTotalMinor: controller
                                        .estimatedLineTotalMinor(
                                          package,
                                          quantity,
                                        ),
                                    onSetQuantity: (nextQuantity) =>
                                        controller.setPackageVoucherCount(
                                          package,
                                          nextQuantity,
                                        ),
                                  );
                                }),
                              );
                            }),
                            if (controller.isLoadingMorePackages.value)
                              SizedBox(
                                width: cardWidth,
                                child: const CustomStateView.loading(
                                  presentation:
                                      CustomStatePresentation.skeletonOnly,
                                  skeleton: CustomStateSkeleton(
                                    layout: CustomStateSkeletonLayout.cards,
                                    itemCount: 1,
                                    cardHeight: 124,
                                    maxColumns: 1,
                                    minItemWidth: 180,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (controller.packageLoadMoreErrorMessage.value !=
                            null) ...[
                          AppSpacing.vSm,
                          CustomErrorState.compact(
                            title: 'تعذر تحميل بقية الباقات',
                            subtitle:
                                controller.packageLoadMoreErrorMessage.value,
                            onRetry: controller.loadMorePackages,
                          ),
                        ] else if (controller.packageNextCursor.value != null &&
                            !controller.isLoadingMorePackages.value) ...[
                          AppSpacing.vSm,
                          CustomButton.outline(
                            text: 'تحميل المزيد من الباقات',
                            icon: Icons.expand_more_rounded,
                            width: double.infinity,
                            onPressed: controller.loadMorePackages,
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ],
          );
        }),
      ],
    );
  }
}
