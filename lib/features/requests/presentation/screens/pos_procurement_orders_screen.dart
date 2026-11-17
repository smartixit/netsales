import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_orders_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/pos_procurement_order_card.dart';
import 'package:netsales/features/requests/presentation/widgets/pos_procurement_orders_hero.dart';
import 'package:netsales/features/requests/presentation/widgets/pos_procurement_orders_summary_strip.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_search_filter_header.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة إدارة طلبات التوريد لنقطة البيع.
class PosProcurementOrdersScreen extends GetView<PosProcurementOrdersController> {
  const PosProcurementOrdersScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final topPadding = embedded ? MediaQuery.paddingOf(context).top : 0.0;
    final bottomPadding = embedded
        ? MediaQuery.paddingOf(context).bottom
        : AppSpacing.cardPadding;

    final content = Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        children: [
          PosProcurementOrdersHero(
            embedded: embedded,
            canCreate: controller.canCreateOrder,
            onCreate: controller.navigateToNewOrder,
            onRefresh: () => controller.loadRequests(isRefresh: true),
          ),
          Obx(
            () => PosProcurementOrdersSummaryStrip(
              summary: controller.statusSummary.value,
              isLoading: controller.isSummaryLoading.value,
            ),
          ),
          Obx(
            () => ProcurementSearchFilterHeader(
              searchController: controller.searchController,
              searchQuery: controller.searchQuery.value,
              selectedStatus: controller.statusFilter.value,
              onStatusChanged: controller.setStatusFilter,
              onClearSearch: controller.searchController.clear,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.requests.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: CustomStateView.loading(
                    presentation: CustomStatePresentation.skeletonOnly,
                    skeleton: CustomStateSkeleton(
                      layout: CustomStateSkeletonLayout.cards,
                      itemCount: 3,
                      cardHeight: 190.h,
                      maxColumns: 1,
                    ),
                  ),
                );
              }

              if (controller.errorMessage.value != null &&
                  controller.requests.isEmpty) {
                return Center(
                  child: CustomErrorState(
                    title: 'تعذر جلب طلبات التوريد',
                    subtitle: controller.errorMessage.value,
                    onRetry: () => controller.loadRequests(isRefresh: true),
                  ),
                );
              }

              if (controller.requests.isEmpty) {
                final hasFilter = controller.statusFilter.value != null ||
                    controller.searchQuery.value.trim().isNotEmpty;
                return Center(
                  child: CustomEmptyState(
                    icon: hasFilter
                        ? Icons.search_off_rounded
                        : Icons.inventory_2_outlined,
                    title: hasFilter
                        ? 'لا توجد طلبات مطابقة'
                        : 'لا توجد طلبات توريد حالياً',
                    subtitle: hasFilter
                        ? 'جرّب تغيير كلمات البحث أو الفلاتر.'
                        : 'يمكنك إنشاء طلب توريد جديد من شبكاتك الموردة.',
                    actionLabel: hasFilter
                        ? 'مسح عوامل التصفية'
                        : (controller.canCreateOrder ? 'طلب توريد جديد' : null),
                    onAction: hasFilter
                        ? controller.resetFilters
                        : (controller.canCreateOrder
                            ? controller.navigateToNewOrder
                            : null),
                  ),
                );
              }

              return RefreshIndicator.adaptive(
                onRefresh: () => controller.loadRequests(isRefresh: true),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scroll) {
                    if (scroll.metrics.pixels >=
                        scroll.metrics.maxScrollExtent - 220) {
                      controller.loadMoreRequests();
                    }
                    return false;
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.cardPadding,
                      AppSpacing.sm,
                      AppSpacing.cardPadding,
                      bottomPadding,
                    ),
                    itemCount: controller.requests.length +
                        (controller.isLoadingMore.value ? 1 : 0),
                    separatorBuilder: (_, _) => AppSpacing.vSm,
                    itemBuilder: (context, index) {
                      if (index == controller.requests.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                          child: CustomStateView.loading(
                            presentation: CustomStatePresentation.skeletonOnly,
                            skeleton: CustomStateSkeleton(
                              layout: CustomStateSkeletonLayout.cards,
                              itemCount: 1,
                              cardHeight: 190.h,
                              maxColumns: 1,
                            ),
                          ),
                        );
                      }

                      final request = controller.requests[index];
                      return PosProcurementOrderCard(
                        request: request,
                        onDetails: () => controller.openRequestDetails(request),
                        onEdit: request.isPending && controller.canCreateOrder
                            ? () => controller.openEditOrder(request)
                            : null,
                        onCancel: request.isPending && controller.canCancelOrder
                            ? () => controller.promptCancelRequest(request)
                            : null,
                        onDelete: request.isCancelled && controller.canCancelOrder
                            ? () => controller.promptDeleteRequest(request)
                            : null,
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );

    if (embedded) return content;

    return CustomAppScaffold(
      appBar: AppBar(
        title: const Text('طلبات التوريد'),
        centerTitle: true,
        actions: [
          CustomButton.icon(
            icon: Icons.refresh_rounded,
            tooltip: 'تحديث الطلبات',
            backgroundColor: Colors.transparent,
            onPressed: () => controller.loadRequests(isRefresh: true),
          ),
        ],
      ),
      body: content,
    );
  }
}
