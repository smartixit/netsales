import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/invoices/presentation/controllers/pos_invoices_controller.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_card.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_search_filter_header.dart';
import 'package:netsales/features/invoices/presentation/widgets/pos_embedded_invoices_header.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة قائمة فواتير المشتريات لنقطة البيع (POS Purchase Invoices Screen)
class PosPurchaseInvoicesScreen extends GetView<PosInvoicesController> {
  const PosPurchaseInvoicesScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = RefreshIndicator(
      onRefresh: () => controller.loadInvoices(isRefresh: true),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          children: [
            if (embedded) PosEmbeddedInvoicesHeader(controller: controller),

            // 1. رأس البحث والفلترة
            Obx(
              () => InvoiceSearchFilterHeader(
                searchController: controller.searchController,
                selectedSaleType: controller.selectedSaleType.value,
                onSaleTypeChanged: controller.onSaleTypeChanged,
                onClear: controller.resetFilters,
                searchHint:
                    'بحث برقم الفاتورة، UUID، أو اسم الشبكة المزودة...',
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
                      title: 'تعذر تحميل فواتير المشتريات',
                      subtitle: controller.errorMessage.value ?? '',
                      actionLabel: 'إعادة المحاولة',
                      onAction: () => controller.loadInvoices(isRefresh: true),
                    );
                  }

                  if (controller.invoices.isEmpty) {
                    return CustomEmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'لا توجد فواتير مشتريات',
                      subtitle: controller.searchQuery.value.isNotEmpty
                          ? 'لم يتم العثور على أي فاتورة تطابق عبارة البحث.'
                          : 'لم تسجل أي فواتير مشتريات لصالح نقطة البيع بعد.',
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
                          isNetworkView: false,
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
      );
    

    if (embedded) return content;

    return CustomAppScaffold(
      appBar: AppBar(title: const Text('فواتير المشتريات')),
      body: content,
    );
  }
}

