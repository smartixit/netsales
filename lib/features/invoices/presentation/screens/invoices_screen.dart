import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/invoices/presentation/controllers/base_invoices_controller.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_card.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/indicators/custom_status_summary_strip.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_bar.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';
import 'package:netsales/widgets/lists/custom_cursor_load_more.dart';

/// واجهة استعراض وإدارة فواتير المبيعات والمشتريات الموحدة (InvoicesScreen)
///
/// تجسد المعمارية المؤسسية النظيفة (Enterprise Clean Architecture):
/// - كلاس واحد في ملف واحد بمسؤولية واحدة واضحة (One Public Class Per File).
/// - واجهة تصريحية بحتة (Pure Declarative UI) خالية تماماً من منطق الأعمال والشروط المتفرعة.
/// - تعتمد نمط الاستراتيجية (Strategy Pattern) باستهلاك العقد المعماري الموحد [BaseInvoicesController]،
///   بحيث تتكيف الشاشة تلقائياً وفق مساحة العمل المحقونة (مساحة الشبكة أو نقطة البيع).
class InvoicesScreen extends GetView<BaseInvoicesController> {
  const InvoicesScreen({super.key, this.embedded = false, this.isNetwork});

  final bool embedded;
  final bool? isNetwork;

  @override
  Widget build(BuildContext context) {
    final content = CustomRefreshablePage.slivers(
      embedded: embedded,
      onRefresh: () => controller.loadInvoices(isRefresh: true),
      onLoadMore: controller.loadMoreInvoices,
      hasMore: controller.hasMore,
      hasMorePredicate: () => controller.hasMore,
      scrollKey: const PageStorageKey<String>('invoices-scroll-key'),
      slivers: [
        // 1. ترويسة الصفحة وبطاقات المؤشرات والبحث والتصفية
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(
                () => CustomPageHeroCard(
                  title: controller.pageTitle,
                  subtitle: controller.pageSubtitle,
                  icon: controller.pageIcon,
                  action: controller.headerAction,
                ),
              ),

              Obx(
                () => CustomStatusSummaryStrip(
                  cards: controller.buildKpiCards(context),
                  isLoading:
                      controller.isLoading.value && controller.invoices.isEmpty,
                  selectedKey: controller.paymentStatusFilter.value,
                  onSelectKey: controller.setPaymentStatusFilter,
                ),
              ),

              Obx(
                () => CustomSearchFilterBar<String?>(
                  searchController: controller.searchController,
                  searchQuery: controller.searchQuery.value,
                  searchHint: controller.searchHint,
                  selectedFilter: controller.paymentStatusFilter.value,
                  filterOptions: controller.buildFilterOptions(context),
                  onFilterChanged: controller.setPaymentStatusFilter,
                  onClearSearch: controller.searchController.clear,
                ),
              ),

              Obx(
                () =>
                    controller.buildExtraFilters(context) ??
                    const SizedBox.shrink(),
              ),
              SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),

        // 2. حالات القائمة (تحميل، خطأ، فراغ) أو عناصر الفواتير المعتمدة
        Obx(() {
          final isLoading = controller.isLoading.value;
          final error = controller.errorMessage.value;
          final isEmpty = controller.invoices.isEmpty;
          final hasFilter =
              controller.paymentStatusFilter.value != null ||
              controller.selectedSaleType.value != null ||
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
                title: 'تعذر جلب الفواتير',
                subtitle: error,
                onRetry: () => controller.loadInvoices(isRefresh: true),
              ),
            );
          }

          if (isEmpty) {
            return SliverToBoxAdapter(
              child: CustomEmptyState(
                icon: hasFilter
                    ? Icons.search_off_rounded
                    : Icons.receipt_long_outlined,
                title: hasFilter
                    ? 'لا توجد فواتير مطابقة'
                    : 'لا توجد فواتير حالياً',
                subtitle: hasFilter
                    ? 'جرّب تغيير كلمات البحث أو تصفية الحالات.'
                    : 'ستظهر هنا فواتير المبيعات أو المشتريات فور إصدارها.',
                actionLabel: hasFilter ? 'مسح عوامل التصفية' : null,
                onAction: hasFilter ? controller.resetFilters : null,
              ),
            );
          }

          final invoiceCount = controller.invoices.length;
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index.isOdd) return AppSpacing.vSm;
              final invoiceIndex = index ~/ 2;
              final invoice = controller.invoices[invoiceIndex];

              return Obx(() {
                final isExpanded =
                    controller.expandedInvoiceId.value == invoice.invoiceId;

                return InvoiceCard(
                  key: ValueKey<String>('invoice-${invoice.invoiceId}'),
                  invoice: invoice,
                  isNetworkPerspective: isNetwork ?? true,
                  isExpanded: isExpanded,
                  onToggleExpand: () =>
                      controller.toggleInvoiceExpansion(invoice.invoiceId),
                  onDetails: () => controller.openInvoiceDetails(invoice),
                  onPrint: () => controller.printInvoice(invoice),
                  onShare: () => controller.shareInvoice(invoice),
                  actions: controller.buildCardActions(context, invoice),
                );
              });
            }, childCount: invoiceCount == 0 ? 0 : invoiceCount * 2 - 1),
          );
        }),

        // 3. ذيل التحميل الإضافي الموحد (CustomCursorLoadMore)
        SliverToBoxAdapter(
          child: Obx(
            () => CustomCursorLoadMore(
              hasMore: controller.hasMore,
              isLoading: controller.isLoadingMore.value,
              error: controller.loadMoreError.value,
              onPressed: controller.loadMoreInvoices,
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
