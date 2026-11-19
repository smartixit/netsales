import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/requests/presentation/controllers/network_procurement_review_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_orders_summary_strip.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_search_filter_header.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

/// واجهة استعراض ومراجعة طلبات التوريد الواردة لمساحة شبكة التوزيع (Network Workspace)
class NetworkProcurementOrdersView
    extends GetView<NetworkProcurementReviewController> {
  const NetworkProcurementOrdersView({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final topPadding = embedded
        ? MediaQuery.paddingOf(context).top + 20.h
        : AppSpacing.md;
    final bottomPadding = embedded
        ? 115.h + MediaQuery.paddingOf(context).bottom
        : MediaQuery.paddingOf(context).bottom + AppSpacing.xl;
    final horizontalPadding = AppBreakpoints.screenMargin(context);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: RefreshIndicator.adaptive(
          edgeOffset: embedded ? topPadding - 14.h : 0.0,
          displacement: 36.h,
          color: colors.primary,
          backgroundColor: colors.surface,
          strokeWidth: 2.5,
          onRefresh: controller.refreshOrders,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scroll) {
              if (scroll.depth == 0 &&
                  scroll.metrics.extentAfter <= 220 &&
                  controller.hasMore) {
                controller.loadMoreRequests();
              }
              return false;
            },
            child: CustomScrollView(
              key: const PageStorageKey<String>(
                'network-procurement-orders-scroll',
              ),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    topPadding,
                    horizontalPadding,
                    0,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // 1. الترويسة القيادية لطلبات التوريد الواردة
                      const CustomPageHeroCard(
                        title: 'طلبات التوريد الواردة',
                        subtitle:
                            'مراجعة واعتماد طلبات نقاط البيع، مقارنة الكميات والأسعار، وإصدار الفواتير المعتمدة.',
                        icon: Icons.receipt_long_rounded,
                      ),

                      // 2. شريط ملخص المؤشرات
                      Obx(
                        () => ProcurementOrdersSummaryStrip(
                          isNetworkView: true,
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

                      // 3. شريط البحث والفلترة السريعة
                      Obx(
                        () => ProcurementSearchFilterHeader(
                          searchController: controller.searchController,
                          searchQuery: controller.searchQuery.value,
                          selectedStatus: controller.statusFilter.value,
                          onStatusChanged: controller.setStatusFilter,
                          onClearSearch: controller.searchController.clear,
                        ),
                      ),

                      // 4. منتقي الشبكات في حالة وجود أكثر من شبكة للمشغل
                      Obx(() {
                        final networks = controller.authorizedNetworks;
                        if (networks.length <= 1) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.sm),
                          child: CustomDropdown<int>(
                            label: 'تصفية بحسب الشبكة',
                            searchEnabled: false,
                            rxValue: controller.selectedNetworkId,
                            items: networks.map((net) {
                              return DropdownItem<int>(
                                value: net.networkId,
                                child: Text(net.networkName),
                              );
                            }).toList(),
                            onChanged: controller.onNetworkFilterChanged,
                          ),
                        );
                      }),
                    ]),
                  ),
                ),

                // 5. محتوى القائمة
                Obx(() {
                  if (controller.isLoading.value &&
                      controller.requests.isEmpty) {
                    return SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        AppSpacing.xs,
                        horizontalPadding,
                        bottomPadding,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: CustomStateView.loading(
                          presentation: CustomStatePresentation.skeletonOnly,
                          skeleton: CustomStateSkeleton(
                            layout: CustomStateSkeletonLayout.list,
                            itemCount: 3,
                            cardHeight: 160.h,
                            maxColumns: 1,
                          ),
                        ),
                      ),
                    );
                  }

                  if (controller.errorMessage.value != null &&
                      controller.requests.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            AppSpacing.lg,
                            horizontalPadding,
                            bottomPadding,
                          ),
                          child: CustomErrorState(
                            title: 'تعذر جلب طلبات التوريد الواردة',
                            subtitle: controller.errorMessage.value,
                            onRetry: controller.refreshOrders,
                          ),
                        ),
                      ),
                    );
                  }

                  if (controller.requests.isEmpty) {
                    final hasFilter = controller.statusFilter.value != null ||
                        controller.searchQuery.value.trim().isNotEmpty;

                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            AppSpacing.lg,
                            horizontalPadding,
                            bottomPadding,
                          ),
                          child: CustomEmptyState(
                            icon: hasFilter
                                ? Icons.search_off_rounded
                                : Icons.inbox_outlined,
                            title: hasFilter
                                ? 'لا توجد طلبات مطابقة'
                                : 'لا توجد طلبات توريد واردة حالياً',
                            subtitle: hasFilter
                                ? 'جرّب تغيير كلمات البحث أو تصفية الحالات.'
                                : 'ستظهر هنا طلبات شراء الكروت الواردة من نقاط البيع المرتبطة.',
                            actionLabel:
                                hasFilter ? 'مسح عوامل التصفية' : null,
                            onAction:
                                hasFilter ? controller.resetFilters : null,
                          ),
                        ),
                      ),
                    );
                  }

                  final requestCount = controller.requests.length;
                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      AppSpacing.xs,
                      horizontalPadding,
                      bottomPadding,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index.isOdd) return AppSpacing.vSm;
                          final requestIndex = index ~/ 2;
                          final request = controller.requests[requestIndex];

                          return Obx(() {
                            final isExpanded = controller
                                    .expandedRequestId.value ==
                                request.requestId;

                            return ProcurementOrderCard(
                              key: ValueKey<String>(
                                'network-procurement-order-${request.requestId}',
                              ),
                              request: request,
                              isNetworkView: true,
                              isExpanded: isExpanded,
                              onToggleExpand: () =>
                                  controller.toggleAccordion(request.requestId),
                              onDetails: () =>
                                  controller.openRequestDetails(request),
                              onInvoiceTap: request.invoiceId != null
                                  ? () => controller.openInvoice(request.invoiceId!)
                                  : null,
                              onApprove: (request.isPending &&
                                      controller.canApproveRequests)
                                  ? () =>
                                      controller.promptApproveRequest(request)
                                  : null,
                              onModify: (request.isPending &&
                                      controller.canModifyRequests)
                                  ? () =>
                                      controller.openModificationSheet(request)
                                  : null,
                              onReject: (request.isPending &&
                                      controller.canRejectRequests)
                                  ? () =>
                                      controller.promptRejectRequest(request)
                                  : null,
                            );
                          });
                        },
                        childCount: requestCount == 0
                            ? 0
                            : requestCount * 2 - 1,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
