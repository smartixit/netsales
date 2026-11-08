import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/finance/presentation/controllers/repayment_collection_controller.dart';
import 'package:netsales/features/finance/presentation/widgets/repayment_beneficiary_skeleton.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

class RepaymentCollectionScreen extends GetView<RepaymentCollectionController> {
  const RepaymentCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      appBar: AppBar(title: const Text('تحصيل سداد مديونية (FIFO)')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: colors.primary),
                  AppSpacing.hSm,
                  Expanded(
                    child: Text(
                      'يتم توزيع مبلغ السداد آلياً على الفواتير الآجلة المستحقة بنظام الأسبقية FIFO بواسطة الخادم.',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.vLg,
            Obx(() {
              if (controller.isLoadingInitial.value) {
                return const RepaymentBeneficiarySkeleton();
              }
              if (controller.initialErrorMessage.value != null) {
                return CustomErrorState.compact(
                  title: 'تعذر تحميل الشبكات',
                  subtitle: controller.initialErrorMessage.value,
                  onRetry: controller.loadInitialData,
                );
              }
              if (controller.networks.isEmpty) {
                return const CustomEmptyState(
                  icon: Icons.account_tree_outlined,
                  title: 'لا توجد شبكات متاحة',
                  subtitle: 'لا توجد شبكة مخوّلة لإجراء تحصيل السداد حالياً.',
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الشبكة المستفيدة',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.vXs,
                  CustomDropdown<int>(
                    hint: 'اختر الشبكة المستفيدة',
                    searchEnabled: controller.networks.length > 5,
                    isRequired: true,
                    rxValue: controller.selectedNetworkId,
                    items: controller.networks.map((network) {
                      return DropdownItem<int>(
                        value: network.networkId,
                        child: Text(network.networkName),
                      );
                    }).toList(growable: false),
                    itemSearchText: (networkId) => controller.networks
                        .firstWhereOrNull((network) => network.networkId == networkId)
                        ?.networkName ?? networkId.toString(),
                    onChanged: controller.onNetworkChanged,
                  ),
                  AppSpacing.vMd,
                  if (controller.posErrorMessage.value != null)
                    CustomErrorState.compact(
                      title: 'تعذر تحميل نقاط البيع',
                      subtitle: controller.posErrorMessage.value,
                      onRetry: controller.selectedNetworkId.value == null
                          ? null
                          : () => controller.loadPosForNetwork(
                                controller.selectedNetworkId.value!,
                              ),
                    )
                  else if (controller.isLoadingPos.value &&
                      !controller.hasLoadedPosList.value)
                    const RepaymentBeneficiaryFieldSkeleton()
                  else
                    CustomDropdown<int>(
                          hint: controller.selectedNetworkId.value == null
                              ? 'اختر الشبكة أولاً'
                              : 'ابحث عن نقطة البيع المستفيدة',
                    searchEnabled: controller.posList.length > 5,
                    isRequired: true,
                    enabled: controller.selectedNetworkId.value != null,
                    rxValue: controller.selectedPosId,
                    isSearching: controller.isLoadingPos.value,
                    onRemoteSearch: controller.searchPosForNetwork,
                    selectedItemFallback: controller.selectedPos.value == null
                        ? null
                        : DropdownItem<int>(
                            value: controller.selectedPos.value!.posId,
                            child: Text(controller.selectedPos.value!.posName),
                          ),
                    items: controller.posList.map((pos) {
                      return DropdownItem<int>(
                        value: pos.posId,
                        child: Text(pos.posName),
                      );
                    }).toList(growable: false),
                    itemSearchText: (posId) => controller.posList
                            .firstWhereOrNull((pos) => pos.posId == posId)
                            ?.posName ??
                        (controller.selectedPos.value?.posId == posId
                            ? controller.selectedPos.value!.posName
                            : posId.toString()),
                    onChanged: controller.onPosChanged,
                  ),
                ],
              );
            }),
            AppSpacing.vMd,
            CustomTextField(
              controller: controller.amountController,
              label: 'مبلغ التحصيل والسداد',
              hint: 'أدخل المبلغ المحصل...',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              isRequired: true,
            ),
            AppSpacing.vMd,
            CustomTextField(
              controller: controller.refController,
              label: 'رقم الإشعار / المرجع (اختياري)',
              hint: 'مثال: REF-990021...',
              isRequired: false,
            ),
            AppSpacing.vMd,
            CustomTextField(
              controller: controller.notesController,
              label: 'ملاحظات السداد (اختياري)',
              hint: 'أي تفاصيل متعلقة بالتحصيل...',
              maxLines: 2,
              isRequired: false,
            ),
            AppSpacing.vXl,
            CustomButton(
              text: 'تأكيد التحصيل والتوزيع السيادي (FIFO)',
              icon: Icons.check_circle_outline,
              onPressed: () async {
                final ok = await controller.submitRepayment();
                if (ok) {
                  controller.amountController.clear();
                  controller.refController.clear();
                  controller.notesController.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
