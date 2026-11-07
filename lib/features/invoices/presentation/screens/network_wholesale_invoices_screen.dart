import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/invoices/presentation/controllers/network_invoices_controller.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_card.dart';
import 'package:netsales/features/invoices/presentation/widgets/invoice_search_filter_header.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة قائمة فواتير مبيعات الجملة لمشغل الشبكة (Network Wholesale Invoices Screen)
class NetworkWholesaleInvoicesScreen
    extends GetView<NetworkInvoicesController> {
  const NetworkWholesaleInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      appBar: AppBar(title: const Text('فواتير مبيعات الجملة')),
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
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.cardPadding),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.primary,
                                    ),
                                  ),
                                  AppSpacing.hSm,
                                  Text(
                                    'جاري تحميل المزيد من الفواتير...',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final invoice = controller.invoices[index];
                        return InvoiceCard(
                          invoice: invoice,
                          isNetworkView: true,
                          onTap: () {
                            Get.toNamed<void>(
                              AppRoutes.saleInvoiceDetails,
                              arguments: invoice,
                            );
                          },
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
