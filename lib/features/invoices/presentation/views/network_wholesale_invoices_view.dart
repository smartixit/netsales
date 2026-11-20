import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/invoices/presentation/controllers/network_invoices_controller.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_card.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoices_search_filter_header.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoices_summary_strip.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_page_hero_card.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';
import 'package:netsales/widgets/lists/custom_cursor_load_more.dart';

/// واجهة استعراض وإدارة فواتير مبيعات الجملة لمشغل الشبكة (Network Workspace View)
class NetworkWholesaleInvoicesView extends GetView<NetworkInvoicesController> {
  const NetworkWholesaleInvoicesView({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return CustomRefreshablePage.slivers(
      embedded: embedded,
      onRefresh: controller.refreshInvoices,
      onLoadMore: controller.loadMoreInvoices,
      hasMore: controller.hasMore,
      hasMorePredicate: () => controller.hasMore,
      scrollKey:
          const PageStorageKey<String>('network-wholesale-invoices-scroll'),
      slivers: [
        // 1. الترويسة القيادية لفواتير مبيعات الجملة وشريط الملخص وفلاتر البحث
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomPageHeroCard(
                title: 'فواتير مبيعات الجملة',
                subtitle:
                    'متابعة فواتير كروت الشبكة، حالات السداد المالي، وتفاصيل الكميات المعتمدة فورياً.',
                icon: Icons.receipt_long_rounded,
                action: controller.canCreateInvoice
                    ? CustomButton.primary(
                        text: 'فاتورة جديدة +',
                        icon: Icons.add_rounded,
                        shape: AppButtonShape.pill,
                        size: AppButtonSize.small,
                        onPressed: controller.navigateToCreateInvoice,
                      )
                    : null,
              ),

              Obx(
                () => InvoicesSummaryStrip(
                  isNetworkView: true,
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
                  searchHint:
                      'بحث برقم الفاتورة، UUID، أو اسم نقطة البيع...',
                ),
              ),

              Obx(() {
                final networks = controller.authorizedNetworks;
                if (networks.length <= 1) return const SizedBox.shrink();
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
                title: 'تعذر جلب فواتير مبيعات الجملة',
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
                title: 'لا توجد فواتير مبيعات',
                subtitle: controller.searchQuery.value.isNotEmpty ||
                        controller.statusFilter.value != null
                    ? 'لم يتم العثور على أي فاتورة تطابق خيارات التصفية المحددة.'
                    : 'لم تصدر أي فواتير مبيعات جملة حتى الآن.',
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
                      isNetworkView: true,
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
