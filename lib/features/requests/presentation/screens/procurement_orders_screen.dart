import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/requests/presentation/controllers/base_procurement_orders_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/indicators/custom_status_summary_strip.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_bar.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';
import 'package:netsales/widgets/lists/custom_cursor_load_more.dart';

/// واجهة استعراض وإدارة طلبات التوريد الموحدة للمنصة (ProcurementOrdersScreen)
///
/// تجسد المعمارية المؤسسية النظيفة (Enterprise Clean Architecture):
/// - كلاس واحد في ملف واحد بمسؤولية واحدة واضحة (One Public Class Per File).
/// - واجهة تصريحية بحتة (Pure Declarative UI) خالية تماماً من منطق الأعمال والشروط المتفرعة.
/// - تعتمد نمط الاستراتيجية (Strategy Pattern) باستهلاك العقد المعماري الموحد [BaseProcurementOrdersController]،
///   بحيث تتكيف الشاشة تلقائياً وفق مساحة العمل المحقونة (مساحة الشبكة أو نقطة البيع) بدون تكرار سطر كود واحد.
class ProcurementOrdersScreen extends GetView<BaseProcurementOrdersController> {
  const ProcurementOrdersScreen({
    super.key,
    this.embedded = false,
    this.isNetwork,
  });

  final bool embedded;
  final bool? isNetwork;

  @override
  Widget build(BuildContext context) {
    final content = CustomRefreshablePage.slivers(
      embedded: embedded,
      onRefresh: controller.refreshOrders,
      onLoadMore: controller.loadMoreRequests,
      hasMore: controller.hasMore,
      hasMorePredicate: () => controller.hasMore,
      scrollKey: const PageStorageKey<String>('procurement-orders-scroll'),
      slivers: [
        // 1. ترويسة الصفحة وبطاقات المؤشرات والبحث والتصفية
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomPageHeroCard(
                title: controller.pageTitle,
                subtitle: controller.pageSubtitle,
                icon: controller.pageIcon,
                action: controller.headerAction,
              ),

              Obx(
                () => CustomStatusSummaryStrip(
                  cards: controller.buildKpiCards(context),
                  isLoading:
                      controller.isLoading.value && controller.requests.isEmpty,
                  selectedKey: controller.statusFilter.value,
                  onSelectKey: controller.setStatusFilter,
                ),
              ),

              Obx(
                () => CustomSearchFilterBar<String?>(
                  searchController: controller.searchController,
                  searchQuery: controller.searchQuery.value,
                  searchHint: controller.searchHint,
                  selectedFilter: controller.statusFilter.value,
                  filterOptions: controller.buildFilterOptions(context),
                  onFilterChanged: controller.setStatusFilter,
                  onClearSearch: controller.searchController.clear,
                ),
              ),

              controller.buildExtraFilters(context) ?? const SizedBox.shrink(),

              SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),

        // 2. حالات القائمة (تحميل، خطأ، فراغ) أو عناصر الطلبات المعتمدة
        Obx(() {
          final isLoading = controller.isLoading.value;
          final error = controller.errorMessage.value;
          final isEmpty = controller.requests.isEmpty;
          final hasFilter =
              controller.statusFilter.value != null ||
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
                    : Icons.inbox_outlined,
                title: hasFilter
                    ? 'لا توجد طلبات مطابقة'
                    : 'لا توجد طلبات توريد حالياً',
                subtitle: hasFilter
                    ? 'جرّب تغيير كلمات البحث أو تصفية الحالات.'
                    : 'ستظهر هنا طلبات شراء الكروت فور ورودها أو إرسالها.',
                actionLabel: hasFilter ? 'مسح عوامل التصفية' : null,
                onAction: hasFilter ? controller.resetFilters : null,
              ),
            );
          }

          final requestCount = controller.requests.length;
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index.isOdd) return AppSpacing.vSm;
              final requestIndex = index ~/ 2;
              final request = controller.requests[requestIndex];

              return Obx(() {
                final isExpanded =
                    controller.expandedRequestId.value == request.requestId;

                return ProcurementOrderCard(
                  key: ValueKey<String>(
                    'procurement-order-${request.requestId}',
                  ),
                  request: request,
                  isExpanded: isExpanded,
                  onToggleExpand: () =>
                      controller.toggleAccordion(request.requestId),
                  onDetails: () => controller.openRequestDetails(request),
                  onInvoiceTap: request.invoiceId != null
                      ? () => controller.openInvoice(request.invoiceId!)
                      : null,
                  actions: controller.buildCardActions(context, request),
                );
              });
            }, childCount: requestCount == 0 ? 0 : requestCount * 2 - 1),
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

    if (embedded) return content;

    return Obx(
      () => CustomAppScaffold(appBarTitle: controller.pageTitle, body: content),
    );
  }
}
