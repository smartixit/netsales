import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/finance/presentation/controllers/network_wallet_transfer_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

class NetworkWalletTransferSheet
    extends GetView<NetworkWalletTransferController> {
  const NetworkWalletTransferSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final wallet = controller.selectedWallet.value;
      final isNetworkToPos =
          controller.transferDirection.value ==
          WalletTransferDirection.networkToPos;

      return CustomBottomSheet(
        title: isNetworkToPos
            ? 'تحويل رصيد من محفظة الشبكة'
            : 'استرجاع رصيد من محفظة نقطة البيع',
        subtitle: wallet?.networkName ?? 'شبكة #${wallet?.networkId ?? ''}',
        scrollable: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // شريط تبديل اتجاه العملية باستخدام CustomSegmentedBar الموحد
            CustomSegmentedBar(
              selectedIndex: isNetworkToPos ? 0 : 1,
              onSegmentChanged: (index) {
                controller.setTransferDirection(
                  index == 0
                      ? WalletTransferDirection.networkToPos
                      : WalletTransferDirection.posToNetwork,
                );
              },
              items: const [
                CustomSegmentItem(
                  label: 'تحويل إلى النقطة',
                  icon: Icons.arrow_downward_rounded,
                ),
                CustomSegmentItem(
                  label: 'استرجاع للشبكة',
                  icon: Icons.arrow_upward_rounded,
                ),
              ],
            ),
            AppSpacing.vMd,
            if (controller.isLoadingPos.value &&
                !controller.hasLoadedPosList.value)
              const CustomSkeletonFeed(itemCount: 2)
            else if (controller.posErrorMessage.value != null &&
                !controller.hasLoadedPosList.value)
              CustomErrorState.compact(
                title: 'تعذر تحميل نقاط البيع',
                subtitle: controller.posErrorMessage.value,
                onRetry: () => controller.loadPosForNetwork(),
              )
            else if (controller.posList.isEmpty &&
                controller.hasLoadedPosList.value &&
                !controller.hasMorePos)
              const CustomEmptyState(
                icon: Icons.point_of_sale_outlined,
                title: 'لا توجد نقاط بيع مرتبطة',
                subtitle: 'لا توجد نقطة بيع نشطة يمكن إجراء العملية معها.',
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.posErrorMessage.value != null) ...[
                    CustomErrorState.compact(
                      title: 'تعذر تحديث نتائج البحث',
                      subtitle: controller.posErrorMessage.value,
                      onRetry: () =>
                          controller.searchPos(controller.searchQuery),
                    ),
                    AppSpacing.vXs,
                  ],
                  CustomDropdown<int>(
                    label: isNetworkToPos
                        ? 'نقطة البيع المستفيدة'
                        : 'نقطة البيع المصدر (المسترجع منها)',
                    hint: 'ابحث واختر نقطة البيع',
                    prefixIcon: Icons.storefront_outlined,
                    isRequired: true,
                    searchEnabled: true,
                    rxValue: controller.selectedPosId,
                    isSearching: controller.isLoadingPos.value,
                    onRemoteSearch: controller.searchPos,
                    selectedItemFallback:
                        controller.selectedPos.value == null
                        ? null
                        : DropdownItem<int>(
                            value: controller.selectedPos.value!.posId,
                            child: Text(
                              controller.selectedPos.value!.posName,
                            ),
                          ),
                    items: controller.posList
                        .map(
                          (pos) => DropdownItem<int>(
                            value: pos.posId,
                            child: Text(pos.posName),
                          ),
                        )
                        .toList(growable: false),
                    itemSearchText: (id) =>
                        controller.posList
                            .firstWhereOrNull((pos) => pos.posId == id)
                            ?.posName ??
                        id.toString(),
                    onChanged: controller.onPosChanged,
                  ),
                  if (controller.posLoadMoreErrorMessage.value != null) ...[
                    AppSpacing.vXs,
                    CustomErrorState.compact(
                      title: 'تعذر تحميل بقية نقاط البيع',
                      subtitle: controller.posLoadMoreErrorMessage.value,
                      onRetry: controller.loadMorePos,
                    ),
                  ],
                  if (controller.isLoadingMorePos.value) ...[
                    AppSpacing.vXs,
                    const CustomSkeletonFeed(itemCount: 2),
                  ] else if (controller.hasMorePos) ...[
                    AppSpacing.vXs,
                    CustomButton.secondary(
                      text: 'تحميل مزيد من نقاط البيع',
                      prefix: Icons.expand_more_rounded,
                      width: double.infinity,
                      onPressed: controller.loadMorePos,
                    ),
                  ],
                ],
              ),
            AppSpacing.vMd,
            CustomTextField(
              controller: controller.amountController,
              label: isNetworkToPos ? 'مبلغ التحويل' : 'مبلغ الاسترجاع',
              hint: 'أدخل المبلغ',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              isRequired: true,
              enabled: !controller.isSubmitting.value,
            ),
            AppSpacing.vSm,
            CustomTextField(
              controller: controller.statementController,
              label: isNetworkToPos ? 'بيان التحويل' : 'بيان الاسترجاع',
              hint: 'سبب أو وصف مختصر للعملية (اختياري)',
              maxLength: 255,
              isRequired: false,
              enabled: !controller.isSubmitting.value,
            ),
            AppSpacing.vMd,
            CustomButton.primary(
              text: isNetworkToPos ? 'تأكيد التحويل' : 'تأكيد الاسترجاع',
              prefix: isNetworkToPos
                  ? Icons.swap_horiz_rounded
                  : Icons.keyboard_return_rounded,
              width: double.infinity,
              loading: controller.isSubmitting.value,
              enabled:
                  !controller.isSubmitting.value &&
                  controller.selectedPosId.value != null,
              onPressed: controller.submitTransfer,
            ),
            AppSpacing.vXs,
            CustomButton.text(
              text: 'إلغاء',
              width: double.infinity,
              enabled: !controller.isSubmitting.value,
              onPressed: () => Get.back<void>(),
            ),
          ],
        ),
      );
    });
  }
}
