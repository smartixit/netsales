import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/pos_embedded_orders_header.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_request_card.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_search_filter_header.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_card.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';

/// شاشة قائمة طلبات التوريد والشراء لنقطة البيع (POS Procurement Orders Screen)
class PosProcurementOrdersScreen extends GetView<PosProcurementController> {
  const PosProcurementOrdersScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final content = Column(
      children: [
        if (embedded) PosEmbeddedOrdersHeader(controller: controller),

        // شريط البحث والفلترة
        Obx(() {
          return ProcurementSearchFilterHeader(
            searchController: controller.searchController,
            searchQuery: controller.searchQuery.value,
            selectedStatus: controller.statusFilter.value,
            onStatusChanged: controller.setStatusFilter,
            onClearSearch: controller.searchController.clear,
          );
        }),

        // قائمة الطلبات مع حالات التحميل والخطأ
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: CustomSkeletonFeed(itemCount: 4, cardHeight: 130.h),
              );
            }

            if (controller.errorMessage.value != null &&
                controller.requests.isEmpty) {
              return Center(
                child: CustomErrorState(
                  title: 'تعذر جلب طلبات التوريد',
                  subtitle: controller.errorMessage.value,
                  onRetry: () => controller.loadRequests(isRefresh: true),
                ),
              );
            }

            if (controller.requests.isEmpty) {
              final hasFilter = controller.statusFilter.value != null;
              return Center(
                child: CustomEmptyState(
                  icon: hasFilter
                      ? Icons.search_off_rounded
                      : Icons.inventory_2_outlined,
                  title: hasFilter
                      ? 'لا توجد طلبات مطابقة للحالة'
                      : 'لا توجد طلبات توريد حالياً',
                  subtitle: hasFilter
                      ? 'لم يتم العثور على أي طلبات بالحالة المختارة.'
                      : 'يمكنك إنشاء طلب كروت جديد من شبكاتك الموردة.',
                  actionLabel: hasFilter
                      ? 'عرض جميع الطلبات'
                      : (controller.canCreateOrder ? 'طلب توريد جديد' : null),
                  onAction: hasFilter
                      ? () => controller.setStatusFilter(null)
                      : (controller.canCreateOrder
                          ? controller.navigateToNewOrder
                          : null),
                ),
              );
            }

            return RefreshIndicator.adaptive(
              onRefresh: () => controller.loadRequests(isRefresh: true),
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scroll) {
                  if (scroll.metrics.pixels >=
                      scroll.metrics.maxScrollExtent - 200) {
                    controller.loadMoreRequests();
                  }
                  return false;
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(AppSpacing.cardPadding),
                  itemCount:
                      controller.requests.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  separatorBuilder: (context, index) => AppSpacing.vSm,
                  itemBuilder: (context, index) {
                    if (index == controller.requests.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        child: CustomSkeletonCard(
                          height: 130.h,
                        ),
                      );
                    }

                    final request = controller.requests[index];
                    return ProcurementRequestCard(
                      request: request,
                      isNetworkView: false,
                      onTap: () => controller.openRequestDetails(request),
                      onCancel: (request.isPending && controller.canCancelOrder)
                          ? () => controller.promptCancelRequest(request)
                          : null,
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ],
    );

    if (embedded) return content;

    return CustomAppScaffold(
      appBar: AppBar(
        title: Text(
          'طلبات التوريد والمشتريات',
          style: AppTypography.titleMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          CustomButton.icon(
            icon: Icons.refresh_rounded,
            tooltip: 'تحديث الطلبات',
            backgroundColor: Colors.transparent,
            foregroundColor: colors.onSurfaceVariant,
            onPressed: () => controller.loadRequests(isRefresh: true),
          ),
          AppSpacing.hXs,
        ],
      ),
      floatingActionButton: controller.canCreateOrder
          ? FloatingActionButton.extended(
              onPressed: controller.navigateToNewOrder,
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: Text(
                'طلب توريد جديد',
                style: AppTypography.labelLarge.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      body: content,
    );
  }
}

