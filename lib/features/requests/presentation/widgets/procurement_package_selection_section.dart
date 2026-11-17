
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_package_option_card.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// كتالوج الباقات: استعراض وتكوين السلة مباشرة مع بحث وترقيم خادمي.
class ProcurementPackageSelectionSection
    extends GetView<PosProcurementController> {
  const ProcurementPackageSelectionSection({super.key});

  Widget _buildCatalogFailureState(BuildContext context) {
    final message = controller.packageErrorMessage.value ?? '';
    final normalized = message.toLowerCase();
    final offline = normalized.contains('socket') ||
        normalized.contains('network') ||
        normalized.contains('connection') ||
        normalized.contains('internet') ||
        message.contains('الاتصال') ||
        message.contains('الإنترنت');
    final networkId = controller.selectedNetworkId.value;
    final retry = networkId == null
        ? null
        : () => controller.loadNetworkPackages(networkId);

    if (offline) {
      return CustomStateView.offline(
        title: 'تعذر الاتصال بكتالوج الشبكة',
        subtitle: 'تحقق من اتصال الإنترنت ثم أعد المحاولة لتحميل الباقات.',
        presentation: CustomStatePresentation.compact,
        onAction: retry,
      );
    }

    return CustomStateView.error(
      title: 'تعذر تحميل كتالوج الباقات',
      subtitle: message,
      presentation: CustomStatePresentation.compact,
      onAction: retry,
    );
  }

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
          'عدّل كمية كل باقة من بطاقتها مباشرة. يمكنك إضافة أكثر من باقة، ووتظهر تعرفة النقدي والآجل مباشرة داخل كل بطاقة.',
          style: AppTypography.bodySmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        AppSpacing.vSm,
        Obx(() {
          if (controller.selectedNetworkId.value == null) {
            return const CustomEmptyState.compact(
              title: 'اختر الشبكة الموردة أولاً',
              subtitle: 'سيظهر هنا كتالوج الباقات النشطة التابعة للشبكة.',
              icon: Icons.hub_outlined,
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
              AppSpacing.vSm,
              if (controller.isLoadingPackages.value &&
                  controller.availablePackages.isEmpty)
                const CustomStateView.loading(presentation: CustomStatePresentation.skeletonOnly, skeleton: CustomStateSkeleton(layout: CustomStateSkeletonLayout.list, itemCount: 3, cardHeight: 124, ))
              else if (controller.packageErrorMessage.value != null &&
                  controller.availablePackages.isEmpty)
                _buildCatalogFailureState(context)
              else if (controller.availablePackages.isEmpty &&
                  controller.packageSearchQuery.value.isNotEmpty)
                CustomEmptyState.search(
                  query: controller.packageSearchQuery.value,
                  onClearSearch: controller.clearPackageSearch,
                )
              else if (controller.availablePackages.isEmpty)
                const CustomEmptyState.compact(
                  title: 'لا توجد باقات نشطة',
                  subtitle: 'لا تتوفر باقات نشطة لدى الشبكة المحددة حالياً.',
                  icon: Icons.inventory_2_outlined,
                )
              else
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
                                width: cardWidth,
                                child: ProcurementPackageOptionCard(
                                  package: package,
                                  quantity: controller.cartQuantityForPackage(
                                    package.packageId,
                                  ),
isCashSale: controller.selectedSaleType.value == SaleType.cash,
                                  onSetQuantity: (quantity) =>
                                      controller.setPackageVoucherCount(package, quantity),
                                ),
                              );
                            }),
                            if (controller.isLoadingMorePackages.value)
                              SizedBox(
                                width: cardWidth,
                                child: const CustomSkeletonCard(height: 124),
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
          );
        }),

      ],
    );
  }
}
