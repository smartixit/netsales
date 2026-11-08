import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/finance/presentation/controllers/repayment_history_controller.dart';
import 'package:netsales/features/finance/presentation/screens/repayment_details_screen.dart';
import 'package:netsales/features/finance/presentation/widgets/repayment_card.dart';
import 'package:netsales/features/finance/presentation/widgets/repayment_card_skeleton.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

class RepaymentHistoryScreen extends GetView<RepaymentHistoryController> {
  final bool isNetworkView;

  const RepaymentHistoryScreen({super.key, this.isNetworkView = true});

  @override
  Widget build(BuildContext context) {
    return CustomAppScaffold(
      appBar: AppBar(title: const Text('سجل سندات سداد الديون')),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HistoryScopePanel(controller: controller),
              AppSpacing.vMd,
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingNetworks.value) {
                    return const CustomSkeletonFeed(itemCount: 3);
                  }

                  if (controller.networkErrorMessage.value != null &&
                      controller.networks.isEmpty) {
                    return CustomErrorState.compact(
                      title: 'تعذر تحميل نطاق السجل',
                      subtitle: controller.networkErrorMessage.value,
                      onRetry: controller.initializeNetworks,
                    );
                  }

                  if (controller.networks.isEmpty) {
                    return const CustomEmptyState(
                      icon: Icons.account_tree_outlined,
                      title: 'لا توجد شبكات متاحة',
                      subtitle: 'لا توجد شبكة مخوّلة لعرض سندات السداد.',
                    );
                  }

                  if (!controller.hasSelectedNetwork) {
                    return CustomEmptyState(
                      icon: Icons.account_tree_outlined,
                      title: 'اختر الشبكة أولاً',
                      subtitle: 'حدد الشبكة التي تريد مراجعة سندات سدادها.',
                    );
                  }

                  if (controller.isLoading.value &&
                      controller.repayments.isEmpty) {
                    return const CustomSkeletonFeed(itemCount: 4);
                  }

                  if (controller.repayments.isEmpty &&
                      controller.errorMessage.value != null) {
                    return CustomErrorState.compact(
                      title: 'تعذر تحميل سندات السداد',
                      subtitle: controller.errorMessage.value,
                      onRetry: () => controller.loadRepayments(isRefresh: true),
                    );
                  }

                  if (controller.repayments.isEmpty) {
                    return const CustomEmptyState(
                      icon: Icons.payments_outlined,
                      title: 'لا توجد سندات سداد',
                      subtitle: 'لم تسجل أي سندات سداد لهذه الشبكة حتى الآن.',
                    );
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (scrollInfo.metrics.pixels >=
                              scrollInfo.metrics.maxScrollExtent - 200 &&
                          controller.hasMore &&
                          controller.errorMessage.value == null &&
                          !controller.isLoadingMore.value) {
                        controller.loadMoreRepayments();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      itemCount:
                          controller.repayments.length +
                          (controller.hasMore ||
                                  (controller.errorMessage.value != null &&
                                      controller.repayments.isNotEmpty)
                              ? 1
                              : 0),
                      itemBuilder: (context, index) {
                        if (index == controller.repayments.length) {
                          if (controller.errorMessage.value != null) {
                            return CustomErrorState.compact(
                              title: 'تعذر تحميل المزيد من السندات',
                              subtitle: controller.errorMessage.value,
                              onRetry: controller.hasMore
                                  ? controller.loadMoreRepayments
                                  : () => controller.loadRepayments(isRefresh: true),
                            );
                          }
                          return const RepaymentCardSkeleton();
                        }
                        if (index > controller.repayments.length) {
                          return const SizedBox.shrink();
                        }

                        final repayment = controller.repayments[index];
                        return RepaymentCard(
                          repayment: repayment,
                          isNetworkView: isNetworkView,
                          onTap: () {
                            Get.to<void>(
                              () => RepaymentDetailsScreen(
                                repayment: repayment,
                                isNetworkView: isNetworkView,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryScopePanel extends StatelessWidget {
  const _HistoryScopePanel({required this.controller});

  final RepaymentHistoryController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: colors.onPrimaryContainer,
                  size: 20,
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نطاق سجل السداد',
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    Text(
                      'اعرض السندات ضمن شبكة محددة ثم صفّها حسب الحالة.',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vMd,
          Obx(() {
            if (controller.isLoadingNetworks.value) {
              return const CustomSkeletonFeed(itemCount: 1);
            }

            if (controller.networkErrorMessage.value != null &&
                controller.networks.isEmpty) {
              return CustomErrorState.compact(
                title: 'تعذر تحميل الشبكات',
                subtitle: controller.networkErrorMessage.value,
                onRetry: controller.initializeNetworks,
              );
            }

            if (controller.networks.isEmpty) {
              return const SizedBox.shrink();
            }

            final selected = controller.selectedNetwork;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.networks.length > 1)
                  CustomDropdown<int>(
                    label: 'الشبكة',
                    hint: 'اختر الشبكة',
                    prefixIcon: Icons.account_tree_outlined,
                    rxValue: controller.selectedNetworkId,
                    items: controller.networks
                        .map(
                          (network) => DropdownItem<int>(
                            value: network.networkId,
                            child: Text(
                              network.networkName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(growable: false),
                    itemSearchText: (networkId) =>
                        controller.networks
                            .firstWhereOrNull(
                              (network) => network.networkId == networkId,
                            )
                            ?.networkName ??
                        networkId.toString(),
                    onChanged: (networkId) {
                      if (networkId != null) {
                        controller.selectNetwork(networkId);
                      }
                    },
                  )
                else if (selected != null)
                  _SelectedNetworkValue(name: selected.networkName),
                if (controller.hasSelectedNetwork) ...[
                  AppSpacing.vSm,
                  CustomDropdown<String>(
                    label: 'حالة السند',
                    hint: 'جميع الحالات',
                    prefixIcon: Icons.filter_alt_outlined,
                    rxValue: controller.selectedStatus,
                    items: const [
                      DropdownItem<String>(
                        value: 'ALL',
                        child: Text('جميع الحالات'),
                      ),
                      DropdownItem<String>(
                        value: 'COMPLETED',
                        child: Text('مكتمل'),
                      ),
                      DropdownItem<String>(
                        value: 'REVERSED',
                        child: Text('معكوس'),
                      ),
                    ],
                    searchEnabled: false,
                    onChanged: controller.onStatusChanged,
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _SelectedNetworkValue extends StatelessWidget {
  const _SelectedNetworkValue({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.account_tree_outlined, color: colors.primary, size: 19),
          AppSpacing.hSm,
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleSmall.copyWith(
                color: colors.onSurface,
              ),
            ),
          ),
          Icon(Icons.verified_outlined, color: colors.success, size: 17),
        ],
      ),
    );
  }
}
