import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/features/invoices/presentation/controllers/network_direct_invoice_controller.dart';
import 'package:netsales/features/invoices/presentation/widgets/direct_invoice_package_option_card.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/indicators/custom_results_counter_bar.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// كتالوج باقات الفاتورة المباشرة: استعراض وتكوين السلة مباشرة مع بحث وترقيم خادمي
/// مطابق بنسبة 100% لبنية وتجربة [ProcurementPackageSelectionSection] في وحدة الطلبات
class DirectInvoicePackageSelectionSection
    extends GetView<NetworkDirectInvoiceController> {
  const DirectInvoicePackageSelectionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: controller.packageSearchController,
                label: 'البحث في الباقات',
                hint: 'اكتب اسم الباقة للبحث...',
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
                  child: CustomErrorState(
                    title: 'تعذر تحميل باقات الشبكة',
                    subtitle: controller.packageErrorMessage.value!,
                    onRetry: controller.loadPackages,
                  ),
                )
              else if (controller.availablePackages.isEmpty &&
                  controller.packageSearchQuery.value.isNotEmpty)
                CustomEmptyState.search(
                  query: controller.packageSearchQuery.value,
                  onClearSearch: controller.clearPackageSearch,
                )
              else if (controller.availablePackages.isEmpty)
                const SizedBox(
                  width: double.infinity,
                  child: CustomEmptyState.compact(
                    title: 'لا توجد باقات نشطة',
                    subtitle: 'لا تتوفر باقات نشطة لدى الشبكة المحددة حالياً.',
                    icon: Icons.inventory_2_outlined,
                  ),
                )
              else ...[
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
                                  'invoice-package-${package.packageId}',
                                ),
                                width: cardWidth,
                                child: Obx(() {
                                  final quantity = controller
                                      .cartQuantityForPackage(
                                        package.packageId,
                                      );
                                  final isCashSale =
                                      controller.selectedSaleType.value ==
                                      SaleType.cash;

                                  return DirectInvoicePackageOptionCard(
                                    package: package,
                                    quantity: quantity,
                                    quantityController: controller
                                        .quantityControllerForPackage(
                                          package.packageId,
                                        ),
                                    isCashSale: isCashSale,
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
