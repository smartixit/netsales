import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/invoices/presentation/controllers/pos_invoices_controller.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_card.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoices_search_filter_header.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoices_summary_strip.dart';
import 'package:netsales/features/invoices/presentation/widgets/pos_embedded_invoices_header.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';
import 'package:netsales/widgets/lists/custom_cursor_load_more.dart';

/// واجهة استعراض وإدارة فواتير المشتريات لنقطة البيع (POS Workspace View)
class PosPurchaseInvoicesView extends GetView<PosInvoicesController> {
  const PosPurchaseInvoicesView({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return CustomRefreshablePage.slivers(
      embedded: embedded,
      onRefresh: controller.refreshInvoices,
      onLoadMore: controller.loadMoreInvoices,
      hasMore: controller.hasMore,
      hasMorePredicate: () => controller.hasMore,
      scrollKey: const PageStorageKey<String>('pos-purchase-invoices-scroll'),
      slivers: [
        // 1. الترويسة القيادية لفواتير المشتريات وشريط الملخص وفلاتر البحث
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (embedded)
                PosEmbeddedInvoicesHeader(controller: controller),

              const CustomPageHeroCard(
                title: 'فواتير المشتريات',
                subtitle:
                    'متابعة فواتير كروت الشبكات، تفاصيل السداد المالي، وتفاصيل الكميات المعتمدة فورياً.',
                icon: Icons.receipt_long_rounded,
              ),

              Obx(
                () => InvoicesSummaryStrip(
                  isNetworkView: false,
                  totalCount: controller.totalInvoicesCount,
                  paidCount: controller.paidInvoicesCount,
                  partiallyPaidCount:
                      controller.partiallyPaidInvoicesCount,
                  unpaidCount: controller.unpaidInvoicesCount,
                  isLoading: controller.isLoading.value &&
                      controller.invoices.isEmpty,
                  selectedStatus: controller.statusFilter.value,
                  onStatusTap: controller.setStatusFilter,
                ),
              ),

              Obx(
                () => InvoicesSearchFilterHeader(
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

        // 2. الحالات التفاعلية المركزية (تحميل أولي، خطأ، فراغ) أو قائمة الفواتير
        Obx(() {
          final isLoading = controller.isLoading.value;
          final error = controller.errorMessage.value;
          final isEmpty = controller.invoices.isEmpty;

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
                title: 'تعذر جلب فواتير المشتريات',
                subtitle: error,
                onRetry: controller.refreshInvoices,
              ),
            );
          }

          if (isEmpty) {
            return SliverToBoxAdapter(
              child: CustomEmptyState(
                icon: controller.searchQuery.value.isNotEmpty ||
                        controller.statusFilter.value != null
                    ? Icons.search_off_rounded
                    : Icons.receipt_long_outlined,
                title: 'لا توجد فواتير مشتريات',
                subtitle: controller.searchQuery.value.isNotEmpty ||
                        controller.statusFilter.value != null
                    ? 'لم يتم العثور على أي فاتورة تطابق خيارات التصفية المحددة.'
                    : 'لم تصدر لك أي فواتير مشتريات من شبكاتك الموردة حتى الآن.',
                actionLabel: controller.searchQuery.value.isNotEmpty ||
                        controller.statusFilter.value != null
                    ? 'إعادة التعيين'
                    : null,
                onAction: controller.searchQuery.value.isNotEmpty ||
                        controller.statusFilter.value != null
                    ? controller.resetFilters
                    : null,
              ),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final invoice = controller.invoices[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Obx(
                    () => InvoiceCard(
                      invoice: invoice,
                      isNetworkView: false,
                      isExpanded: controller.expandedInvoiceId.value ==
                          invoice.invoiceId,
                      onToggleExpansion: () => controller
                          .toggleInvoiceExpansion(invoice.invoiceId),
                      onTap: () =>
                          controller.openInvoiceDetails(invoice),
                    ),
                  ),
                );
              },
              childCount: controller.invoices.length,
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
              onPressed: controller.loadMoreInvoices,
            ),
          ),
        ),
      ],
    );
  }
}
