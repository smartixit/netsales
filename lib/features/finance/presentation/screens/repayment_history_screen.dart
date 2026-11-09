import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/finance/presentation/controllers/repayment_history_controller.dart';
import 'package:netsales/features/finance/presentation/screens/repayment_details_screen.dart';
import 'package:netsales/features/finance/presentation/widgets/repayment_card.dart';
import 'package:netsales/features/finance/presentation/widgets/repayment_card_skeleton.dart';
import 'package:netsales/features/finance/presentation/widgets/repayment_history_scope_panel.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

class RepaymentHistoryScreen extends GetView<RepaymentHistoryController> {
  final bool isNetworkView;

  const RepaymentHistoryScreen({super.key, this.isNetworkView = true});

  @override
  Widget build(BuildContext context) {
    final isCompact = AppBreakpoints.isCompact(context);

    return CustomAppScaffold(
      appBar: AppBar(title: const Text('سجل سندات سداد الديون')),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppBreakpoints.maxContentWidth,
            ),
            child: Padding(
              padding: EdgeInsets.all(
                isCompact ? AppSpacing.md : AppSpacing.cardPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RepaymentHistoryScopePanel(controller: controller),
                  AppSpacing.vMd,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'السندات المطابقة',
                        style: AppTypography.titleSmall.copyWith(
                          color: context.colors.onSurface,
                        ),
                      ),
                      Obx(
                        () => CustomChip(
                          label: '${controller.repayments.length} معروض',
                          icon: Icons.receipt_long_outlined,
                          isCompact: true,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vSm,
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
                        return const CustomEmptyState(
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
                          onRetry: () =>
                              controller.loadRepayments(isRefresh: true),
                        );
                      }

                      if (controller.repayments.isEmpty) {
                        return CustomEmptyState(
                          icon: Icons.payments_outlined,
                          title: controller.selectedStatus.value == 'ALL'
                              ? 'لا توجد سندات سداد'
                              : controller.selectedStatus.value == 'REVERSED'
                              ? 'لا توجد سندات معكوسة'
                              : 'لا توجد سندات مكتملة',
                          subtitle: 'لا توجد نتائج لهذه الشبكة وفق حالة السند المحددة.',
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
                          physics: const AlwaysScrollableScrollPhysics(),
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
                                      : () => controller.loadRepayments(
                                          isRefresh: true,
                                        ),
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
        ),
      ),
    );
  }
}
