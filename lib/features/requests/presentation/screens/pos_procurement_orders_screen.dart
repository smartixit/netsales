import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_orders_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/pos_procurement_order_card.dart';
import 'package:netsales/features/requests/presentation/widgets/pos_procurement_orders_hero.dart';
import 'package:netsales/features/requests/presentation/widgets/pos_procurement_orders_summary_strip.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_search_filter_header.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة استعراض وإدارة طلبات التوريد لنقطة البيع (PosProcurementOrdersScreen - V2)
///
/// مصممة وفق أحدث معايير الكلين كود والتكوين التجميعي النظيف:
/// - هوامش موحدة متطابقة 100% مع لوحة التحكم لتجنب أي تداخل مع AppBar أو BottomNavBar.
/// - حاوية متجاوبة مركزية بحد أقصى للعرض.
/// - شجرة تمرير أحادية تحافظ على انسيابية الأداء ودعم مؤشرات السحب للتحديث والترقيم بالـ Cursor.
class PosProcurementOrdersScreen
    extends GetView<PosProcurementOrdersController> {
  const PosProcurementOrdersScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // هوامش موحدة ومتطابقة بدقة مع لوحة التحكم (PosHomeDashboard) لمنع أي تداخل
    final topPadding = embedded
        ? MediaQuery.paddingOf(context).top + 20.h
        : AppSpacing.md;
    final bottomPadding = embedded
        ? 115.h + MediaQuery.paddingOf(context).bottom
        : MediaQuery.paddingOf(context).bottom + AppSpacing.xl;
    final horizontalPadding = AppBreakpoints.screenMargin(context);

    final scrollView = RefreshIndicator(
      onRefresh: controller.refreshOrders,
      color: colors.primary,
      backgroundColor: colors.surface,
      strokeWidth: 2.5,
      displacement: 40.h,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll.depth == 0 &&
              scroll.metrics.extentAfter <= 220 &&
              controller.hasMore) {
            controller.loadMoreRequests();
          }
          return false;
        },
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: CustomScrollView(
              key: const PageStorageKey<String>(
                'pos-procurement-orders-scroll',
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
                      PosProcurementOrdersHero(
                        embedded: embedded,
                        canCreate: !embedded && controller.canCreateOrder,
                        onCreate: controller.navigateToNewOrder,
                      ),
                      Obx(
                        () => PosProcurementOrdersSummaryStrip(
                          totalCount: controller.totalOrdersCount,
                          pendingCount: controller.pendingOrdersCount,
                          approvedCount: controller.approvedOrdersCount,
                          isLoading:
                              controller.isLoading.value &&
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
                    ]),
                  ),
                ),
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
                            title: 'تعذر جلب طلبات التوريد',
                            subtitle: controller.errorMessage.value,
                            onRetry: controller.refreshOrders,
                          ),
                        ),
                      ),
                    );
                  }

                  if (controller.requests.isEmpty) {
                    final hasFilter =
                        controller.statusFilter.value != null ||
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
                                : Icons.inventory_2_outlined,
                            title: hasFilter
                                ? 'لا توجد طلبات مطابقة'
                                : 'لا توجد طلبات توريد حالياً',
                            subtitle: hasFilter
                                ? 'جرّب تغيير كلمات البحث أو تصفية الحالات.'
                                : 'يمكنك إنشاء طلب توريد جديد من شبكاتك الموردة.',
                            actionLabel: hasFilter
                                ? 'مسح عوامل التصفية'
                                : (controller.canCreateOrder
                                      ? 'طلب توريد جديد'
                                      : null),
                            onAction: hasFilter
                                ? controller.resetFilters
                                : (controller.canCreateOrder
                                      ? controller.navigateToNewOrder
                                      : null),
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
                            final isExpanded =
                                controller.expandedRequestId.value ==
                                request.requestId;
                            return PosProcurementOrderCard(
                              key: ValueKey<String>(
                                'pos-procurement-order-${request.requestId}',
                              ),
                              request: request,
                              isExpanded: isExpanded,
                              onToggleExpand: () =>
                                  controller.toggleAccordion(request.requestId),
                              onDetails: () =>
                                  controller.openRequestDetails(request),
                              onEdit:
                                  request.isPending && controller.canCreateOrder
                                  ? () => controller.openEditOrder(request)
                                  : null,
                              onCancel:
                                  request.isPending && controller.canCancelOrder
                                  ? () =>
                                        controller.promptCancelRequest(request)
                                  : null,
                              onDelete:
                                  request.isCancelled &&
                                      controller.canCancelOrder
                                  ? () =>
                                        controller.promptDeleteRequest(request)
                                  : null,
                            );
                          });
                        },
                        childCount: requestCount == 0
                            ? 0
                            : requestCount * 2 - 1,
                        addAutomaticKeepAlives: false,
                      ),
                    ),
                  );
                }),
                Obx(() {
                  if (controller.isLoadingMore.value) {
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
                          skeleton: const CustomStateSkeleton(
                            layout: CustomStateSkeletonLayout.list,
                            itemCount: 1,
                            cardHeight: 140,
                            maxColumns: 1,
                          ),
                        ),
                      ),
                    );
                  }

                  if (controller.loadMoreError.value != null) {
                    return SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        AppSpacing.xs,
                        horizontalPadding,
                        bottomPadding,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: CustomStateView.error(
                          title: 'تعذر تحميل بقية الطلبات',
                          subtitle: controller.loadMoreError.value,
                          presentation: CustomStatePresentation.banner,
                          onAction: controller.loadMoreRequests,
                          actionLabel: 'إعادة المحاولة',
                        ),
                      ),
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }),
              ],
            ),
          ),
        ),
      ),
    );

    if (embedded) return scrollView;

    return CustomAppScaffold(
      appBar: AppBar(title: const Text('طلبات التوريد'), centerTitle: true),
      body: scrollView,
    );
  }
}
