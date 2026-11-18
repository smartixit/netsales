import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/presentation/controllers/network_procurement_review_controller.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_orders_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_orders_hero.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_orders_summary_strip.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_search_filter_header.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

/// واجهة استعراض وإدارة طلبات التوريد الموحدة للمنصة (ProcurementOrdersScreen)
///
/// تعمل كواجهة موحدة وحيدة لكلا مساحتي العمل:
/// 1. مساحة نقطة البيع (POS Workspace): متابعة الطلبات، التعديل، الإلغاء، وإنشاء طلب جديد.
/// 2. مساحة شبكة التوزيع (Network Workspace): مراجعة الطلبات الواردة، الاعتماد، التعديل، والرفض.
///
/// مصممة وفق أحدث معايير الكلين كود:
/// - هوامش موحدة متطابقة 100% مع لوحة التحكم لمنع أي تداخل مع AppBar أو BottomNavBar.
/// - حاوية متجاوبة مركزية بحد أقصى للعرض (760px).
/// - شجرة تمرير أحادية تحافظ على انسيابية الأداء ودعم مؤشرات السحب للتحديث والترقيم بالـ Cursor.
/// - دعم التشغيل المباشر للـ Skeleton Shimmer عند التصفية والبحث دون وميض للحالة الفارغة.
class ProcurementOrdersScreen extends StatelessWidget {
  const ProcurementOrdersScreen({
    super.key,
    this.embedded = false,
    this.isNetwork,
  });

  final bool embedded;
  final bool? isNetwork;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isNetworkWorkspace =
        isNetwork ??
        (Get.isRegistered<WorkspaceService>() &&
            WorkspaceService.to.activeWorkspace == AppWorkspace.network);

    // ربط المتحكم بحسب سياق مساحة العمل
    final networkCtrl = isNetworkWorkspace
        ? Get.find<NetworkProcurementReviewController>()
        : null;
    final posCtrl = isNetworkWorkspace
        ? null
        : Get.find<PosProcurementOrdersController>();

    // هوامش موحدة ومتطابقة بدقة مع لوحة التحكم لتجنب أي تداخل مع شريط التطبيق أو شريط التنقل السفلي
    final topPadding = embedded
        ? MediaQuery.paddingOf(context).top + 20.h
        : AppSpacing.md;
    final bottomPadding = embedded
        ? 115.h + MediaQuery.paddingOf(context).bottom
        : MediaQuery.paddingOf(context).bottom + AppSpacing.xl;
    final horizontalPadding = AppBreakpoints.screenMargin(context);

    // الخصائص المشتركة بين المتحكمين
    final requests = isNetworkWorkspace
        ? networkCtrl!.requests
        : posCtrl!.requests;
    final isLoading = isNetworkWorkspace
        ? networkCtrl!.isLoading
        : posCtrl!.isLoading;
    final errorMessage = isNetworkWorkspace
        ? networkCtrl!.errorMessage
        : posCtrl!.errorMessage;
    final hasMore = isNetworkWorkspace
        ? networkCtrl!.hasMore
        : posCtrl!.hasMore;
    final searchController = isNetworkWorkspace
        ? networkCtrl!.searchController
        : posCtrl!.searchController;
    final searchQuery = isNetworkWorkspace
        ? networkCtrl!.searchQuery
        : posCtrl!.searchQuery;
    final statusFilter = isNetworkWorkspace
        ? networkCtrl!.statusFilter
        : posCtrl!.statusFilter;
    final expandedRequestId = isNetworkWorkspace
        ? networkCtrl!.expandedRequestId
        : posCtrl!.expandedRequestId;

    Future<void> onRefresh() async {
      if (isNetworkWorkspace) {
        await networkCtrl!.refreshOrders();
      } else {
        await posCtrl!.refreshOrders();
      }
    }

    void onLoadMore() {
      if (isNetworkWorkspace) {
        networkCtrl!.loadMoreRequests();
      } else {
        posCtrl!.loadMoreRequests();
      }
    }

    void onStatusChanged(String? status) {
      if (isNetworkWorkspace) {
        networkCtrl!.setStatusFilter(status);
      } else {
        posCtrl!.setStatusFilter(status);
      }
    }

    void onResetFilters() {
      if (isNetworkWorkspace) {
        networkCtrl!.resetFilters();
      } else {
        posCtrl!.resetFilters();
      }
    }

    void onToggleAccordion(int requestId) {
      if (isNetworkWorkspace) {
        networkCtrl!.toggleAccordion(requestId);
      } else {
        posCtrl!.toggleAccordion(requestId);
      }
    }

    void onOpenDetails(RequestEntity request) {
      if (isNetworkWorkspace) {
        networkCtrl!.openRequestDetails(request);
      } else {
        posCtrl!.openRequestDetails(request);
      }
    }

    final scrollView = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: RefreshIndicator.adaptive(
          edgeOffset: embedded ? topPadding - 14.h : 0.0,
          displacement: 36.h,
          color: colors.primary,
          backgroundColor: colors.surface,
          strokeWidth: 2.5,
          onRefresh: onRefresh,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scroll) {
              if (scroll.depth == 0 &&
                  scroll.metrics.extentAfter <= 220 &&
                  hasMore) {
                onLoadMore();
              }
              return false;
            },
            child: CustomScrollView(
              key: PageStorageKey<String>(
                isNetworkWorkspace
                    ? 'network-procurement-orders-scroll'
                    : 'pos-procurement-orders-scroll',
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
                      // 1. الترويسة القيادية لهوية الطلبات
                      ProcurementOrdersHero(
                        embedded: embedded,
                        title: isNetworkWorkspace
                            ? 'طلبات التوريد الواردة'
                            : 'طلبات التوريد',
                        subtitle: isNetworkWorkspace
                            ? 'مراجعة واعتماد طلبات نقاط البيع، مقارنة الكميات والأسعار، وإصدار الفواتير المعتمدة.'
                            : 'متابعة وإدارة طلبات كروت الشبكات، حالات الاعتماد، وتفاصيل الكميات فورياً.',
                        canCreate:
                            !isNetworkWorkspace &&
                            !embedded &&
                            (posCtrl?.canCreateOrder ?? false),
                        onCreate: !isNetworkWorkspace
                            ? () => posCtrl?.navigateToNewOrder()
                            : null,
                      ),

                      // 2. شريط ملخص المؤشرات الموحد
                      Obx(
                        () => ProcurementOrdersSummaryStrip(
                          isNetworkView: isNetworkWorkspace,
                          totalCount: isNetworkWorkspace
                              ? networkCtrl!.totalOrdersCount
                              : posCtrl!.totalOrdersCount,
                          pendingCount: isNetworkWorkspace
                              ? networkCtrl!.pendingOrdersCount
                              : posCtrl!.pendingOrdersCount,
                          approvedCount: isNetworkWorkspace
                              ? networkCtrl!.approvedOrdersCount
                              : posCtrl!.approvedOrdersCount,
                          isLoading: isLoading.value && requests.isEmpty,
                          selectedStatus: statusFilter.value,
                          onStatusTap: onStatusChanged,
                        ),
                      ),

                      // 3. شريط البحث والفلترة السريعة
                      Obx(
                        () => ProcurementSearchFilterHeader(
                          searchController: searchController,
                          searchQuery: searchQuery.value,
                          selectedStatus: statusFilter.value,
                          onStatusChanged: onStatusChanged,
                          onClearSearch: searchController.clear,
                        ),
                      ),

                      // 4. منتقي الشبكات التابعة في حالة وجود أكثر من شبكة للمشغل
                      if (isNetworkWorkspace)
                        Obx(() {
                          final networks = networkCtrl!.authorizedNetworks;
                          if (networks.length <= 1) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.sm),
                            child: CustomDropdown<int>(
                              label: 'تصفية بحسب الشبكة',
                              searchEnabled: false,
                              rxValue: networkCtrl.selectedNetworkId,
                              items: networks.map((net) {
                                return DropdownItem<int>(
                                  value: net.networkId,
                                  child: Text(net.networkName),
                                );
                              }).toList(),
                              onChanged: networkCtrl.onNetworkFilterChanged,
                            ),
                          );
                        }),
                    ]),
                  ),
                ),

                // 5. محتوى القائمة: التحميل، الأخطاء، القائمة الفارغة، والبطاقات
                Obx(() {
                  if (isLoading.value && requests.isEmpty) {
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

                  if (errorMessage.value != null && requests.isEmpty) {
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
                            title: isNetworkWorkspace
                                ? 'تعذر جلب طلبات التوريد الواردة'
                                : 'تعذر جلب طلبات التوريد',
                            subtitle: errorMessage.value,
                            onRetry: onRefresh,
                          ),
                        ),
                      ),
                    );
                  }

                  if (requests.isEmpty) {
                    final hasFilter =
                        statusFilter.value != null ||
                        searchQuery.value.trim().isNotEmpty;

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
                                : (isNetworkWorkspace
                                      ? Icons.inbox_outlined
                                      : Icons.inventory_2_outlined),
                            title: hasFilter
                                ? 'لا توجد طلبات مطابقة'
                                : (isNetworkWorkspace
                                      ? 'لا توجد طلبات توريد واردة حالياً'
                                      : 'لا توجد طلبات توريد حالياً'),
                            subtitle: hasFilter
                                ? 'جرّب تغيير كلمات البحث أو تصفية الحالات.'
                                : (isNetworkWorkspace
                                      ? 'ستظهر هنا طلبات شراء الكروت الواردة من نقاط البيع المرتبطة.'
                                      : 'يمكنك إنشاء طلب توريد جديد من شبكاتك الموردة.'),
                            actionLabel: hasFilter
                                ? 'مسح عوامل التصفية'
                                : (!isNetworkWorkspace &&
                                          (posCtrl?.canCreateOrder ?? false)
                                      ? 'طلب توريد جديد'
                                      : null),
                            onAction: hasFilter
                                ? onResetFilters
                                : (!isNetworkWorkspace &&
                                          (posCtrl?.canCreateOrder ?? false)
                                      ? () => posCtrl?.navigateToNewOrder()
                                      : null),
                          ),
                        ),
                      ),
                    );
                  }

                  final requestCount = requests.length;
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
                          final request = requests[requestIndex];

                          return Obx(() {
                            final isExpanded =
                                expandedRequestId.value == request.requestId;

                            if (isNetworkWorkspace) {
                              return ProcurementOrderCard(
                                key: ValueKey<String>(
                                  'network-procurement-order-${request.requestId}',
                                ),
                                request: request,
                                isNetworkView: true,
                                isExpanded: isExpanded,
                                onToggleExpand: () =>
                                    onToggleAccordion(request.requestId),
                                onDetails: () => onOpenDetails(request),
                                onApprove:
                                    (request.isPending &&
                                        networkCtrl!.canApproveRequests)
                                    ? () => networkCtrl.promptApproveRequest(
                                        request,
                                      )
                                    : null,
                                onModify:
                                    (request.isPending &&
                                        networkCtrl!.canModifyRequests)
                                    ? () => networkCtrl.openModificationSheet(
                                        request,
                                      )
                                    : null,
                                onReject:
                                    (request.isPending &&
                                        networkCtrl!.canRejectRequests)
                                    ? () => networkCtrl.promptRejectRequest(
                                        request,
                                      )
                                    : null,
                              );
                            }

                            return ProcurementOrderCard(
                              key: ValueKey<String>(
                                'pos-procurement-order-${request.requestId}',
                              ),
                              request: request,
                              isNetworkView: false,
                              isExpanded: isExpanded,
                              onToggleExpand: () =>
                                  onToggleAccordion(request.requestId),
                              onDetails: () => onOpenDetails(request),
                              onEdit:
                                  (request.isPending && posCtrl!.canCreateOrder)
                                  ? () => posCtrl.openEditOrder(request)
                                  : null,
                              onCancel:
                                  (request.isPending && posCtrl!.canCancelOrder)
                                  ? () => posCtrl.promptCancelRequest(request)
                                  : null,
                              onDelete:
                                  (request.isCancelled &&
                                      posCtrl!.canCancelOrder)
                                  ? () => posCtrl.promptDeleteRequest(request)
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

    if (embedded) return scrollView;

    return CustomAppScaffold(
      appBarTitle: isNetworkWorkspace
          ? 'طلبات التوريد الواردة'
          : 'طلبات التوريد',
      body: scrollView,
    );
  }
}
