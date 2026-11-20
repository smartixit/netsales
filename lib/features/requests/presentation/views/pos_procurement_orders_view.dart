import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_orders_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_orders_summary_strip.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_search_filter_header.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';
import 'package:netsales/widgets/lists/custom_cursor_load_more.dart';

/// واجهة استعراض وإدارة طلبات التوريد لمساحة نقطة البيع (POS Workspace)
class PosProcurementOrdersView
    extends GetView<PosProcurementOrdersController> {
  const PosProcurementOrdersView({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return CustomRefreshablePage.slivers(
      embedded: embedded,
      onRefresh: controller.refreshOrders,
      onLoadMore: controller.loadMoreRequests,
      hasMore: controller.hasMore,
      hasMorePredicate: () => controller.hasMore,
      scrollKey: const PageStorageKey<String>('pos-procurement-orders-scroll'),
      slivers: [
        // 1. الترويسة القيادية لطلبات التوريد وشريط الملخص وفلاتر البحث
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomPageHeroCard(
                title: 'طلبات التوريد',
                subtitle:
                    'متابعة وإدارة طلبات كروت الشبكات، حالات الاعتماد، وتفاصيل الكميات فورياً.',
                icon: Icons.receipt_long_rounded,
                action: (!embedded && controller.canCreateOrder)
                    ? CustomButton.primary(
                        text: 'طلب توريد جديد +',
                        icon: Icons.add_shopping_cart_rounded,
                        shape: AppButtonShape.pill,
                        size: AppButtonSize.small,
                        onPressed: controller.navigateToNewOrder,
                      )
                    : null,
              ),

              Obx(
                () => ProcurementOrdersSummaryStrip(
                  isNetworkView: false,
                  totalCount: controller.totalOrdersCount,
                  pendingCount: controller.pendingOrdersCount,
                  approvedCount: controller.approvedOrdersCount,
                  rejectedCount: controller.rejectedOrdersCount,
                  cancelledCount: controller.cancelledOrdersCount,
                  isLoading: controller.isLoading.value &&
                      controller.requests.isEmpty,
                  selectedStatus: controller.statusFilter.value,
                  onStatusTap: controller.setStatusFilter,
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
              SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),

        // 2. الحالات التفاعلية المركزية (تحميل أولي، خطأ، فراغ) أو قائمة الطلبات
        Obx(() {
          final isLoading = controller.isLoading.value;
          final error = controller.errorMessage.value;
          final isEmpty = controller.requests.isEmpty;
          final hasFilter = controller.statusFilter.value != null ||
              controller.searchQuery.value.trim().isNotEmpty;

          if (isLoading && isEmpty) {
            return const SliverToBoxAdapter(
              child: CustomStateView.loading(
                presentation: CustomStatePresentation.skeletonOnly,
                skeleton: CustomStateSkeleton(
                  layout: CustomStateSkeletonLayout.list,
                  itemCount: 4,
                  cardHeight: 156,
                  maxColumns: 1,
                  hasLeading: true,
                ),
              ),
            );
          }

          if (error != null && isEmpty) {
            return SliverToBoxAdapter(
              child: CustomErrorState(
                title: 'تعذر جلب طلبات التوريد',
                subtitle: error,
                onRetry: controller.refreshOrders,
              ),
            );
          }

          if (isEmpty) {
            return SliverToBoxAdapter(
              child: CustomEmptyState(
                icon: hasFilter
                    ? Icons.search_off_rounded
                    : Icons.inventory_2_outlined,
                title: hasFilter
                    ? 'لا توجد طلبات مطابقة'
                    : 'لا توجد طلبات توريد حالياً',
                subtitle: hasFilter
                    ? 'جرّب تغيير كلمات البحث أو تصفية الحالات.'
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

          final requestCount = controller.requests.length;
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index.isOdd) return AppSpacing.vSm;
                final requestIndex = index ~/ 2;
                final request = controller.requests[requestIndex];

                return Obx(() {
                  final isExpanded = controller.expandedRequestId.value ==
                      request.requestId;

                  return ProcurementOrderCard(
                    key: ValueKey<String>(
                      'pos-procurement-order-${request.requestId}',
                    ),
                    request: request,
                    isNetworkView: false,
                    isExpanded: isExpanded,
                    onToggleExpand: () =>
                        controller.toggleAccordion(request.requestId),
                    onDetails: () =>
                        controller.openRequestDetails(request),
                    onInvoiceTap: request.invoiceId != null
                        ? () => controller.openInvoice(request.invoiceId!)
                        : null,
                    onEdit: (request.isPending &&
                            controller.canCreateOrder)
                        ? () => controller.openEditOrder(request)
                        : null,
                    onCancel: (request.isPending &&
                            controller.canCancelOrder)
                        ? () =>
                            controller.promptCancelRequest(request)
                        : null,
                    onDelete: (request.isCancelled &&
                            controller.canCancelOrder)
                        ? () =>
                            controller.promptDeleteRequest(request)
                        : null,
                  );
                });
              },
              childCount: requestCount == 0 ? 0 : requestCount * 2 - 1,
            ),
          );
        }),

        // 3. ذيل التحميل الإضافي الموحد (CustomCursorLoadMore)
        SliverToBoxAdapter(
          child: Obx(
            () => CustomCursorLoadMore(
              hasMore: controller.hasMore,
              isLoading: controller.isLoadingMore.value,
              error: controller.loadMoreError.value,
              onPressed: controller.loadMoreRequests,
            ),
          ),
        ),
      ],
    );
  }
}
