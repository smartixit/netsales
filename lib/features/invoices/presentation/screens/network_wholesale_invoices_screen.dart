import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/invoices/presentation/controllers/network_invoices_controller.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_card.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_search_filter_header.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/indicators/custom_results_counter_bar.dart';

/// شاشة قائمة فواتير مبيعات الجملة لمشغل الشبكة (Network Wholesale Invoices Screen)
class NetworkWholesaleInvoicesScreen
    extends GetView<NetworkInvoicesController> {
  const NetworkWholesaleInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      appBar: AppBar(
        title: const Text('فواتير مبيعات الجملة'),
        actions: [
          if (controller.canCreateInvoice)
            CustomButton.icon(
              icon: Icons.add_rounded,
              tooltip: 'إنشاء فاتورة مبيعات مباشرة',
              backgroundColor: Colors.transparent,
              foregroundColor: colors.primary,
              onPressed: controller.navigateToCreateInvoice,
            ),
          AppSpacing.hXs,
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadInvoices(isRefresh: true),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            children: [
              // 1. رأس البحث والفلترة
              Obx(
                () => InvoiceSearchFilterHeader(
                  searchController: controller.searchController,
                  selectedSaleType: controller.selectedSaleType.value,
                  onSaleTypeChanged: controller.onSaleTypeChanged,
                  onClear: controller.resetFilters,
                  searchHint: 'بحث برقم الفاتورة، UUID، أو اسم نقطة البيع...',
                ),
              ),

              AppSpacing.vSm,

              // شريط موحد لعرض عدد السجلات ونتائج التصفية والبحث
              Obx(
                () => CustomResultsCounterBar(
                  count: controller.invoices.length,
                  recordLabel: 'فاتورة',
                  isFiltered: controller.searchQuery.value.isNotEmpty ||
                      controller.selectedSaleType.value != null,
                  isLoading: controller.isLoading.value && controller.invoices.isEmpty,
                  onClear: controller.resetFilters,
                ),
              ),

              AppSpacing.vMd,

              // 2. قائمة الفواتير مع الترقيم بالمؤشر
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.invoices.isEmpty) {
                    return const CustomSkeletonFeed(itemCount: 4);
                  }

                  if (controller.errorMessage.value != null &&
                      controller.invoices.isEmpty) {
                    return CustomEmptyState(
                      icon: Icons.error_outline,
                      title: 'تعذر تحميل الفواتير',
                      subtitle: controller.errorMessage.value ?? '',
                      actionLabel: 'إعادة المحاولة',
                      onAction: () => controller.loadInvoices(isRefresh: true),
                    );
                  }

                  if (controller.invoices.isEmpty) {
                    return CustomEmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'لا توجد فواتير مبيعات',
                      subtitle: controller.searchQuery.value.isNotEmpty
                          ? 'لم يتم العثور على أي فاتورة تطابق عبارة البحث الحالية.'
                          : 'لم تصدر أي فواتير مبيعات جملة حتى الآن.',
                      actionLabel: controller.searchQuery.value.isNotEmpty
                          ? 'إعادة التعيين'
                          : null,
                      onAction: controller.searchQuery.value.isNotEmpty
                          ? controller.resetFilters
                          : null,
                    );
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (scrollInfo.metrics.pixels >=
                              scrollInfo.metrics.maxScrollExtent - 200 &&
                          controller.hasMore &&
                          !controller.isLoadingMore.value) {
                        controller.loadMoreInvoices();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      itemCount:
                          controller.invoices.length +
                          (controller.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == controller.invoices.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            child: const CustomSkeletonFeed(
                              itemCount: 1,
                              cardHeight: 120,
                            ),
                          );
                        }

                        final invoice = controller.invoices[index];
                        return InvoiceCard(
                          invoice: invoice,
                          isNetworkView: true,
                          onTap: () => controller.openInvoiceDetails(invoice),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
