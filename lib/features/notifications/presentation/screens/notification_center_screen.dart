import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/notification_filter.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:netsales/features/notifications/presentation/widgets/notification_item_card.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/feedback/states/custom_empty_state.dart';
import 'package:netsales/widgets/feedback/states/custom_error_state.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_bar.dart';
import 'package:netsales/widgets/layouts/custom_refreshable_page.dart';
import 'package:netsales/widgets/lists/custom_cursor_load_more.dart';

/// شاشة مركز الإشعارات بأسلوب قيد — نقيّة عبر [GetView<NotificationController>].
class NotificationCenterScreen extends GetView<NotificationController> {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomAppScaffold(
      showBackButton: true,
      appBarTitleWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'مركز الإشعارات',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          Obx(() {
            final unread = controller.unreadCount.value;
            if (unread <= 0) return const SizedBox.shrink();
            return Container(
              margin: EdgeInsetsDirectional.only(start: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                unread > 99 ? '99+' : '$unread',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
                ),
              ),
            );
          }),
        ],
      ),
      actions: [
        Obx(() {
          final hasUnread =
              controller.unreadCount.value > 0 ||
              controller.notifications.any((n) => !n.isRead);

          if (!hasUnread) return const SizedBox.shrink();

          return Padding(
            padding: EdgeInsetsDirectional.only(end: AppSpacing.sm),
            child: CustomButton.icon(
              icon: Icons.done_all_rounded,
              tooltip: 'تعليم الكل كمقروء',
              size: AppButtonSize.small,
              foregroundColor: colors.primary,
              backgroundColor: colors.primary.withValues(alpha: 0.1),
              loading: controller.isMarkingAllRead.value,
              onPressed: controller.markAllAsRead,
            ),
          );
        }),
      ],
      body: CustomRefreshablePage.slivers(
        onRefresh: controller.loadInitialData,
        onLoadMore: controller.loadMoreNotifications,
        hasMorePredicate: () =>
            controller.hasMore && !controller.isLoadingMore.value,
        maxContentWidth: 720,
        scrollKey: const PageStorageKey<String>('notifications-center-scroll'),
        slivers: [
          SliverToBoxAdapter(
            child: Obx(() {
              final items = controller.filteredNotifications;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomSearchFilterBar<NotificationFilter>(
                    searchController: controller.searchController,
                    searchQuery: controller.searchQuery.value,
                    searchHint: 'بحث في الإشعارات والتنبيهات...',
                    onClearSearch: controller.clearSearch,
                    selectedFilter: controller.selectedFilter.value,
                    filterOptions: controller.filterOptions,
                    onFilterChanged: (filter) {
                      if (filter != null) controller.setFilter(filter);
                    },
                    kpiCards: controller.buildKpiCards(context),
                    selectedKpiKey: controller.selectedFilter.value.wireValue,
                    isKpiLoading: controller.isLoading.value &&
                        controller.notifications.isEmpty,
                    onKpiSelected: controller.onKpiSelected,
                    resultsCount: controller.isLoading.value &&
                            controller.notifications.isEmpty
                        ? null
                        : items.length,
                    totalCount: controller.notifications.length,
                    recordLabel: 'إشعار',
                    hasActiveFilters: controller.hasActiveFilters,
                    isLoadingResults: controller.isLoading.value,
                    onClearAll: controller.resetFilters,
                  ),
                  AppSpacing.vSm,
                ],
              );
            }),
          ),
          Obx(() {
            if (controller.isLoading.value && controller.notifications.isEmpty) {
              return const SliverToBoxAdapter(
                child: CustomStateView.loading(
                  presentation: CustomStatePresentation.skeletonOnly,
                  skeleton: CustomStateSkeleton(
                    layout: CustomStateSkeletonLayout.list,
                    itemCount: 4,
                    cardHeight: 120,
                    hasLeading: true,
                  ),
                ),
              );
            }

            if (controller.errorMessage.value != null &&
                controller.notifications.isEmpty) {
              return SliverToBoxAdapter(
                child: CustomErrorState(
                  title: 'تعذر تحميل الإشعارات',
                  subtitle: controller.errorMessage.value,
                  onRetry: controller.loadInitialData,
                ),
              );
            }

            final items = controller.filteredNotifications;
            if (items.isEmpty) {
              return SliverToBoxAdapter(
                child: CustomEmptyState.boxed(
                  icon: Icons.notifications_off_outlined,
                  title: 'لا توجد إشعارات مطابقة',
                  subtitle: controller.hasActiveFilters
                      ? 'جرّب تعديل البحث أو مسح الفلاتر.'
                      : 'ستظهر هنا كافة الإشعارات والتنبيهات الواردة إليك.',
                ),
              );
            }

            return SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => AppSpacing.vSm,
              itemBuilder: (ctx, index) {
                final item = items[index];
                return NotificationItemCard(
                  notification: item,
                  onTap: () => controller.openNotificationDetails(ctx, item),
                  onPreviewImage: item.hasImage
                      ? () => controller.openMediaPreview(ctx, item)
                      : null,
                  onMarkAsRead: item.isRead
                      ? null
                      : () => controller.markAsRead(item),
                );
              },
            );
          }),
          SliverToBoxAdapter(
            child: Obx(
              () => CustomCursorLoadMore(
                isLoading: controller.isLoadingMore.value,
                hasMore: controller.hasMore,
                error: null,
                onPressed: controller.loadMoreNotifications,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
