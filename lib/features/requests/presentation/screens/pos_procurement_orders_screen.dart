import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
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
///
/// تستخدم Scrollable واحداً للرأس والمؤشرات والبحث والقائمة حتى تبقى شجرة
/// التخطيط وSemantics مستقرة عند الانتقال من التحميل إلى البيانات الفعلية.
class PosProcurementOrdersScreen extends GetView<PosProcurementOrdersController> {
  const PosProcurementOrdersScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = embedded
        ? MediaQuery.paddingOf(context).bottom +
            AppSpacing.bottomNavHeight +
            AppSpacing.cardPadding +
            AppSpacing.sm
        : AppSpacing.cardPadding;

    final scrollView = RefreshIndicator.adaptive(
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
          key: const PageStorageKey<String>('pos-procurement-orders-scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: PosProcurementOrdersHero(
                embedded: embedded,
                canCreate: !embedded && controller.canCreateOrder,
                onCreate: controller.navigateToNewOrder,
              ),
            ),
            SliverToBoxAdapter(
              child: Obx(
                () => PosProcurementOrdersSummaryStrip(
                  summary: controller.statusSummary.value,
                  isLoading: controller.isSummaryLoading.value,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Obx(
                () => ProcurementSearchFilterHeader(
                  searchController: controller.searchController,
                  searchQuery: controller.searchQuery.value,
                  selectedStatus: controller.statusFilter.value,
                  onStatusChanged: controller.setStatusFilter,
                  onClearSearch: controller.searchController.clear,
                ),
              ),
            ),
            Obx(() {
              if (controller.isLoading.value &&
                  controller.requests.isEmpty) {
                // Skeleton elements are visual placeholders, not accessible
                // content. Excluding them prevents the loading subtree from
                // competing with the real request semantics during replacement.
                return SliverToBoxAdapter(
                  child: ExcludeSemantics(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.cardPadding,
                        AppSpacing.sm,
                        AppSpacing.cardPadding,
                        bottomPadding,
                      ),
                      child: CustomStateView.loading(
                        presentation: CustomStatePresentation.skeletonOnly,
                        skeleton: CustomStateSkeleton(
                          layout: CustomStateSkeletonLayout.list,
                          itemCount: 3,
                          cardHeight: 150.h,
                          maxColumns: 1,
                        ),
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
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: CustomErrorState(
                        title: 'تعذر جلب طلبات التوريد',
                        subtitle: controller.errorMessage.value,
                        onRetry: () =>
                            controller.loadRequests(isRefresh: true),
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
                      padding: EdgeInsets.all(AppSpacing.lg),
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
                  AppSpacing.cardPadding,
                  AppSpacing.sm,
                  AppSpacing.cardPadding,
                  bottomPadding,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index.isOdd) {
                        return AppSpacing.vSm;
                      }

                      final requestIndex = index ~/ 2;
                      final request = controller.requests[requestIndex];
                      return PosProcurementOrderCard(
                        key: ValueKey<String>(
                          'pos-procurement-order-${request.requestId}',
                        ),
                        request: request,
                        onDetails: () =>
                            controller.openRequestDetails(request),
                        onEdit: request.isPending &&
                                controller.canCreateOrder
                            ? () => controller.openEditOrder(request)
                            : null,
                        onCancel: request.isPending &&
                                controller.canCancelOrder
                            ? () =>
                                controller.promptCancelRequest(request)
                            : null,
                        onDelete: request.isCancelled &&
                                controller.canCancelOrder
                            ? () =>
                                controller.promptDeleteRequest(request)
                            : null,
                      );
                    },
                    childCount: requestCount == 0 ? 0 : requestCount * 2 - 1,
                    addAutomaticKeepAlives: false,
                  ),
                ),
              );
            }),
            Obx(() {
              if (controller.isLoadingMore.value) {
                return SliverToBoxAdapter(
                  child: ExcludeSemantics(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.cardPadding,
                        AppSpacing.xs,
                        AppSpacing.cardPadding,
                        bottomPadding,
                      ),
                      child: CustomStateView.loading(
                        presentation: CustomStatePresentation.skeletonOnly,
                        skeleton: const CustomStateSkeleton(
                          layout: CustomStateSkeletonLayout.list,
                          itemCount: 1,
                          cardHeight: 150,
                          maxColumns: 1,
                        ),
                      ),
                    ),
                  ),
                );
              }

              if (controller.loadMoreError.value != null) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.cardPadding,
                      AppSpacing.xs,
                      AppSpacing.cardPadding,
                      bottomPadding,
                    ),
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
    );

    if (embedded) return scrollView;

    return CustomAppScaffold(
      appBar: AppBar(
        title: const Text('طلبات التوريد'),
        centerTitle: true,
      ),
      body: scrollView,
    );
  }
}
