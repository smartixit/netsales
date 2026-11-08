import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/finance/presentation/controllers/repayment_history_controller.dart';
import 'package:netsales/features/finance/presentation/screens/repayment_details_screen.dart';
import 'package:netsales/features/finance/presentation/widgets/repayment_card.dart';
import 'package:netsales/features/finance/presentation/widgets/repayment_card_skeleton.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

class RepaymentHistoryScreen extends GetView<RepaymentHistoryController> {
  final bool isNetworkView;

  const RepaymentHistoryScreen({super.key, this.isNetworkView = true});

  @override
  Widget build(BuildContext context) {
    return CustomAppScaffold(
      appBar: AppBar(title: const Text('سجل سندات سداد الديون')),
      body: RefreshIndicator(
        onRefresh: () => controller.loadRepayments(isRefresh: true),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
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
                    return CustomEmptyState(
                      icon: Icons.payments_outlined,
                      title: 'لا توجد سندات سداد',
                      subtitle: 'لم تسجل أي سندات سداد للديون حتى الآن.',
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
                              () =>
                                  RepaymentDetailsScreen(repayment: repayment),
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
