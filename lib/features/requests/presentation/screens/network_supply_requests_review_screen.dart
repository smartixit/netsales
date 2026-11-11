import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/controllers/network_procurement_review_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_request_card.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_search_filter_header.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

/// شاشة مراجعة واعتماد طلبات التوريد لمشغلي الشبكة (Network Procurement Review Queue Screen)
class NetworkSupplyRequestsReviewScreen
    extends GetView<NetworkProcurementReviewController> {
  const NetworkSupplyRequestsReviewScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final content = Column(
      children: [
        if (embedded)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.cardPadding,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'مراجعة طلبات التوريد الواردة',
                    style: AppTypography.titleMedium.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                ),
                CustomButton.icon(
                  icon: Icons.refresh_rounded,
                  tooltip: 'تحديث الطلبات',
                  backgroundColor: Colors.transparent,
                  foregroundColor: colors.onSurfaceVariant,
                  onPressed: () => controller.loadRequests(isRefresh: true),
                ),
              ],
            ),
          ),
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

        // منتقي الشبكة عند تعدد شبكات المشغل
        Obx(() {
          final networks = controller.authorizedNetworks;
          if (networks.length <= 1) return const SizedBox.shrink();

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
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

        // قائمة الطلبات الواردة
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: CustomSkeletonFeed(itemCount: 4, cardHeight: 140.h),
              );
            }

            if (controller.errorMessage.value != null &&
                controller.requests.isEmpty) {
              return Center(
                child: CustomErrorState(
                  title: 'تعذر جلب طلبات التوريد الواردة',
                  subtitle: controller.errorMessage.value,
                  onRetry: () => controller.loadRequests(isRefresh: true),
                ),
              );
            }

            if (controller.requests.isEmpty) {
              return const Center(
                child: CustomEmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'لا توجد طلبات توريد واردة',
                  subtitle: 'جميع طلبات الكروت الواردة تمت معالجتها واعتمادها.',
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
                      return const CustomSkeletonFeed(
                        itemCount: 1,
                        cardHeight: 132,
                      );
                    }

                    final request = controller.requests[index];
                    return ProcurementRequestCard(
                      request: request,
                      isNetworkView: true,
                      onTap: () => controller.openRequestDetails(request),
                      onModify: (request.isPending && controller.canModifyRequests)
                          ? () => controller.openModificationSheet(request)
                          : null,
                      onApprove: (request.isPending && controller.canApproveRequests)
                          ? () => controller.promptApproveRequest(request)
                          : null,
                      onReject: (request.isPending && controller.canRejectRequests)
                          ? () => controller.promptRejectRequest(request)
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
          'مراجعة طلبات التوريد الواردة',
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
      body: content,
    );
  }
}
